import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String memberAuthUid;
  final String memberId;
  final String memberName;
  final String? photoUrl;
  final String branch;
  final String text;
  final String? mediaUrl;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final Timestamp createdAt;

  const PostModel({
    required this.id,
    required this.memberAuthUid,
    required this.memberId,
    required this.memberName,
    this.photoUrl,
    required this.branch,
    required this.text,
    this.mediaUrl,
    required this.tags,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  factory PostModel.fromMap(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      memberAuthUid: data['memberAuthUid'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      branch: data['branch'] as String? ?? '',
      text: data['text'] as String? ?? '',
      mediaUrl: data['mediaUrl'] as String?,
      tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberAuthUid': memberAuthUid,
      'memberId': memberId,
      'memberName': memberName,
      'photoUrl': photoUrl,
      'branch': branch,
      'text': text,
      'mediaUrl': mediaUrl,
      'tags': tags,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt,
    };
  }
}
