import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/weekly_war_model.dart';
import 'gamification_service.dart';

class WeeklyWarService {
  static final WeeklyWarService instance = WeeklyWarService._internal();
  WeeklyWarService._internal();

  final _db = FirebaseFirestore.instance;
  final _gamService = GamificationService();

  Future<WeeklyWarModel?> getActiveWar(String branchId) async {
    try {
      final snapshot = await _db
          .collection('weekly_wars')
          .where('branchId', isEqualTo: branchId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return WeeklyWarModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      // debugPrint('Error getting active war: $e');
      return null;
    }
  }

  Future<void> recordWorkoutEntry(
      String memberId, String branchId, String exercise, int reps) async {
    final war = await getActiveWar(branchId);
    if (war == null || war.status != 'active') return;
    if (war.exercise.toLowerCase() != exercise.toLowerCase()) return;

    final entryRef = _db
        .collection('weekly_wars')
        .doc(war.id)
        .collection('entries')
        .doc(memberId);

    // Assuming we fetch member name somehow, or just pass it in? We only have memberId.
    // Let's rely on the DB having member info or we can omit name. Let's just update stats.
    await entryRef.set({
      'memberId': memberId,
      'totalReps': FieldValue.increment(reps),
      'sessionCount': FieldValue.increment(1),
      'lastUpdated': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Stream<List<WarEntryModel>> getWarLeaderboard(String warId) {
    return _db
        .collection('weekly_wars')
        .doc(warId)
        .collection('entries')
        .orderBy('totalReps', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WarEntryModel.fromFirestore(doc))
            .toList());
  }

  Future<void> completeWar(String warId) async {
    final warRef = _db.collection('weekly_wars').doc(warId);
    final entriesRef = warRef.collection('entries');

    try {
      final isLocked = await _db.runTransaction((transaction) async {
        final warDoc = await transaction.get(warRef);
        if (!warDoc.exists) return false;

        final war = WeeklyWarModel.fromFirestore(warDoc);
        if (war.status != 'active') return false;

        // 1. Lock status
        transaction.update(warRef, {'status': 'locked'});
        return true;
      });

      if (!isLocked) return;

      // 2. Read all entries, sort by totalReps desc
      final entriesSnapshot =
          await entriesRef.orderBy('totalReps', descending: true).get();
      final entries = entriesSnapshot.docs
          .map((doc) => WarEntryModel.fromFirestore(doc))
          .toList();

      if (entries.isEmpty) {
        await warRef.update({'status': 'completed'});
        return;
      }

      String? winnerId;
      String? winnerName;

      // 3. Assign ranks and 4. Distribute XP via processEvent calls
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final rank = i + 1;
        final docRef = entriesRef.doc(entry.memberId);

        if (rank == 1) {
          winnerId = entry.memberId;
          winnerName = entry.memberName;
          await _gamService.processEvent('war_winner', entry.memberId);
          await _db.collection('gamification').doc(entry.memberId).update({
            'warWins': FieldValue.increment(1)
          });
        } else if (rank <= 3) {
          await _gamService.processEvent('war_top3', entry.memberId,
              customXP: rank == 2 ? 300 : 150);
        } else if (rank <= 10) {
          await _gamService.processEvent('war_top3', entry.memberId,
              customXP: 50);
        } else {
          await _gamService.processEvent('war_participate', entry.memberId);
        }

        await docRef.update({'rank': rank});
      }

      // 5. Set status: 'completed', winnerId, winnerName
      await warRef.update({
        'status': 'completed',
        'winnerId': winnerId,
        'winnerName': winnerName,
      });

      // 6. Send FCM to all branch members: war result announcement
      // This part would typically use a Cloud Function or FCM service.
      // Assuming a notification service exists, or just log for now.
      // debugPrint('War $warId completed. Winner: $winnerName');
    } catch (e) {
      // debugPrint('Error completing war: $e');
      // Rollback status on fail, but only if we were the ones who locked it
      try {
        final doc = await warRef.get();
        if (doc.exists && doc.data()?['status'] == 'locked') {
          await warRef.update({'status': 'active'});
        }
      } catch (_) {}
    }
  }

  // Helper method for WarScreen to fetch historical wars
  Future<List<WeeklyWarModel>> getPastWars(String branchId) async {
    try {
      final snapshot = await _db
          .collection('weekly_wars')
          .where('branchId', isEqualTo: branchId)
          .where('status', isEqualTo: 'completed')
          .orderBy('endDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WeeklyWarModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // debugPrint('Error getting past wars: $e');
      return [];
    }
  }

  // Get member's rank in a specific war
  Future<WarEntryModel?> getMemberWarEntry(String warId, String memberId) async {
    try {
      final doc = await _db
          .collection('weekly_wars')
          .doc(warId)
          .collection('entries')
          .doc(memberId)
          .get();
      if (!doc.exists) return null;
      return WarEntryModel.fromFirestore(doc);
    } catch (e) {
      // debugPrint('Error getting member war entry: $e');
      return null;
    }
  }
}
