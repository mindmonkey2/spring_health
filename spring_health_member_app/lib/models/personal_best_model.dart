import 'package:cloud_firestore/cloud_firestore.dart';

/// A single logged entry for one exercise on one day
class PersonalBestEntry {
  final DateTime date;
  final int value; // reps or seconds
  final int xpEarned;
  final bool isPersonalBest;

  const PersonalBestEntry({
    required this.date,
    required this.value,
    required this.xpEarned,
    required this.isPersonalBest,
  });

  factory PersonalBestEntry.fromMap(Map<String, dynamic> map) {
    return PersonalBestEntry(
      date: (map['date'] as Timestamp).toDate(),
      value: (map['value'] as num).toInt(),
      xpEarned: (map['xpEarned'] as num).toInt(),
      isPersonalBest: map['isPersonalBest'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'value': value,
    'xpEarned': xpEarned,
    'isPersonalBest': isPersonalBest,
  };
}

/// Supported core exercises with metadata
enum CoreExercise { pushUps, pullUps, squats, plank, burpees, sitUps }

extension CoreExerciseExtension on CoreExercise {
  String get key => name; // Firestore document key

  String get displayName {
    switch (this) {
      case CoreExercise.pushUps:
        return 'Push-Ups';
      case CoreExercise.pullUps:
        return 'Pull-Ups';
      case CoreExercise.squats:
        return 'Squats';
      case CoreExercise.plank:
        return 'Plank';
      case CoreExercise.burpees:
        return 'Burpees';
      case CoreExercise.sitUps:
        return 'Sit-Ups';
    }
  }

  String get unit {
    return this == CoreExercise.plank ? 'seconds' : 'reps';
  }

  String get unitShort {
    return this == CoreExercise.plank ? 'sec' : 'reps';
  }

  String get emoji {
    switch (this) {
      case CoreExercise.pushUps:
        return '';
      case CoreExercise.pullUps:
        return '';
      case CoreExercise.squats:
        return '';
      case CoreExercise.plank:
        return '';
      case CoreExercise.burpees:
        return '';
      case CoreExercise.sitUps:
        return '';
    }
  }
}

/// Firestore document: personal_bests/{uid}/exercises/{exerciseKey}
class PersonalBestRecord {
  final String exerciseKey;
  final int currentBest; // all-time personal best
  final List<PersonalBestEntry> history;
  final DateTime? lastLoggedDate;
  final int totalXpEarned;

  const PersonalBestRecord({
    required this.exerciseKey,
    required this.currentBest,
    required this.history,
    this.lastLoggedDate,
    required this.totalXpEarned,
  });

  bool get loggedToday {
    if (lastLoggedDate == null) return false;
    final now = DateTime.now();
    final last = lastLoggedDate!;
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  factory PersonalBestRecord.fromMap(Map<String, dynamic> map, String key) {
    final rawHistory = map['history'] as List<dynamic>? ?? [];
    return PersonalBestRecord(
      exerciseKey: key,
      currentBest: (map['currentBest'] as num?)?.toInt() ?? 0,
      history: rawHistory
          .map((e) => PersonalBestEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      lastLoggedDate: map['lastLoggedDate'] != null
          ? (map['lastLoggedDate'] as Timestamp).toDate()
          : null,
      totalXpEarned: (map['totalXpEarned'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'exerciseKey': exerciseKey,
    'currentBest': currentBest,
    'history': history.map((e) => e.toMap()).toList(),
    'lastLoggedDate': lastLoggedDate != null
        ? Timestamp.fromDate(lastLoggedDate!)
        : null,
    'totalXpEarned': totalXpEarned,
  };
}
