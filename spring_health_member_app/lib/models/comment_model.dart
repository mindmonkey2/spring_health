import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String memberAuthUid;
  final String memberName;
  final String text;
  final Timestamp createdAt;

  const CommentModel({
    required this.id,
    required this.memberAuthUid,
    required this.memberName,
    required this.text,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data, String id) {
    return CommentModel(
      id: id,
      memberAuthUid: data['memberAuthUid'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberAuthUid': memberAuthUid,
      'memberName': memberName,
      'text': text,
      'createdAt': createdAt,
    };
  }
}
