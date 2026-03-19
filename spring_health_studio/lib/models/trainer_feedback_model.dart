import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerFeedbackModel {
  final String id;
  final String trainerId;    // TRN001
  final String memberId;     // Member Firestore doc ID
  final String memberName;
  final double rating;       // 1.0 – 5.0
  final String? comment;
  final String? trainerReply;
  final DateTime createdAt;
  final DateTime? repliedAt;

  const TrainerFeedbackModel({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.memberName,
    required this.rating,
    this.comment,
    this.trainerReply,
    required this.createdAt,
    this.repliedAt,
  });

  factory TrainerFeedbackModel.fromMap(Map<String, dynamic> map, String id) {
    return TrainerFeedbackModel(
      id: id,
      trainerId: map['trainerId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberName: map['memberName'] as String? ?? 'Unknown',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] as String?,
      trainerReply: map['trainerReply'] as String?,
      createdAt: map['createdAt'] != null
      ? (map['createdAt'] as Timestamp).toDate()
      : DateTime.now(),
      repliedAt: map['repliedAt'] != null
      ? (map['repliedAt'] as Timestamp).toDate()
      : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'trainerId': trainerId,
    'memberId': memberId,
    'memberName': memberName,
    'rating': rating,
    'comment': comment,
    'trainerReply': trainerReply,
    'createdAt': Timestamp.fromDate(createdAt),
    'repliedAt': repliedAt != null ? Timestamp.fromDate(repliedAt!) : null,
  };

  bool get hasReply => trainerReply != null && trainerReply!.isNotEmpty;

  String get ratingLabel {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Good';
    if (rating >= 2.5) return 'Average';
    return 'Needs Improvement';
  }
}
