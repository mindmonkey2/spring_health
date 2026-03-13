// lib/models/personal_best_model.dart

enum CoreExercise {
  pushUps,
  pullUps,
  squats,
  plank,
  burpees,
  sitUps,
}

extension CoreExerciseExt on CoreExercise {
  String get key {
    switch (this) {
      case CoreExercise.pushUps:
        return 'push_ups';
      case CoreExercise.pullUps:
        return 'pull_ups';
      case CoreExercise.squats:
        return 'squats';
      case CoreExercise.plank:
        return 'plank';
      case CoreExercise.burpees:
        return 'burpees';
      case CoreExercise.sitUps:
        return 'sit_ups';
    }
  }

  String get displayName {
    switch (this) {
      case CoreExercise.pushUps:
        return 'Push-ups';
      case CoreExercise.pullUps:
        return 'Pull-ups';
      case CoreExercise.squats:
        return 'Squats';
      case CoreExercise.plank:
        return 'Plank';
      case CoreExercise.burpees:
        return 'Burpees';
      case CoreExercise.sitUps:
        return 'Sit-ups';
    }
  }
}

class PersonalBestModel {
  final String id;
  final String memberId;
  final CoreExercise exercise;
  /// Represents reps for most exercises, but can represent seconds for the Plank.
  final double recordValue;
  final DateTime dateAchieved;

  const PersonalBestModel({
    required this.id,
    required this.memberId,
    required this.exercise,
    required this.recordValue,
    required this.dateAchieved,
  });

  factory PersonalBestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PersonalBestModel(
      id: documentId,
      memberId: map['memberId'] as String? ?? '',
      exercise: CoreExercise.values.firstWhere(
        (e) => e.key == map['exercise'],
        orElse: () => CoreExercise.pushUps, // Fallback
      ),
      recordValue: (map['recordValue'] as num?)?.toDouble() ?? 0.0,
      dateAchieved: map['dateAchieved'] != null
      ? DateTime.parse(map['dateAchieved'].toString())
      : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'exercise': exercise.key,
      'recordValue': recordValue,
      'dateAchieved': dateAchieved.toIso8601String(),
    };
  }
}
