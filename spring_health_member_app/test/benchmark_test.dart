import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Benchmark N+1 vs Batched WeeklyWarService.recordWorkoutEntries pure functions',
    () async {
      final db = FakeFirebaseFirestore();

      // Create active war
      await db.collection('weekly_wars').doc('war1').set({
        'branchId': 'branch1',
        'status': 'active',
        'exercise': 'Push Ups',
      });

      final memberId = 'member1';
      final branchId = 'branch1';
      final exerciseName = 'Push Ups';

      // Simulate what the loop would do
      Map<String, int> exerciseReps = {};
      for (int i = 0; i < 50; i++) {
        exerciseReps.update(
          exerciseName,
          (val) => val + 10,
          ifAbsent: () => 10,
        );
      }

      // N+1 implementation inline
      Future<void> recordWorkoutEntry(
        String memberId,
        String branchId,
        String exercise,
        int reps,
      ) async {
        final snapshot = await db
            .collection('weekly_wars')
            .where('branchId', isEqualTo: branchId)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) return;
        final warId = snapshot.docs.first.id;
        final warExercise = snapshot.docs.first.data()['exercise'] as String;

        if (warExercise.toLowerCase() != exercise.toLowerCase()) return;

        final entryRef = db
            .collection('weekly_wars')
            .doc(warId)
            .collection('entries')
            .doc(memberId);
        await entryRef.set({
          'memberId': memberId,
          'totalReps': FieldValue.increment(reps),
          'sessionCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      // Batched implementation inline
      Future<void> recordWorkoutEntries(
        String memberId,
        String branchId,
        Map<String, int> exerciseReps,
      ) async {
        if (exerciseReps.isEmpty) return;

        final snapshot = await db
            .collection('weekly_wars')
            .where('branchId', isEqualTo: branchId)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) return;
        final warId = snapshot.docs.first.id;
        final warExercise = snapshot.docs.first.data()['exercise'] as String;

        final warExerciseLower = warExercise.toLowerCase();
        int totalWarReps = 0;
        for (final entry in exerciseReps.entries) {
          if (entry.key.toLowerCase() == warExerciseLower) {
            totalWarReps += entry.value;
          }
        }

        if (totalWarReps == 0) return;

        final entryRef = db
            .collection('weekly_wars')
            .doc(warId)
            .collection('entries')
            .doc(memberId);
        await entryRef.set({
          'memberId': memberId,
          'totalReps': FieldValue.increment(totalWarReps),
          'sessionCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      // 1. N+1 version
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 50; i++) {
        await recordWorkoutEntry(memberId, branchId, exerciseName, 10);
      }
      stopwatch.stop();
      final nPlus1Time = stopwatch.elapsedMilliseconds;

      // Check reps
      final doc1 = await db
          .collection('weekly_wars')
          .doc('war1')
          .collection('entries')
          .doc(memberId)
          .get();
      final nReps = doc1.data()?['totalReps'];
      debugPrint('N+1 reps: $nReps');

      // Reset total reps
      await db
          .collection('weekly_wars')
          .doc('war1')
          .collection('entries')
          .doc(memberId)
          .delete();

      // 2. Batched version
      final stopwatchBatched = Stopwatch()..start();
      await recordWorkoutEntries(memberId, branchId, exerciseReps);
      stopwatchBatched.stop();
      final batchedTime = stopwatchBatched.elapsedMilliseconds;

      final doc2 = await db
          .collection('weekly_wars')
          .doc('war1')
          .collection('entries')
          .doc(memberId)
          .get();
      final bReps = doc2.data()?['totalReps'];
      debugPrint('Batched reps: $bReps');

      debugPrint('N+1 time: ${nPlus1Time}ms');
      debugPrint('Batched time: ${batchedTime}ms');

      expect(batchedTime < nPlus1Time, isTrue);
    },
  );
}
