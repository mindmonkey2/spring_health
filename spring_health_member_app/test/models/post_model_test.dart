import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/models/post_model.dart';

void main() {
  group('PostModel Tests', () {
    final timestamp = Timestamp(1672531200, 0);

    test('fromMap populates all fields correctly', () {
      final map = {
        'memberAuthUid': 'auth123',
        'memberId': 'mem123',
        'memberName': 'John Doe',
        'photoUrl': 'http://example.com/photo.jpg',
        'branch': 'main',
        'text': 'Hello world!',
        'mediaUrl': 'http://example.com/media.jpg',
        'tags': ['war_result', 'pb'],
        'likeCount': 42,
        'commentCount': 7,
        'createdAt': timestamp,
      };

      final model = PostModel.fromMap(map, 'post123');

      expect(model.id, 'post123');
      expect(model.memberAuthUid, 'auth123');
      expect(model.memberId, 'mem123');
      expect(model.memberName, 'John Doe');
      expect(model.photoUrl, 'http://example.com/photo.jpg');
      expect(model.branch, 'main');
      expect(model.text, 'Hello world!');
      expect(model.mediaUrl, 'http://example.com/media.jpg');
      expect(model.tags, ['war_result', 'pb']);
      expect(model.likeCount, 42);
      expect(model.commentCount, 7);
      expect(model.createdAt, timestamp);
    });

    test('fromMap uses fallbacks on missing fields', () {
      final map = <String, dynamic>{};

      final model = PostModel.fromMap(map, 'post123');

      expect(model.id, 'post123');
      expect(model.memberAuthUid, '');
      expect(model.memberId, '');
      expect(model.memberName, '');
      expect(model.photoUrl, isNull);
      expect(model.branch, '');
      expect(model.text, '');
      expect(model.mediaUrl, isNull);
      expect(model.tags, isEmpty);
      expect(model.likeCount, 0);
      expect(model.commentCount, 0);
      expect(model.createdAt, isA<Timestamp>()); // Timestamp.now() is used
    });

    test('toMap round-trip produces identical field values', () {
      final map = {
        'memberAuthUid': 'auth123',
        'memberId': 'mem123',
        'memberName': 'John Doe',
        'photoUrl': 'http://example.com/photo.jpg',
        'branch': 'main',
        'text': 'Hello world!',
        'mediaUrl': 'http://example.com/media.jpg',
        'tags': ['war_result', 'pb'],
        'likeCount': 42,
        'commentCount': 7,
        'createdAt': timestamp,
      };

      final originalModel = PostModel.fromMap(map, 'post123');
      final toMapResult = originalModel.toMap();
      final roundTripModel = PostModel.fromMap(toMapResult, 'post123');

      expect(roundTripModel.id, originalModel.id);
      expect(roundTripModel.memberAuthUid, originalModel.memberAuthUid);
      expect(roundTripModel.memberId, originalModel.memberId);
      expect(roundTripModel.memberName, originalModel.memberName);
      expect(roundTripModel.photoUrl, originalModel.photoUrl);
      expect(roundTripModel.branch, originalModel.branch);
      expect(roundTripModel.text, originalModel.text);
      expect(roundTripModel.mediaUrl, originalModel.mediaUrl);
      expect(roundTripModel.tags, originalModel.tags);
      expect(roundTripModel.likeCount, originalModel.likeCount);
      expect(roundTripModel.commentCount, originalModel.commentCount);
      expect(roundTripModel.createdAt, originalModel.createdAt);

      // Verify id is not in toMap()
      expect(toMapResult.containsKey('id'), isFalse);
    });

    test('toMap includes null photoUrl and mediaUrl explicitly', () {
      final map = <String, dynamic>{
        'createdAt': timestamp,
      };

      final model = PostModel.fromMap(map, 'post123');
      final toMapResult = model.toMap();

      expect(toMapResult.containsKey('photoUrl'), isTrue);
      expect(toMapResult['photoUrl'], isNull);

      expect(toMapResult.containsKey('mediaUrl'), isTrue);
      expect(toMapResult['mediaUrl'], isNull);
    });

    test('tags round-trip preserves list elements correctly', () {
      final tags = ['war_result', 'pb'];
      final model = PostModel(
        id: 'post123',
        memberAuthUid: '',
        memberId: '',
        memberName: '',
        branch: '',
        text: '',
        tags: tags,
        likeCount: 0,
        commentCount: 0,
        createdAt: timestamp,
      );

      final toMapResult = model.toMap();
      final fromMapModel = PostModel.fromMap(toMapResult, 'post123');

      expect(fromMapModel.tags, tags);
    });
  });
}
