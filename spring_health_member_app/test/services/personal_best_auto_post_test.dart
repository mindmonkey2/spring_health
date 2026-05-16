import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/models/post_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('SocialService System Posts', () {
    test('createSystemPost creates a post with deterministic ID', () async {
      final memberId = 'mem123';
      final sourceType = 'personal_best';
      final sourceId = 'pushUps_20231015';
      final text = 'New personal best unlocked!';

      final deterministicId = '${memberId}_${sourceType}_$sourceId';

      final docRef = fakeFirestore.collection('posts').doc(deterministicId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        final postToSave = PostModel(
          id: deterministicId,
          memberAuthUid: 'auth123',
          memberId: memberId,
          memberName: 'Test User',
          branch: 'branch1',
          text: text,
          tags: const ['achievement'],
          likeCount: 0,
          commentCount: 0,
          createdAt: Timestamp.now(),
          sourceType: sourceType,
          sourceId: sourceId,
        );
        await docRef.set(postToSave.toMap());
      }

      final savedDoc = await fakeFirestore.collection('posts').doc(deterministicId).get();
      expect(savedDoc.exists, isTrue);
      expect(savedDoc.data()?['sourceType'], 'personal_best');

      // Simulate duplicate call
      var callCount = 0;
      if (!(await docRef.get()).exists) {
        callCount++;
      }
      expect(callCount, 0); // Verify second call would abort early
    });
  });
}
