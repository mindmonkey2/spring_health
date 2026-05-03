import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/services/weekly_war_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late WeeklyWarService service;

  const branch = 'main-branch';
  const warId = 'war-001';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = WeeklyWarService.withFirestore(fakeFirestore);
  });

  Future<void> seedActiveWar({
    String id = warId,
    String exercise = 'Push-ups',
  }) async {
    await fakeFirestore.collection('weeklywars').doc(id).set({
      'branchId': branch,
      'status': 'active',
      'exercise': exercise,
      'category': 'Upper Body',
      'unit': 'reps',
      'startDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
      'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
    });
  }

  group('WeeklyWarService.getActiveWar', () {
    test('returns model when active war exists for branch', () async {
      await seedActiveWar();
      final war = await service.getActiveWar(branch);
      expect(war, isNotNull);
      expect(war!.id, warId);
      expect(war.exercise, 'Push-ups');
    });

    test('returns null when no active war for branch', () async {
      final war = await service.getActiveWar(branch);
      expect(war, isNull);
    });

    test('returns null when active war is for a different branch', () async {
      await seedActiveWar();
      final war = await service.getActiveWar('other-branch');
      expect(war, isNull);
    });

    test('returns null when only completed wars exist', () async {
      await fakeFirestore.collection('weeklywars').doc('war-done').set({
        'branchId': branch,
        'status': 'completed',
        'exercise': 'Squats',
        'category': 'Lower Body',
        'unit': 'reps',
        'startDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 10))),
        'endDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3))),
      });
      final war = await service.getActiveWar(branch);
      expect(war, isNull);
    });
  });

  group('WeeklyWarService.recordWorkoutEntry', () {
    test('creates entry when one does not exist', () async {
      await seedActiveWar(exercise: 'Push-ups');
      await service.recordWorkoutEntry('member-1', 'Alice', branch, 'Push-ups', 20);

      final doc = await fakeFirestore
          .collection('weeklywars')
          .doc(warId)
          .collection('entries')
          .doc('member-1')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['memberId'], 'member-1');
      expect(doc.data()!['memberName'], 'Alice');
    });

    test('does nothing when no active war exists', () async {
      await service.recordWorkoutEntry('member-1', 'Alice', branch, 'Push-ups', 20);

      final snap = await fakeFirestore
          .collectionGroup('entries')
          .get();
      expect(snap.docs, isEmpty);
    });

    test('does nothing when exercise does not match the active war', () async {
      await seedActiveWar(exercise: 'Push-ups');
      await service.recordWorkoutEntry('member-1', 'Alice', branch, 'Squats', 30);

      final snap = await fakeFirestore
          .collection('weeklywars')
          .doc(warId)
          .collection('entries')
          .get();
      expect(snap.docs, isEmpty);
    });

    test('exercise match is case-insensitive', () async {
      await seedActiveWar(exercise: 'Push-ups');
      await service.recordWorkoutEntry('member-1', 'Alice', branch, 'push-ups', 10);

      final doc = await fakeFirestore
          .collection('weeklywars')
          .doc(warId)
          .collection('entries')
          .doc('member-1')
          .get();
      expect(doc.exists, isTrue);
    });
  });

  group('WeeklyWarService.getMemberEntry', () {
    test('returns entry when it exists', () async {
      await fakeFirestore
          .collection('weeklywars')
          .doc(warId)
          .collection('entries')
          .doc('member-1')
          .set({'memberId': 'member-1', 'memberName': 'Alice', 'totalReps': 50, 'sessionCount': 2, 'lastUpdated': Timestamp.now()});

      final entry = await service.getMemberEntry(warId, 'member-1');
      expect(entry, isNotNull);
      expect(entry!.memberId, 'member-1');
      expect(entry.totalReps, 50);
    });

    test('returns null when entry does not exist', () async {
      final entry = await service.getMemberEntry(warId, 'nonexistent');
      expect(entry, isNull);
    });
  });

  group('WeeklyWarService.getWarLeaderboard', () {
    test('emits entries ordered by totalReps descending', () async {
      final entriesRef = fakeFirestore
          .collection('weeklywars')
          .doc(warId)
          .collection('entries');
      final ts = Timestamp.now();
      await entriesRef.doc('m1').set({'memberId': 'm1', 'memberName': 'Alice', 'totalReps': 100, 'sessionCount': 3, 'lastUpdated': ts});
      await entriesRef.doc('m2').set({'memberId': 'm2', 'memberName': 'Bob', 'totalReps': 200, 'sessionCount': 5, 'lastUpdated': ts});
      await entriesRef.doc('m3').set({'memberId': 'm3', 'memberName': 'Carol', 'totalReps': 50, 'sessionCount': 1, 'lastUpdated': ts});

      final entries = await service.getWarLeaderboard(warId).first;
      expect(entries.length, 3);
      expect(entries.first.totalReps, 200);
      expect(entries.last.totalReps, 50);
    });

    test('emits empty list when no entries exist', () async {
      final entries = await service.getWarLeaderboard(warId).first;
      expect(entries, isEmpty);
    });
  });

  group('WeeklyWarService.getWarHistory', () {
    test('returns completed and archived wars for the branch', () async {
      for (final status in ['completed', 'archived']) {
        await fakeFirestore.collection('weeklywars').add({
          'branchId': branch,
          'status': status,
          'exercise': 'Squats',
          'category': 'Lower Body',
          'unit': 'reps',
          'startDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 14))),
          'endDate': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
        });
      }
      final history = await service.getWarHistory(branch);
      expect(history.length, 2);
    });

    test('excludes active wars from history', () async {
      await seedActiveWar();
      final history = await service.getWarHistory(branch);
      expect(history, isEmpty);
    });

    test('returns empty list when no history exists', () async {
      final history = await service.getWarHistory(branch);
      expect(history, isEmpty);
    });
  });

  group('WeeklyWarService.warSchedule', () {
    test('contains exactly 7 entries', () {
      expect(WeeklyWarService.warSchedule.length, 7);
    });

    test('every entry has required keys', () {
      for (final week in WeeklyWarService.warSchedule) {
        expect(week.containsKey('week'), isTrue);
        expect(week.containsKey('category'), isTrue);
        expect(week.containsKey('exercise'), isTrue);
        expect(week.containsKey('unit'), isTrue);
      }
    });

    test('week numbers are 1 through 7', () {
      final weeks = WeeklyWarService.warSchedule.map((w) => w['week']).toList();
      expect(weeks, containsAll(['1', '2', '3', '4', '5', '6', '7']));
    });
  });
}
