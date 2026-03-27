import 'package:cloud_firestore/cloud_firestore.dart';

class MemberGoalModel {
  final String id;
  final String primaryGoal;
  final Map<String, dynamic> targetMetric;
  final double? heightCm;
  final DateTime deadline;
  final List<Map<String, dynamic>> milestones;
  final String currentPace;
  final String createdBy;

  MemberGoalModel({
    required this.id,
    required this.primaryGoal,
    required this.targetMetric,
    this.heightCm,
    required this.deadline,
    required this.milestones,
    required this.currentPace,
    required this.createdBy,
  });

  factory MemberGoalModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberGoalModel(
      id: id,
      primaryGoal: map['primaryGoal'] as String? ?? '',
      targetMetric: Map<String, dynamic>.from(map['targetMetric'] ?? {}),
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      deadline: map['deadline'] != null
          ? (map['deadline'] as Timestamp).toDate()
          : DateTime.now(),
      milestones: List<Map<String, dynamic>>.from(map['milestones'] ?? []),
      currentPace: map['currentPace'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryGoal': primaryGoal,
      'targetMetric': targetMetric,
      'heightCm': heightCm,
      'deadline': Timestamp.fromDate(deadline),
      'milestones': milestones,
      'currentPace': currentPace,
      'createdBy': createdBy,
    };
  }
}
