import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String memberId;
  final String memberAuthUid;
  final String trainerId;
  final String trainerUid;
  final String trainerName;
  final String branch;
  final DateTime date;
  // status values: 'created' | 'warmup' | 'planning' | 'active'
  //                | 'stretching' | 'complete' | 'cancelled'
  //                | 'medical_hold'
  final String status;
  final List<Map<String, dynamic>> warmup;
  final List<Map<String, dynamic>> exercises;
  final List<String> musclesWorked;
  final List<Map<String, dynamic>> stretching;
  final String aiSummary;
  final String nextSessionFocus;
  final bool dietPlanPushed;
  final bool attendanceMarked;
  final bool sessionXpAwarded;
  final DateTime createdAt;
  final DateTime? completedAt;

  SessionModel({
    required this.id,
    required this.memberId,
    required this.memberAuthUid,
    required this.trainerId,
    required this.trainerUid,
    required this.trainerName,
    required this.branch,
    required this.date,
    required this.status,
    required this.warmup,
    required this.exercises,
    required this.musclesWorked,
    required this.stretching,
    required this.aiSummary,
    required this.nextSessionFocus,
    required this.dietPlanPushed,
    required this.attendanceMarked,
    required this.sessionXpAwarded,
    required this.createdAt,
    this.completedAt,
  });

  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    return SessionModel(
      id: id,
      memberId: data['memberId'] ?? '',
      memberAuthUid: data['memberAuthUid'] ?? '',
      trainerId: data['trainerId'] ?? '',
      trainerUid: data['trainerUid'] ?? '',
      trainerName: data['trainerName'] ?? '',
      branch: data['branch'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'created',
      warmup: List<Map<String, dynamic>>.from(data['warmup'] ?? []),
      exercises: List<Map<String, dynamic>>.from(data['exercises'] ?? []),
      musclesWorked: List<String>.from(data['musclesWorked'] ?? []),
      stretching: List<Map<String, dynamic>>.from(data['stretching'] ?? []),
      aiSummary: data['aiSummary'] ?? '',
      nextSessionFocus: data['nextSessionFocus'] ?? '',
      dietPlanPushed: data['dietPlanPushed'] ?? false,
      attendanceMarked: data['attendanceMarked'] ?? false,
      sessionXpAwarded: data['sessionXpAwarded'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberAuthUid': memberAuthUid,
      'trainerId': trainerId,
      'trainerUid': trainerUid,
      'trainerName': trainerName,
      'branch': branch,
      'date': Timestamp.fromDate(date),
      'status': status,
      'warmup': warmup,
      'exercises': exercises,
      'musclesWorked': musclesWorked,
      'stretching': stretching,
      'aiSummary': aiSummary,
      'nextSessionFocus': nextSessionFocus,
      'dietPlanPushed': dietPlanPushed,
      'attendanceMarked': attendanceMarked,
      'sessionXpAwarded': sessionXpAwarded,
      'createdAt': Timestamp.fromDate(createdAt),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  SessionModel copyWith({
    String? id,
    String? memberId,
    String? memberAuthUid,
    String? trainerId,
    String? trainerUid,
    String? trainerName,
    String? branch,
    DateTime? date,
    String? status,
    List<Map<String, dynamic>>? warmup,
    List<Map<String, dynamic>>? exercises,
    List<String>? musclesWorked,
    List<Map<String, dynamic>>? stretching,
    String? aiSummary,
    String? nextSessionFocus,
    bool? dietPlanPushed,
    bool? attendanceMarked,
    bool? sessionXpAwarded,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberAuthUid: memberAuthUid ?? this.memberAuthUid,
      trainerId: trainerId ?? this.trainerId,
      trainerUid: trainerUid ?? this.trainerUid,
      trainerName: trainerName ?? this.trainerName,
      branch: branch ?? this.branch,
      date: date ?? this.date,
      status: status ?? this.status,
      warmup: warmup ?? this.warmup,
      exercises: exercises ?? this.exercises,
      musclesWorked: musclesWorked ?? this.musclesWorked,
      stretching: stretching ?? this.stretching,
      aiSummary: aiSummary ?? this.aiSummary,
      nextSessionFocus: nextSessionFocus ?? this.nextSessionFocus,
      dietPlanPushed: dietPlanPushed ?? this.dietPlanPushed,
      attendanceMarked: attendanceMarked ?? this.attendanceMarked,
      sessionXpAwarded: sessionXpAwarded ?? this.sessionXpAwarded,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
