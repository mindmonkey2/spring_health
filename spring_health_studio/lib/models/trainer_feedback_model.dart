// lib/models/trainer_feedback_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerFeedbackModel {
  final String id;
  final String trainerId;
  final String memberId;
  final String memberName;
  final double rating;          // 1.0 – 5.0
  final String? comment;
  final String? trainerReply;
  final DateTime createdAt;

  const TrainerFeedbackModel({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.memberName,
    required this.rating,
    this.comment,
    this.trainerReply,
    required this.createdAt,
  });

  factory TrainerFeedbackModel.fromMap(Map<String, dynamic> data, String id) {
    return TrainerFeedbackModel(
      id: id,
      trainerId: data['trainerId'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String?,
      trainerReply: data['trainerReply'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'trainerId': trainerId,
    'memberId': memberId,
    'memberName': memberName,
    'rating': rating,
    if (comment != null) 'comment': comment,
    if (trainerReply != null) 'trainerReply': trainerReply,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  /// Average rating helper — used by detail screen
  static double averageRating(List<TrainerFeedbackModel> list) {
    if (list.isEmpty) return 0.0;
    return list.map((f) => f.rating).reduce((a, b) => a + b) / list.length;
  }
}
