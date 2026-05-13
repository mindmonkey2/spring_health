import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/models/like_model.dart';

void main() {
  group('LikeModel Tests', () {
    final timestamp = Timestamp(1672531200, 0);

    test('fromMap populates all fields correctly', () {
      final map = {
        'memberAuthUid': 'auth123',
        'createdAt': timestamp,
      };

      final model = LikeModel.fromMap(map, 'like123');

      expect(model.id, 'like123');
      expect(model.memberAuthUid, 'auth123');
      expect(model.createdAt, timestamp);
    });

    test('fromMap uses fallbacks on empty map', () {
      final map = <String, dynamic>{};

      final model = LikeModel.fromMap(map, 'like123');

      expect(model.id, 'like123');
      expect(model.memberAuthUid, '');
      expect(model.createdAt, isA<Timestamp>());
    });

    test('toMap round-trip produces identical field values', () {
      final map = {
        'memberAuthUid': 'auth123',
        'createdAt': timestamp,
      };

      final originalModel = LikeModel.fromMap(map, 'like123');
      final toMapResult = originalModel.toMap();
      final roundTripModel = LikeModel.fromMap(toMapResult, 'like123');

      expect(roundTripModel.id, originalModel.id);
      expect(roundTripModel.memberAuthUid, originalModel.memberAuthUid);
      expect(roundTripModel.createdAt, originalModel.createdAt);
    });

    test('id is NOT in toMap() output', () {
      final map = {
        'memberAuthUid': 'auth123',
        'createdAt': timestamp,
      };

      final model = LikeModel.fromMap(map, 'like123');
      final toMapResult = model.toMap();

      expect(toMapResult.containsKey('id'), isFalse);
    });
  });
}
