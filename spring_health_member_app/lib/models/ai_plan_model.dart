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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'weeklyPlan': weeklyPlan,
      'weeklyFocus': weeklyFocus,
      'coachNote': coachNote,
      'bpNote': bpNote,
      'recoveryNote': recoveryNote,
      'status': status,
      'generatedAt': generatedAt,
      'basedOn': basedOn,
    };
  }

  AiWorkoutPlanModel copyWith({
    String? id,
    String? memberId,
    List<Map<String, dynamic>>? weeklyPlan,
    String? weeklyFocus,
    String? coachNote,
    String? bpNote,
    String? recoveryNote,
    String? status,
    Timestamp? generatedAt,
    Map<String, dynamic>? basedOn,
  }) {
    return AiWorkoutPlanModel(
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
    );
  }
}

class AiDietPlanModel {
  final String id;
  final String memberId;
  final Map<String, dynamic> dailyTargets;
  final List<Map<String, dynamic>> meals;
  final double hydrationLitres;
  final String nutritionNotes;
  final String? bpDietNote;
  final String? glucoseNote;
  final Timestamp generatedAt;

  const AiDietPlanModel({
    required this.id,
    required this.memberId,
    required this.dailyTargets,
    required this.meals,
    required this.hydrationLitres,
    required this.nutritionNotes,
    this.bpDietNote,
    this.glucoseNote,
    required this.generatedAt,
  });

  factory AiDietPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return AiDietPlanModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      dailyTargets: Map<String, dynamic>.from(map['dailyTargets'] ?? {}),
      meals: List<Map<String, dynamic>>.from(map['meals'] ?? []),
      hydrationLitres: (map['hydrationLitres'] as num?)?.toDouble() ?? 0.0,
      nutritionNotes: map['nutritionNotes'] as String? ?? '',
      bpDietNote: map['bpDietNote'] as String?,
      glucoseNote: map['glucoseNote'] as String?,
      generatedAt: map['generatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'dailyTargets': dailyTargets,
      'meals': meals,
      'hydrationLitres': hydrationLitres,
      'nutritionNotes': nutritionNotes,
      'bpDietNote': bpDietNote,
      'glucoseNote': glucoseNote,
      'generatedAt': generatedAt,
    };
  }

  AiDietPlanModel copyWith({
    String? id,
    String? memberId,
    Map<String, dynamic>? dailyTargets,
    List<Map<String, dynamic>>? meals,
    double? hydrationLitres,
    String? nutritionNotes,
    String? bpDietNote,
    String? glucoseNote,
    Timestamp? generatedAt,
  }) {
    return AiDietPlanModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      dailyTargets: dailyTargets ?? this.dailyTargets,
      meals: meals ?? this.meals,
      hydrationLitres: hydrationLitres ?? this.hydrationLitres,
      nutritionNotes: nutritionNotes ?? this.nutritionNotes,
      bpDietNote: bpDietNote ?? this.bpDietNote,
      glucoseNote: glucoseNote ?? this.glucoseNote,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}
