import 'package:cloud_firestore/cloud_firestore.dart';

class LikeModel {
  final String id;
  final String memberAuthUid;
  final Timestamp createdAt;

  const LikeModel({
    required this.id,
    required this.memberAuthUid,
    required this.createdAt,
  });

  factory LikeModel.fromMap(Map<String, dynamic> data, String id) {
    return LikeModel(
      id: id,
      memberAuthUid: data['memberAuthUid'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberAuthUid': memberAuthUid,
      'createdAt': createdAt,
    };
  }
}
