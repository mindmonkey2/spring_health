import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingSessionModel {
  final String id;
  final String trainerId;
  final String memberId;
  final String memberAuthUid;
  final String memberName;
  final int memberAge;
  final String branch;
  final Timestamp date;
  final bool isFirstSession;
  final String status;
  final int readinessScore;
  final Map<String, dynamic> trainerContext;
  final Map<String, dynamic> bodyMetricsContext;
  final Map<String, dynamic>? goalContext;
  final Map<String, dynamic>? flexibilityContext;
  final String? selectedIntensity;
  final Map<String, dynamic> plans;
  final List<Map<String, dynamic>> exercises;
  final int activeExerciseIndex;
  final Timestamp? warmupStartTime;
  final Timestamp? sessionStartTime;
  final Timestamp? sessionEndTime;
  final int? totalDurationMinutes;
  final String? trainerNotes;
  final int? sessionRpe;
  final String? sessionFocus;
  final String? goalInsight;
  final String? postWorkoutMeal;
  final String? dinnerSuggestion;
  final bool? isFoundationSession;
  final Timestamp? nutritionSentAt;
  final Timestamp? nextWeighInDate;

  TrainingSessionModel({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.memberAuthUid,
    required this.memberName,
    required this.memberAge,
    required this.branch,
    required this.date,
    required this.isFirstSession,
    required this.status,
    required this.readinessScore,
    required this.trainerContext,
    required this.bodyMetricsContext,
    this.goalContext,
    this.flexibilityContext,
    this.selectedIntensity,
    required this.plans,
    required this.exercises,
    required this.activeExerciseIndex,
    this.warmupStartTime,
    this.sessionStartTime,
    this.sessionEndTime,
    this.totalDurationMinutes,
    this.trainerNotes,
    this.sessionRpe,
    this.sessionFocus,
    this.goalInsight,
    this.postWorkoutMeal,
    this.dinnerSuggestion,
    this.isFoundationSession,
    this.nutritionSentAt,
    this.nextWeighInDate,
  });

  factory TrainingSessionModel.fromMap(Map<String, dynamic> data, String id) {
    return TrainingSessionModel(
      id: id,
      trainerId: data['trainerId'] ?? '',
      memberId: data['memberId'] ?? '',
      memberAuthUid: data['memberAuthUid'] ?? '',
      memberName: data['memberName'] ?? '',
      memberAge: data['memberAge'] as int? ?? 0,
      branch: data['branch'] ?? '',
      date: data['date'] as Timestamp? ?? Timestamp.now(),
      isFirstSession: data['isFirstSession'] as bool? ?? false,
      status: data['status'] ?? 'analyzing',
      readinessScore: data['readinessScore'] as int? ?? 0,
      trainerContext: data['trainerContext'] != null
          ? Map<String, dynamic>.from(data['trainerContext'] as Map)
          : {},
      bodyMetricsContext: data['bodyMetricsContext'] != null
          ? Map<String, dynamic>.from(data['bodyMetricsContext'] as Map)
          : {},
      goalContext: data['goalContext'] != null
          ? Map<String, dynamic>.from(data['goalContext'] as Map)
          : null,
      flexibilityContext: data['flexibilityContext'] != null
          ? Map<String, dynamic>.from(data['flexibilityContext'] as Map)
          : null,
      selectedIntensity: data['selectedIntensity'] as String?,
      plans: data['plans'] != null
          ? Map<String, dynamic>.from(data['plans'] as Map)
          : {},
      exercises: data['exercises'] != null
          ? List<Map<String, dynamic>>.from(
              (data['exercises'] as List).map((e) => Map<String, dynamic>.from(e as Map)))
          : [],
      activeExerciseIndex: data['activeExerciseIndex'] as int? ?? 0,
      warmupStartTime: data['warmupStartTime'] as Timestamp?,
      sessionStartTime: data['sessionStartTime'] as Timestamp?,
      sessionEndTime: data['sessionEndTime'] as Timestamp?,
      totalDurationMinutes: data['totalDurationMinutes'] as int?,
      trainerNotes: data['trainerNotes'] as String?,
      sessionRpe: data['sessionRpe'] as int?,
      sessionFocus: data['sessionFocus'] as String?,
      goalInsight: data['goalInsight'] as String?,
      postWorkoutMeal: data['postWorkoutMeal'] as String?,
      dinnerSuggestion: data['dinnerSuggestion'] as String?,
      isFoundationSession: data['isFoundationSession'] as bool?,
      nutritionSentAt: data['nutritionSentAt'] as Timestamp?,
      nextWeighInDate: data['nextWeighInDate'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'trainerId': trainerId,
      'memberId': memberId,
      'memberAuthUid': memberAuthUid,
      'memberName': memberName,
      'memberAge': memberAge,
      'branch': branch,
      'date': date,
      'isFirstSession': isFirstSession,
      'status': status,
      'readinessScore': readinessScore,
      'trainerContext': trainerContext,
      'bodyMetricsContext': bodyMetricsContext,
      if (goalContext != null) 'goalContext': goalContext,
      if (flexibilityContext != null) 'flexibilityContext': flexibilityContext,
      if (selectedIntensity != null) 'selectedIntensity': selectedIntensity,
      'plans': plans,
      'exercises': exercises,
      'activeExerciseIndex': activeExerciseIndex,
      if (warmupStartTime != null) 'warmupStartTime': warmupStartTime,
      if (sessionStartTime != null) 'sessionStartTime': sessionStartTime,
      if (sessionEndTime != null) 'sessionEndTime': sessionEndTime,
      if (totalDurationMinutes != null) 'totalDurationMinutes': totalDurationMinutes,
      if (trainerNotes != null) 'trainerNotes': trainerNotes,
      if (sessionRpe != null) 'sessionRpe': sessionRpe,
      if (sessionFocus != null) 'sessionFocus': sessionFocus,
      if (goalInsight != null) 'goalInsight': goalInsight,
      if (postWorkoutMeal != null) 'postWorkoutMeal': postWorkoutMeal,
      if (dinnerSuggestion != null) 'dinnerSuggestion': dinnerSuggestion,
      if (isFoundationSession != null) 'isFoundationSession': isFoundationSession,
      if (nutritionSentAt != null) 'nutritionSentAt': nutritionSentAt,
      if (nextWeighInDate != null) 'nextWeighInDate': nextWeighInDate,
    };
  }

  TrainingSessionModel copyWith({
    String? trainerId,
    String? memberId,
    String? memberAuthUid,
    String? memberName,
    int? memberAge,
    String? branch,
    Timestamp? date,
    bool? isFirstSession,
    String? status,
    int? readinessScore,
    Map<String, dynamic>? trainerContext,
    Map<String, dynamic>? bodyMetricsContext,
    Map<String, dynamic>? goalContext,
    Map<String, dynamic>? flexibilityContext,
    String? selectedIntensity,
    Map<String, dynamic>? plans,
    List<Map<String, dynamic>>? exercises,
    int? activeExerciseIndex,
    Timestamp? warmupStartTime,
    Timestamp? sessionStartTime,
    Timestamp? sessionEndTime,
    int? totalDurationMinutes,
    String? trainerNotes,
    int? sessionRpe,
    String? sessionFocus,
    String? goalInsight,
    String? postWorkoutMeal,
    String? dinnerSuggestion,
    bool? isFoundationSession,
    Timestamp? nutritionSentAt,
    Timestamp? nextWeighInDate,
  }) {
    return TrainingSessionModel(
      id: id,
      trainerId: trainerId ?? this.trainerId,
      memberId: memberId ?? this.memberId,
      memberAuthUid: memberAuthUid ?? this.memberAuthUid,
      memberName: memberName ?? this.memberName,
      memberAge: memberAge ?? this.memberAge,
      branch: branch ?? this.branch,
      date: date ?? this.date,
      isFirstSession: isFirstSession ?? this.isFirstSession,
      status: status ?? this.status,
      readinessScore: readinessScore ?? this.readinessScore,
      trainerContext: trainerContext ?? this.trainerContext,
      bodyMetricsContext: bodyMetricsContext ?? this.bodyMetricsContext,
      goalContext: goalContext ?? this.goalContext,
      flexibilityContext: flexibilityContext ?? this.flexibilityContext,
      selectedIntensity: selectedIntensity ?? this.selectedIntensity,
      plans: plans ?? this.plans,
      exercises: exercises ?? this.exercises,
      activeExerciseIndex: activeExerciseIndex ?? this.activeExerciseIndex,
      warmupStartTime: warmupStartTime ?? this.warmupStartTime,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionEndTime: sessionEndTime ?? this.sessionEndTime,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      trainerNotes: trainerNotes ?? this.trainerNotes,
      sessionRpe: sessionRpe ?? this.sessionRpe,
      sessionFocus: sessionFocus ?? this.sessionFocus,
      goalInsight: goalInsight ?? this.goalInsight,
      postWorkoutMeal: postWorkoutMeal ?? this.postWorkoutMeal,
      dinnerSuggestion: dinnerSuggestion ?? this.dinnerSuggestion,
      isFoundationSession: isFoundationSession ?? this.isFoundationSession,
      nutritionSentAt: nutritionSentAt ?? this.nutritionSentAt,
      nextWeighInDate: nextWeighInDate ?? this.nextWeighInDate,
    );
  }
}
