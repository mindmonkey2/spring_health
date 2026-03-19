import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/services/trainer_service.dart';
import 'package:spring_health_member/models/trainer_model.dart';

void main() {
  group('TrainerService.getMyTrainerStream', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TrainerService trainerService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      trainerService = TrainerService(db: fakeFirestore);
    });

    // ── HAPPY PATH ──────────────────────────────────────

    test('returns TrainerModel when member is assigned to a trainer', () async {
      await fakeFirestore.collection('trainers').doc('trainer1').set({
        'name': 'Ravi Kumar',
        'phone': '9876543210',
        'branch': 'hanamkonda',
        'assignedMembers': ['member_abc'],
        'specialization': 'Strength',
        'isActive': true,
      });

      final stream = trainerService.getMyTrainerStream('member_abc');
      final result = await stream.first;

      expect(result, isNotNull);
      expect(result, isA<TrainerModel>());
      expect(result!.name, equals('Ravi Kumar'));
      expect(result.id, equals('trainer1'));
    });

    test('returns only first trainer when multiple trainers match (limit: 1)',
        () async {
      await fakeFirestore.collection('trainers').doc('trainer1').set({
        'name': 'Ravi Kumar',
        'branch': 'hanamkonda',
        'assignedMembers': ['member_abc'],
        'isActive': true,
      });
      await fakeFirestore.collection('trainers').doc('trainer2').set({
        'name': 'Suresh Babu',
        'branch': 'warangal',
        'assignedMembers': ['member_abc'],
        'isActive': true,
      });

      final stream = trainerService.getMyTrainerStream('member_abc');
      final result = await stream.first;

      // limit(1) ensures only one result is returned — not null, not a list
      expect(result, isNotNull);
      expect(result, isA<TrainerModel>());
    });

    test('emits updated TrainerModel when Firestore document changes',
        () async {
      final docRef =
          fakeFirestore.collection('trainers').doc('trainer1');

      await docRef.set({
        'name': 'Ravi Kumar',
        'branch': 'hanamkonda',
        'assignedMembers': ['member_abc'],
        'isActive': true,
      });

      final stream = trainerService.getMyTrainerStream('member_abc');
      final first = await stream.first;
      expect(first!.name, equals('Ravi Kumar'));

      // Simulate trainer name update
      await docRef.update({'name': 'Ravi Kumar (Head Trainer)'});

      final second = await stream.first;
      expect(second!.name, equals('Ravi Kumar (Head Trainer)'));
    });

    // ── EDGE CASES ───────────────────────────────────────

    test('returns null when member has no assigned trainer', () async {
      // No trainers in Firestore at all
      final stream = trainerService.getMyTrainerStream('member_abc');
      final result = await stream.first;

      expect(result, isNull);
    });

    test('returns null when member is not in any assignedMembers array',
        () async {
      await fakeFirestore.collection('trainers').doc('trainer1').set({
        'name': 'Ravi Kumar',
        'branch': 'hanamkonda',
        'assignedMembers': ['member_xyz'],  // different member
        'isActive': true,
      });

      final stream = trainerService.getMyTrainerStream('member_abc');
      final result = await stream.first;

      expect(result, isNull);
    });

    test('returns null when memberId is an empty string', () async {
      await fakeFirestore.collection('trainers').doc('trainer1').set({
        'name': 'Ravi Kumar',
        'branch': 'hanamkonda',
        'assignedMembers': ['member_abc'],
        'isActive': true,
      });

      final stream = trainerService.getMyTrainerStream('');
      final result = await stream.first;

      // Empty string should not match any assignedMembers entry
      expect(result, isNull);
    });

    test('handles trainer document with missing optional fields gracefully',
        () async {
      // Minimal document — no specialization, no phone, no isActive
      await fakeFirestore.collection('trainers').doc('trainer1').set({
        'name': 'Ravi Kumar',
        'assignedMembers': ['member_abc'],
      });

      final stream = trainerService.getMyTrainerStream('member_abc');

      // Should NOT throw — fromMap must handle missing fields with nulls/defaults
      expect(() async => await stream.first, returnsNormally);

      final result = await stream.first;
      expect(result, isNotNull);
      expect(result!.name, equals('Ravi Kumar'));
    });

    test('returns null after member is removed from assignedMembers', () async {
      final docRef =
          fakeFirestore.collection('trainers').doc('trainer1');

      await docRef.set({
        'name': 'Ravi Kumar',
        'branch': 'hanamkonda',
        'assignedMembers': ['member_abc'],
        'isActive': true,
      });

      // Verify it shows trainer first
      final before = await trainerService.getMyTrainerStream('member_abc').first;
      expect(before, isNotNull);

      // Remove member from trainer's list
      await docRef.update({'assignedMembers': []});

      final after = await trainerService.getMyTrainerStream('member_abc').first;
      expect(after, isNull);
    });
  });
}
