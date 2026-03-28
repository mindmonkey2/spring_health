import 'package:cloud_firestore/cloud_firestore.dart';

class MemberGoalModel {
  final String id;
  final String authUid;
  final String goalType; // weight_loss, muscle_gain, strength, endurance, flexibility, general_fitness
  final String? targetMetric; // current_weight, target_weight, height_cm, current_max, target_max, target_distance
  final String? targetUnit; // kg, km, miles
  final String? liftType; // Bench Press, Squat, Deadlift, etc.
  final double? currentValue;
  final double? targetValue;
  final double? heightCm;
  final DateTime deadline;
  final int sessionsPerWeek;
  final List<double> milestones;
  final String createdBy; // member, trainer
  final DateTime createdAt;

  MemberGoalModel({
    required this.id,
    required this.authUid,
    required this.goalType,
    this.targetMetric,
    this.targetUnit,
    this.liftType,
    this.currentValue,
    this.targetValue,
    this.heightCm,
    required this.deadline,
    required this.sessionsPerWeek,
    required this.milestones,
    required this.createdBy,
    required this.createdAt,
  });

  factory MemberGoalModel.fromMap(Map<String, dynamic> data, String id) {
    return MemberGoalModel(
      id: id,
      authUid: data['authUid'] ?? '',
      goalType: data['goalType'] ?? 'general_fitness',
      targetMetric: data['targetMetric'],
      targetUnit: data['targetUnit'],
      liftType: data['liftType'],
      currentValue: (data['currentValue'] as num?)?.toDouble(),
      targetValue: (data['targetValue'] as num?)?.toDouble(),
      heightCm: (data['heightCm'] as num?)?.toDouble(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : DateTime.now(),
      sessionsPerWeek: data['sessionsPerWeek'] ?? 3,
      milestones: (data['milestones'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      createdBy: data['createdBy'] ?? 'member',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authUid': authUid,
      'goalType': goalType,
      'targetMetric': targetMetric,
      'targetUnit': targetUnit,
      'liftType': liftType,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'heightCm': heightCm,
      'deadline': Timestamp.fromDate(deadline),
      'sessionsPerWeek': sessionsPerWeek,
      'milestones': milestones,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
