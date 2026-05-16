import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/weekly_war_model.dart';
import 'gamification_service.dart';

class WeeklyWarService {
  static final WeeklyWarService instance = WeeklyWarService._internal();
  WeeklyWarService._internal() : _db = FirebaseFirestore.instance;

  @visibleForTesting
  WeeklyWarService.withFirestore(FirebaseFirestore firestore) : _db = firestore;

  final FirebaseFirestore _db;

  // 7-week rotating exercise schedule — cycles indefinitely
  static const List<Map<String, String>> warSchedule = [
    {
      'week': '1',
      'category': 'Upper Body',
      'exercise': 'Push-ups',
      'unit': 'reps',
    },
    {
      'week': '2',
      'category': 'Lower Body',
      'exercise': 'Squats',
      'unit': 'reps',
    },
    {'week': '3', 'category': 'Core', 'exercise': 'Plank', 'unit': 'seconds'},
    {
      'week': '4',
      'category': 'Full Body',
      'exercise': 'Burpees',
      'unit': 'reps',
    },
    {
      'week': '5',
      'category': 'Cardio',
      'exercise': 'High Knees',
      'unit': 'reps',
    },
    {
      'week': '6',
      'category': 'Gym Equip',
      'exercise': 'Deadlift',
      'unit': 'reps',
    },
    {
      'week': '7',
      'category': 'Upper Body',
      'exercise': 'Pull-ups',
      'unit': 'reps',
    },
  ];

  Future<WeeklyWarModel?> getActiveWar(String branch) async {
    final querySnapshot = await _db
    .collection('weeklywars')
    .where('branchId', isEqualTo: branch)
    .where('status', isEqualTo: 'active')
    .limit(1)
    .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return WeeklyWarModel.fromMap(doc.id, doc.data());
  }

  Future<void> recordWorkoutEntry(
    String memberId,
    String memberName,
    String branch,
    String exercise,
    int reps,
  ) async {
    final activeWar = await getActiveWar(branch);
    if (activeWar == null) return;

    if (activeWar.exercise.toLowerCase() != exercise.toLowerCase()) return;

    final entryRef = _db
    .collection('weeklywars')
    .doc(activeWar.id)
    .collection('entries')
    .doc(memberId);

    await entryRef.set({
      'memberId': memberId,
      'memberName': memberName,
      'totalReps': FieldValue.increment(reps),
      'sessionCount': FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<WarEntryModel>> getWarLeaderboard(String warId) {
    return _db
    .collection('weeklywars')
    .doc(warId)
    .collection('entries')
    .orderBy('totalReps', descending: true)
    .snapshots()
    .map(
      (snapshot) => snapshot.docs
      .map((doc) => WarEntryModel.fromMap(doc.id, doc.data()))
      .toList(),
    );
  }

  Future<WarEntryModel?> getMemberEntry(String warId, String memberId) async {
    final doc = await _db
    .collection('weeklywars')
    .doc(warId)
    .collection('entries')
    .doc(memberId)
    .get();

    if (!doc.exists || doc.data() == null) return null;

    return WarEntryModel.fromMap(doc.id, doc.data()!);
  }

  Future<List<WeeklyWarModel>> getWarHistory(String branch) async {
    final querySnapshot = await _db
    .collection('weeklywars')
    .where('branchId', isEqualTo: branch)
    .where('status', whereIn: ['completed', 'archived'])
    .orderBy('startDate', descending: true)
    .get();

    return querySnapshot.docs
    .map((doc) => WeeklyWarModel.fromMap(doc.id, doc.data()))
    .toList();
  }

  // NOTE: Weekly War auto-post hooks are blocked here because `completeWar`
  // execution and completion logic actually run inside the Studio (Admin) app.
  // Implementing a member-side duplicate hook would violate the app architecture
  // and risk duplication without a trusted admin-side trigger.
  // Future implementation should occur on the Studio side when triggered.

  Future<void> completeWar(String warId) async {
    final warRef = _db
    .collection('weeklywars')
    .doc(warId);

    // 1. Set status = 'locked'
    await warRef.update({'status': 'locked'});

    // 2. Read all entries, sort by totalReps desc
    final entriesSnapshot = await warRef
    .collection('entries')
    .orderBy('totalReps', descending: true)
    .get();

    final entries = entriesSnapshot.docs
    .map((doc) => WarEntryModel.fromMap(doc.id, doc.data()))
    .toList();

    if (entries.isEmpty) {
      await warRef.update({'status': 'completed'});
      return;
    }

    String? winnerId;
    String? winnerName;

    // Iterate through entries and assign ranks and XP
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final rank = i + 1;
      int xpToAward = 20; // Default participation XP
      String eventType = 'war_participate';
      int? customXP;

      if (rank == 1) {
        winnerId = entry.memberId;
        winnerName = entry.memberName;
        eventType = 'war_winner';
        // 5. Increment warWins by 1 in gamification/{memberId} for rank 1 only
        await _db
        .collection('gamification')
        .doc(entry.memberId)
        .set({'warWins': FieldValue.increment(1)}, SetOptions(merge: true));
      } else if (rank == 2) {
        eventType = 'war_top3';
        customXP = 300;
        xpToAward = 300;
      } else if (rank == 3) {
        eventType = 'war_top3';
        customXP = 150;
        xpToAward = 150;
      } else if (rank >= 4 && rank <= 10) {
        eventType = 'war_top3';
        customXP = 50;
        xpToAward = 50;
      }

      // 3. Assign ranks (rank field on each entry doc)
      await warRef.collection('entries').doc(entry.memberId).update({
        'rank': rank,
        'xpAwarded': xpToAward,
      });

      // 4. Distribute XP
      GamificationService.instance.processEvent(
        eventType,
        entry.memberId,
        customXP: customXP,
      );
    }

    // 6. Set status = 'completed', set winnerId and winnerName
    final updateData = <String, dynamic>{
      'status': 'completed',
    };
    if (winnerId != null) updateData['winnerId'] = winnerId;
    if (winnerName != null) updateData['winnerName'] = winnerName;
    await warRef.update(updateData);
  }
}
