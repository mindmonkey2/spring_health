class TrainingSessionModel {
  final String sessionId;
  final String trainerId;
  final String memberId;
  final String memberAuthUid;
  final String status;
  final int readinessScore;
  final List<Map<String, dynamic>> exercises;
  final Map<String, dynamic> plans;

  TrainingSessionModel({
    required this.sessionId,
    required this.trainerId,
    required this.memberId,
    required this.memberAuthUid,
    required this.status,
    required this.readinessScore,
    required this.exercises,
    required this.plans,
  });

  factory TrainingSessionModel.fromMap(Map<String, dynamic> map, String id) {
    return TrainingSessionModel(
      sessionId: map['sessionId'] as String? ?? id,
      trainerId: map['trainerId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      memberAuthUid: map['memberAuthUid'] as String? ?? '',
      status: map['status'] as String? ?? '',
      readinessScore: map['readinessScore'] as int? ?? 0,
      exercises: List<Map<String, dynamic>>.from(map['exercises'] ?? []),
      plans: Map<String, dynamic>.from(map['plans'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'trainerId': trainerId,
      'memberId': memberId,
      'memberAuthUid': memberAuthUid,
      'status': status,
      'readinessScore': readinessScore,
      'exercises': exercises,
      'plans': plans,
    };
  }
}
