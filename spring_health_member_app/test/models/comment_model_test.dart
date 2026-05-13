import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/models/comment_model.dart';

void main() {
  group('CommentModel Tests', () {
    final timestamp = Timestamp(1672531200, 0);

    test('fromMap populates all fields correctly', () {
      final map = {
        'memberAuthUid': 'auth123',
        'memberName': 'Jane Doe',
        'text': 'Great job!',
        'createdAt': timestamp,
      };

      final model = CommentModel.fromMap(map, 'comment123');

      expect(model.id, 'comment123');
      expect(model.memberAuthUid, 'auth123');
      expect(model.memberName, 'Jane Doe');
      expect(model.text, 'Great job!');
      expect(model.createdAt, timestamp);
    });

    test('fromMap uses fallbacks on empty map', () {
      final map = <String, dynamic>{};

      final model = CommentModel.fromMap(map, 'comment123');

      expect(model.id, 'comment123');
      expect(model.memberAuthUid, '');
      expect(model.memberName, '');
      expect(model.text, '');
      expect(model.createdAt, isA<Timestamp>());
    });

    test('toMap round-trip produces identical field values', () {
      final map = {
        'memberAuthUid': 'auth123',
        'memberName': 'Jane Doe',
        'text': 'Great job!',
        'createdAt': timestamp,
      };

      final originalModel = CommentModel.fromMap(map, 'comment123');
      final toMapResult = originalModel.toMap();
      final roundTripModel = CommentModel.fromMap(toMapResult, 'comment123');

      expect(roundTripModel.id, originalModel.id);
      expect(roundTripModel.memberAuthUid, originalModel.memberAuthUid);
      expect(roundTripModel.memberName, originalModel.memberName);
      expect(roundTripModel.text, originalModel.text);
      expect(roundTripModel.createdAt, originalModel.createdAt);
    });

    test('id is NOT in toMap() output', () {
      final map = {
        'memberAuthUid': 'auth123',
        'memberName': 'Jane Doe',
        'text': 'Great job!',
        'createdAt': timestamp,
      };

      final model = CommentModel.fromMap(map, 'comment123');
      final toMapResult = model.toMap();

      expect(toMapResult.containsKey('id'), isFalse);
    });
  });
}
