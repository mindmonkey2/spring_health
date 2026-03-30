import 'package:cloud_firestore/cloud_firestore.dart';

class MemberGoalModel {
  final String id;
  final String primaryGoal;
  final Map<String, dynamic>? targetMetric;
  final double? heightCm;
  final Timestamp deadline;
  final Timestamp startDate;
  final int weeklySessionTarget;
  final List<Map<String, dynamic>> milestones;
  final String? currentPace;
  final Timestamp? lastPaceCheck;
  final String createdBy;
  final Timestamp updatedAt;

  MemberGoalModel({
    required this.id,
    required this.primaryGoal,
    this.targetMetric,
    this.heightCm,
    required this.deadline,
    required this.startDate,
    required this.weeklySessionTarget,
    required this.milestones,
    this.currentPace,
    this.lastPaceCheck,
    required this.createdBy,
    required this.updatedAt,
  });

  factory MemberGoalModel.fromMap(Map<String, dynamic> data, String id) {
    return MemberGoalModel(
      id: id,
      primaryGoal: data['primaryGoal'] ?? '',
      targetMetric: data['targetMetric'] != null
          ? Map<String, dynamic>.from(data['targetMetric'] as Map)
          : null,
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      deadline: data['deadline'] as Timestamp? ?? Timestamp.now(),
      startDate: data['startDate'] as Timestamp? ?? Timestamp.now(),
      weeklySessionTarget: data['weeklySessionTarget'] as int? ?? 0,
      milestones: data['milestones'] != null
          ? List<Map<String, dynamic>>.from(
              (data['milestones'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
          : [],
      currentPace: data['currentPace'] as String?,
      lastPaceCheck: data['lastPaceCheck'] as Timestamp?,
      createdBy: data['createdBy'] ?? 'member',
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primaryGoal': primaryGoal,
      if (targetMetric != null) 'targetMetric': targetMetric,
      if (heightCm != null) 'heightCm': heightCm,
      'deadline': deadline,
      'startDate': startDate,
      'weeklySessionTarget': weeklySessionTarget,
      'milestones': milestones,
      if (currentPace != null) 'currentPace': currentPace,
      if (lastPaceCheck != null) 'lastPaceCheck': lastPaceCheck,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
    };
  }

  MemberGoalModel copyWith({
    String? primaryGoal,
    Map<String, dynamic>? targetMetric,
    double? heightCm,
    Timestamp? deadline,
    Timestamp? startDate,
    int? weeklySessionTarget,
    List<Map<String, dynamic>>? milestones,
    String? currentPace,
    Timestamp? lastPaceCheck,
    String? createdBy,
    Timestamp? updatedAt,
  }) {
    return MemberGoalModel(
      id: id,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      targetMetric: targetMetric ?? this.targetMetric,
      heightCm: heightCm ?? this.heightCm,
      deadline: deadline ?? this.deadline,
      startDate: startDate ?? this.startDate,
      weeklySessionTarget: weeklySessionTarget ?? this.weeklySessionTarget,
      milestones: milestones ?? this.milestones,
      currentPace: currentPace ?? this.currentPace,
      lastPaceCheck: lastPaceCheck ?? this.lastPaceCheck,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
