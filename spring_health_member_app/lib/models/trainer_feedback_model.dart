
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerFeedbackModel {
  final String id;
  final String memberId;
  final String memberName;
  final String memberPhone;
  final String workoutType;
  final String message;
  final int rating; // 1–5
  final DateTime createdAt;

  const TrainerFeedbackModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberPhone,
    required this.workoutType,
    required this.message,
    required this.rating,
    required this.createdAt,
  });

  factory TrainerFeedbackModel.fromMap(
    Map<String, dynamic> map, String docId) {
    return TrainerFeedbackModel(
      id: docId,
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? '',
      memberPhone: map['memberPhone'] as String? ?? '',
      workoutType: map['workoutType'] as String? ?? '',
      message: map['message'] as String? ?? '',
      rating: (map['rating'] as num?)?.toInt() ?? 3,
      createdAt: map['createdAt'] is Timestamp
      ? (map['createdAt'] as Timestamp).toDate()
      : DateTime.now(),
    );
    }

    Map<String, dynamic> toMap() => {
      'memberId': memberId,
      'memberName': memberName,
      'memberPhone': memberPhone,
      'workoutType': workoutType,
      'message': message,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
}
