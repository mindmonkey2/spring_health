import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/models/body_metrics_model.dart';
import 'package:spring_health_member/services/body_metrics_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BodyMetricsService service;
  const memberId = 'test_member_123';
  const otherMemberId = 'other_member_456';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = BodyMetricsService(firestore: fakeFirestore);
  });

  group('BodyMetricsService.getMetricsStream', () {
    test('returns only metrics for the specified memberId', () async {
      // Add metrics for multiple members
      await fakeFirestore.collection('bodyMetrics').add({
        'memberId': memberId,
        'weight': 70.0,
        'recordedAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });
      await fakeFirestore.collection('bodyMetrics').add({
        'memberId': otherMemberId,
        'weight': 80.0,
        'recordedAt': Timestamp.fromDate(DateTime(2023, 1, 2)),
      });

      final stream = service.getMetricsStream(memberId);
      final list = await stream.first;

      expect(list.length, 1);
      expect(list.first.memberId, memberId);
      expect(list.first.weight, 70.0);
    });

    test('returns metrics in descending order of recordedAt', () async {
      final date1 = DateTime(2023, 1, 1);
      final date2 = DateTime(2023, 1, 2);
      final date3 = DateTime(2023, 1, 3);

      await fakeFirestore.collection('bodyMetrics').add({
        'memberId': memberId,
        'weight': 70.0,
        'recordedAt': Timestamp.fromDate(date1),
      });
      await fakeFirestore.collection('bodyMetrics').add({
        'memberId': memberId,
        'weight': 71.0,
        'recordedAt': Timestamp.fromDate(date3), // newest
      });
      await fakeFirestore.collection('bodyMetrics').add({
        'memberId': memberId,
        'weight': 70.5,
        'recordedAt': Timestamp.fromDate(date2),
      });

      final stream = service.getMetricsStream(memberId);
      final list = await stream.first;

      expect(list.length, 3);
      expect(list[0].recordedAt, date3);
      expect(list[1].recordedAt, date2);
      expect(list[2].recordedAt, date1);
    });

    test('respects the limit of 30 entries', () async {
      for (int i = 0; i < 40; i++) {
        await fakeFirestore.collection('bodyMetrics').add({
          'memberId': memberId,
          'weight': 60.0 + i,
          'recordedAt': Timestamp.fromDate(DateTime(2023, 1, i + 1)),
        });
      }

      final stream = service.getMetricsStream(memberId);
      final list = await stream.first;

      expect(list.length, 30);
      // Since it's descending, the first one should be the 40th added (index 39)
      expect(list.first.recordedAt, DateTime(2023, 1, 40));
    });

    test('correctly maps Firestore data to BodyMetricsModel', () async {
      final recordedAt = DateTime(2023, 5, 20, 10, 30);
      final docRef = await fakeFirestore.collection('bodyMetrics').add({
        'memberId': memberId,
        'weight': 75.5,
        'height': 180.0,
        'bodyFat': 15.2,
        'chest': 100.0,
        'waist': 85.0,
        'hips': 95.0,
        'arms': 35.0,
        'thighs': 55.0,
        'notes': 'Feeling great',
        'recordedAt': Timestamp.fromDate(recordedAt),
      });

      final stream = service.getMetricsStream(memberId);
      final list = await stream.first;

      expect(list.length, 1);
      final model = list.first;
      expect(model.id, docRef.id);
      expect(model.memberId, memberId);
      expect(model.weight, 75.5);
      expect(model.height, 180.0);
      expect(model.bodyFat, 15.2);
      expect(model.chest, 100.0);
      expect(model.waist, 85.0);
      expect(model.hips, 95.0);
      expect(model.arms, 35.0);
      expect(model.thighs, 55.0);
      expect(model.notes, 'Feeling great');
      expect(model.recordedAt, recordedAt);
    });

    test('returns empty list when no metrics found for member', () async {
      await fakeFirestore.collection('bodyMetrics').add({
        'memberId': otherMemberId,
        'weight': 80.0,
        'recordedAt': Timestamp.fromDate(DateTime.now()),
      });

      final stream = service.getMetricsStream(memberId);
      final list = await stream.first;

      expect(list, isEmpty);
    });
  });
}
