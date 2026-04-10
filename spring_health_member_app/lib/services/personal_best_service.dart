import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/personal_best_model.dart';
import '../services/gamification_service.dart';

/// XP constants for personal best logging
class PersonalBestXP {
  static const int beatPersonalBest = 50;
  static const int matchPersonalBest = 20;
  static const int loggedEntry = 10;
  static const int dailyChecklist = 100; // all 6 exercises logged in one day
}

class PersonalBestService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _exercisesRef(String uid) =>
      _db.collection('personal_bests').doc(uid).collection('exercises');

  CollectionReference<Map<String, dynamic>> _gamificationRef(String uid) =>
      _db.collection('gamification');

  // ─── Read ──────────────────────────────────────────────────────────────────

  Stream<List<PersonalBestRecord>> watchRecords(String uid) {
    return _exercisesRef(uid).snapshots().map(
      (snap) => snap.docs
          .map((d) => PersonalBestRecord.fromMap(d.data(), d.id))
          .toList(),
    );
  }

  Future<PersonalBestRecord?> getRecord(
    String uid,
    CoreExercise exercise,
  ) async {
    final doc = await _exercisesRef(uid).doc(exercise.key).get();
    if (!doc.exists) return null;
    return PersonalBestRecord.fromMap(doc.data()!, doc.id);
  }

  Future<Map<CoreExercise, PersonalBestRecord>> getAllRecords(
    String uid,
  ) async {
    final snap = await _exercisesRef(uid).get();
    final result = <CoreExercise, PersonalBestRecord>{};
    for (final doc in snap.docs) {
      try {
        final exercise = CoreExercise.values.firstWhere((e) => e.key == doc.id);
        result[exercise] = PersonalBestRecord.fromMap(doc.data(), doc.id);
      } catch (_) {
        // unknown exercise key — skip
      }
    }
    return result;
  }

  // ─── Write ─────────────────────────────────────────────────────────────────

  /// Log a new entry for an exercise. Returns XP earned.
  Future<int> logEntry({
    required String uid,
    required CoreExercise exercise,
    required int value,
  }) async {
    try {
      final existing = await getRecord(uid, exercise);
      final currentBest = existing?.currentBest ?? 0;
      final now = DateTime.now();

      // Calculate XP
      int xpEarned;
      bool isPersonalBest = false;
      if (value > currentBest) {
        xpEarned = PersonalBestXP.beatPersonalBest;
        isPersonalBest = true;
      } else if (value == currentBest && currentBest > 0) {
        xpEarned = PersonalBestXP.matchPersonalBest;
      } else {
        xpEarned = PersonalBestXP.loggedEntry;
      }

      final newEntry = PersonalBestEntry(
        date: now,
        value: value,
        xpEarned: xpEarned,
        isPersonalBest: isPersonalBest,
      );

      final updatedHistory = [...(existing?.history ?? []), newEntry];

      await _exercisesRef(uid).doc(exercise.key).set({
        'exerciseKey': exercise.key,
        'currentBest': isPersonalBest ? value : currentBest,
        'history': updatedHistory.map((e) => e.toMap()).toList(),
        'lastLoggedDate': Timestamp.fromDate(now),
        'totalXpEarned': (existing?.totalXpEarned ?? 0) + xpEarned,
      });

      // Award XP to main gamification document
      await GamificationService.instance.processEvent('personalbest', uid);

      // Check if daily checklist is complete → bonus XP
      final bonusXp = await _checkDailyChecklist(uid);
      return xpEarned + bonusXp;
    } catch (e) {
      debugPrint('Error logging personal best: $e');
      rethrow;
    }
  }

  /// Checks if all 6 core exercises logged today → awards checklist bonus once
  Future<int> _checkDailyChecklist(String uid) async {
    final allRecords = await getAllRecords(uid);
    final allLogged = CoreExercise.values.every((e) {
      final record = allRecords[e];
      return record != null && record.loggedToday;
    });

    if (!allLogged) return 0;

    // Guard against awarding twice — check checklist flag in gamification doc
    final gamDoc = await _gamificationRef(uid).doc(uid).get();
    final data = gamDoc.data() ?? {};
    final lastChecklist = data['lastChecklistBonus'] != null
        ? (data['lastChecklistBonus'] as Timestamp).toDate()
        : null;

    final today = DateTime.now();
    if (lastChecklist != null &&
        lastChecklist.year == today.year &&
        lastChecklist.month == today.month &&
        lastChecklist.day == today.day) {
      return 0; // already awarded today
    }

    await _gamificationRef(uid).doc(uid).set({
      'xp': FieldValue.increment(PersonalBestXP.dailyChecklist),
      'lastChecklistBonus': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return PersonalBestXP.dailyChecklist;
  }
}
