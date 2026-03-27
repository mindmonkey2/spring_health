import 'package:cloud_firestore/cloud_firestore.dart';

class AiWorkoutPlanModel {
  final String id;
  final String memberId;
  final List<Map<String, dynamic>> weeklyPlan;
  final String weeklyFocus;
  final String coachNote;
  final String? bpNote;
  final String? recoveryNote;
  final String status;
  final Timestamp generatedAt;
  final Map<String, dynamic> basedOn;
  final String? trainerNote;
  final Timestamp? trainerNoteUpdatedAt;

  const AiWorkoutPlanModel({
    required this.id,
    required this.memberId,
    required this.weeklyPlan,
    required this.weeklyFocus,
    required this.coachNote,
    this.bpNote,
    this.recoveryNote,
    required this.status,
    required this.generatedAt,
    required this.basedOn,
    this.trainerNote,
    this.trainerNoteUpdatedAt,
  });

  factory AiWorkoutPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return AiWorkoutPlanModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      weeklyPlan: List<Map<String, dynamic>>.from(map['weeklyPlan'] ?? []),
      weeklyFocus: map['weeklyFocus'] as String? ?? '',
      coachNote: map['coachNote'] as String? ?? '',
      bpNote: map['bpNote'] as String?,
      recoveryNote: map['recoveryNote'] as String?,
      status: map['status'] as String? ?? 'active',
      generatedAt: map['generatedAt'] as Timestamp? ?? Timestamp.now(),
      basedOn: Map<String, dynamic>.from(map['basedOn'] ?? {}),
      trainerNote: map['trainerNote'] as String?,
      trainerNoteUpdatedAt: map['trainerNoteUpdatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'weeklyPlan': weeklyPlan,
    'weeklyFocus': weeklyFocus,
    'coachNote': coachNote,
    'bpNote': bpNote,
    'recoveryNote': recoveryNote,
    'status': status,
    'generatedAt': generatedAt,
    'basedOn': basedOn,
    'trainerNote': trainerNote,
    'trainerNoteUpdatedAt': trainerNoteUpdatedAt,
  };

  AiWorkoutPlanModel copyWith({
    String? id, String? memberId,
    List<Map<String, dynamic>>? weeklyPlan,
    String? weeklyFocus, String? coachNote,
    String? bpNote, String? recoveryNote,
    String? status, Timestamp? generatedAt,
    Map<String, dynamic>? basedOn,
    String? trainerNote, Timestamp? trainerNoteUpdatedAt,
  }) => AiWorkoutPlanModel(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    weeklyPlan: weeklyPlan ?? this.weeklyPlan,
    weeklyFocus: weeklyFocus ?? this.weeklyFocus,
    coachNote: coachNote ?? this.coachNote,
    bpNote: bpNote ?? this.bpNote,
    recoveryNote: recoveryNote ?? this.recoveryNote,
    status: status ?? this.status,
    generatedAt: generatedAt ?? this.generatedAt,
    basedOn: basedOn ?? this.basedOn,
    trainerNote: trainerNote ?? this.trainerNote,
    trainerNoteUpdatedAt: trainerNoteUpdatedAt ?? this.trainerNoteUpdatedAt,
  );
}
