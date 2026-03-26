import 'package:cloud_firestore/cloud_firestore.dart';

class AiWorkoutPlanModel {
  final List<AiDayPlanModel> weeklyPlan;
  final String? coachNote;
  final Timestamp generatedAt;
  final Map<String, dynamic> basedOn;
  final String status; // 'active' | 'medicalhold'
  final String? trainerNote;
  final Timestamp? trainerNoteUpdatedAt;

  AiWorkoutPlanModel({
    required this.weeklyPlan,
    this.coachNote,
    required this.generatedAt,
    required this.basedOn,
    required this.status,
    this.trainerNote,
    this.trainerNoteUpdatedAt,
  });

  factory AiWorkoutPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return AiWorkoutPlanModel(
      weeklyPlan: (map['weeklyPlan'] as List<dynamic>?)
              ?.map((e) => AiDayPlanModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      coachNote: map['coachNote'] as String?,
      generatedAt: map['generatedAt'] as Timestamp? ?? Timestamp.now(),
      basedOn: map['basedOn'] as Map<String, dynamic>? ?? {},
      status: map['status'] as String? ?? 'active',
      trainerNote: map['trainerNote'] as String?,
      trainerNoteUpdatedAt: map['trainerNoteUpdatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weeklyPlan': weeklyPlan.map((e) => e.toMap()).toList(),
      if (coachNote != null) 'coachNote': coachNote,
      'generatedAt': generatedAt,
      'basedOn': basedOn,
      'status': status,
      if (trainerNote != null) 'trainerNote': trainerNote,
      if (trainerNoteUpdatedAt != null) 'trainerNoteUpdatedAt': trainerNoteUpdatedAt,
    };
  }

  AiWorkoutPlanModel copyWith({
    List<AiDayPlanModel>? weeklyPlan,
    String? coachNote,
    Timestamp? generatedAt,
    Map<String, dynamic>? basedOn,
    String? status,
    String? trainerNote,
    Timestamp? trainerNoteUpdatedAt,
  }) {
    return AiWorkoutPlanModel(
      weeklyPlan: weeklyPlan ?? this.weeklyPlan,
      coachNote: coachNote ?? this.coachNote,
      generatedAt: generatedAt ?? this.generatedAt,
      basedOn: basedOn ?? this.basedOn,
      status: status ?? this.status,
      trainerNote: trainerNote ?? this.trainerNote,
      trainerNoteUpdatedAt: trainerNoteUpdatedAt ?? this.trainerNoteUpdatedAt,
    );
  }
}

class AiDayPlanModel {
  final String dayName;
  final List<Map<String, dynamic>> exercises;
  final bool isRestDay;

  AiDayPlanModel({
    required this.dayName,
    required this.exercises,
    required this.isRestDay,
  });

  factory AiDayPlanModel.fromMap(Map<String, dynamic> map) {
    return AiDayPlanModel(
      dayName: map['dayName'] as String? ?? '',
      exercises: (map['exercises'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      isRestDay: map['isRestDay'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayName': dayName,
      'exercises': exercises,
      'isRestDay': isRestDay,
    };
  }
}
