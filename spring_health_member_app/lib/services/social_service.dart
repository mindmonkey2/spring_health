import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/like_model.dart';
import 'gamification_service.dart';

class SocialService {
  static final SocialService _instance = SocialService._();
  factory SocialService() => _instance;
  SocialService._();
  static SocialService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createSystemPost({
    required String memberAuthUid,
    required String memberId,
    required String memberName,
    required String branch,
    required String text,
    required String sourceType,
    required String sourceId,
  }) async {
    try {
      // Deterministic ID logic
      final deterministicId = '${memberId}_${sourceType}_$sourceId';
      final docRef = _firestore.collection('posts').doc(deterministicId);

      // Duplicate prevention
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        return; // Already posted for this hook instance
      }

      final postToSave = PostModel(
        id: deterministicId,
        memberAuthUid: memberAuthUid,
        memberId: memberId,
        memberName: memberName,
        branch: branch,
        text: text,
        tags: const ['achievement'],
        likeCount: 0,
        commentCount: 0,
        createdAt: Timestamp.now(),
        sourceType: sourceType,
        sourceId: sourceId,
      );

      await docRef.set(postToSave.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createPost(PostModel post, {File? imageFile}) async {
    try {
      final docRef = _firestore.collection('posts').doc();
      String? uploadedPhotoUrl;

      if (imageFile != null) {
        final storageRef = _storage.ref().child('post_photos/${docRef.id}.jpg');
        final uploadTask = await storageRef.putFile(
          imageFile,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        uploadedPhotoUrl = await uploadTask.ref.getDownloadURL();
      }

      final postToSave = PostModel(
        id: post.id,
        memberAuthUid: post.memberAuthUid,
        memberId: post.memberId,
        memberName: post.memberName,
        photoUrl: uploadedPhotoUrl ?? post.photoUrl,
        branch: post.branch,
        text: post.text,
        mediaUrl: post.mediaUrl,
        tags: post.tags,
        likeCount: post.likeCount,
        commentCount: post.commentCount,
        createdAt: post.createdAt,
      );

      await docRef.set(postToSave.toMap());

      final querySnapshot = await _firestore
          .collection('posts')
          .where('memberAuthUid', isEqualTo: post.memberAuthUid)
          .limit(2)
          .get();

      if (querySnapshot.docs.length <= 1) {
        await GamificationService.instance.processEvent('first_post', post.memberId);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<PostModel>> streamFeedByBranch(String branch, {int limit = 20}) {
    return _firestore
        .collection('posts')
        .where('branch', isEqualTo: branch)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<PostModel>> streamGlobalFeed({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<PostModel>> streamMemberPosts(String memberId) {
    return _firestore
        .collection('posts')
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<DocumentSnapshot> getPostStream(String postId) {
    return _firestore.collection('posts').doc(postId).snapshots();
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  Stream<List<CommentModel>> streamComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addComment(String postId, CommentModel comment) async {
    try {
      final batch = _firestore.batch();

      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc();

      batch.set(commentRef, comment.toMap());

      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'commentCount': FieldValue.increment(1)
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final batch = _firestore.batch();

      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      batch.delete(commentRef);

      final postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'commentCount': FieldValue.increment(-1)
      });

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String memberAuthUid) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      final likeRef = postRef.collection('likes').doc(memberAuthUid);

      bool popularTriggered = false;
      String? postMemberId;

      await _firestore.runTransaction((transaction) async {
        final likeDoc = await transaction.get(likeRef);
        final postDoc = await transaction.get(postRef);

        if (likeDoc.exists) {
          transaction.delete(likeRef);
          transaction.update(postRef, {
            'likeCount': FieldValue.increment(-1)
          });
        } else {
          final likeModel = LikeModel(
            id: memberAuthUid,
            memberAuthUid: memberAuthUid,
            createdAt: Timestamp.now(),
          );

          transaction.set(likeRef, likeModel.toMap());
          transaction.update(postRef, {
            'likeCount': FieldValue.increment(1)
          });

          if (postDoc.exists) {
            final data = postDoc.data() ?? {};
            final currentLikeCount = data['likeCount'] as int? ?? 0;
            final popularXpAwarded = data['popularXpAwarded'] == true;

            if (currentLikeCount == 4 && !popularXpAwarded) {
              popularTriggered = true;
              postMemberId = data['memberId'] as String?;
              transaction.update(postRef, {'popularXpAwarded': true});
            }
          }
        }
      });

      if (popularTriggered && postMemberId != null) {
        await GamificationService.instance.processEvent('post_popular', postMemberId!);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isLikedBy(String postId, String memberAuthUid) async {
    try {
      final docSnap = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(memberAuthUid)
          .get();
      return docSnap.exists;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleLikeWithMemberId(String postId, String memberId) async {
    try {
      final ref = _firestore.collection('posts').doc(postId);
      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = snap.data() ?? {};
        final liked = List<String>.from(data['likedBy'] ?? []);
        if (liked.contains(memberId)) {
          liked.remove(memberId);
        } else {
          liked.add(memberId);
        }
        tx.update(ref, {
          'likedBy': liked,
          'likeCount': liked.length,
        });
      });
    } catch (e) {
      rethrow;
    }
  }
}
