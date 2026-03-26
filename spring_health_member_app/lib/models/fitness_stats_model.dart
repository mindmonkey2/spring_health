import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

enum WorkoutSource { healthKit, healthConnect, manual }

enum WorkoutType {
  upperBody,
  cardio,
  yoga,
  legDay,
  fullBody,
  hiit,
  other;

  String get label {
    switch (this) {
      case WorkoutType.upperBody:
        return 'Upper Body Power';
      case WorkoutType.cardio:
        return 'Cardio Blast';
      case WorkoutType.yoga:
        return 'Yoga Flow';
      case WorkoutType.legDay:
        return 'Leg Day';
      case WorkoutType.fullBody:
        return 'Full Body';
      case WorkoutType.hiit:
        return 'HIIT';
      case WorkoutType.other:
        return 'Workout';
    }
  }

  String get emoji {
    switch (this) {
      case WorkoutType.upperBody:
        return '💪';
      case WorkoutType.cardio:
        return '🏃';
      case WorkoutType.yoga:
        return '🧘';
      case WorkoutType.legDay:
        return '🦵';
      case WorkoutType.fullBody:
        return '🏋️';
      case WorkoutType.hiit:
        return '⚡';
      case WorkoutType.other:
        return '🏅';
    }
  }

  static WorkoutType fromString(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('upper') || s.contains('power')) {
      return WorkoutType.upperBody;
    }
    if (s.contains('cardio') || s.contains('run')) return WorkoutType.cardio;
    if (s.contains('yoga')) return WorkoutType.yoga;
    if (s.contains('leg')) return WorkoutType.legDay;
    if (s.contains('full')) return WorkoutType.fullBody;
    if (s.contains('hiit')) return WorkoutType.hiit;
    return WorkoutType.other;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WEEKLY GOAL
// ─────────────────────────────────────────────────────────────────────────────

class WeeklyGoal {
  final double runningKm;
  final int caloriesKcal;
  final double activeHours;
  final int stepsPerDay;

  const WeeklyGoal({
    this.runningKm = 25.0,
    this.caloriesKcal = 12500,
    this.activeHours = 4.0,
    this.stepsPerDay = 8000,
  });

  static const WeeklyGoal defaults = WeeklyGoal();

  WeeklyGoal copyWith({
    double? runningKm,
    int? caloriesKcal,
    double? activeHours,
    int? stepsPerDay,
  }) {
    return WeeklyGoal(
      runningKm: runningKm ?? this.runningKm,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      activeHours: activeHours ?? this.activeHours,
      stepsPerDay: stepsPerDay ?? this.stepsPerDay,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FITNESS STATS — daily snapshot (Health Connect / HealthKit / empty)
// ─────────────────────────────────────────────────────────────────────────────

class FitnessStats {
  final int steps;
  final int calories;
  final double distance; // km
  final int heartRate; // bpm average
  final int maxHeartRate; // bpm peak
  final int activeMinutes;
  final double sleepHours; // last night's sleep
  final DateTime date;
  final bool isRealData; // false = not synced yet, show 0s

  const FitnessStats({
    required this.steps,
    required this.calories,
    required this.distance,
    required this.heartRate,
    this.maxHeartRate = 0,
    required this.activeMinutes,
    this.sleepHours = 0.0,
    required this.date,
    this.isRealData = false,
  });

  // ── Empty (not synced) — use this instead of mock ────────────────────────
  factory FitnessStats.empty({DateTime? date}) => FitnessStats(
    steps: 0,
    calories: 0,
    distance: 0.0,
    heartRate: 0,
    maxHeartRate: 0,
    activeMinutes: 0,
    sleepHours: 0.0,
    date: date ?? DateTime.now(),
    isRealData: false,
  );

  /// Returns an empty weekly list (7 days, all zeros) for unconnected state
  static List<FitnessStats> emptyWeek() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      return FitnessStats.empty(date: date);
    });
  }

  // ── Firestore round-trip ──────────────────────────────────────────────────

  factory FitnessStats.fromFirestore(Map<String, dynamic> data) {
    return FitnessStats(
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      distance: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      heartRate: (data['heartRate'] as num?)?.toInt() ?? 0,
      maxHeartRate: (data['maxHeartRate'] as num?)?.toInt() ?? 0,
      activeMinutes: (data['activeMinutes'] as num?)?.toInt() ?? 0,
      sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRealData: (data['isRealData'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'steps': steps,
    'calories': calories,
    'distanceKm': distance,
    'heartRate': heartRate,
    'maxHeartRate': maxHeartRate,
    'activeMinutes': activeMinutes,
    'sleepHours': sleepHours,
    'date': Timestamp.fromDate(date),
    'isRealData': isRealData,
  };

  // ── copyWith ──────────────────────────────────────────────────────────────

  FitnessStats copyWith({
    int? steps,
    int? calories,
    double? distance,
    int? heartRate,
    int? maxHeartRate,
    int? activeMinutes,
    double? sleepHours,
    DateTime? date,
    bool? isRealData,
  }) {
    return FitnessStats(
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      distance: distance ?? this.distance,
      heartRate: heartRate ?? this.heartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      sleepHours: sleepHours ?? this.sleepHours,
      date: date ?? this.date,
      isRealData: isRealData ?? this.isRealData,
    );
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Progress toward daily step goal (0.0 – 1.0)
  double stepProgress({int goal = 8000}) => (steps / goal).clamp(0.0, 1.0);

  /// Progress toward daily calorie goal (0.0 – 1.0)
  double calorieProgress({int goal = 500}) => (calories / goal).clamp(0.0, 1.0);

  /// Formatted distance string
  String get distanceLabel => distance >= 1.0
      ? '${distance.toStringAsFixed(1)} km'
      : '${(distance * 1000).toInt()} m';

  /// Formatted sleep string
  String get sleepLabel {
    if (sleepHours <= 0) return '--';
    final h = sleepHours.floor();
    final m = ((sleepHours - h) * 60).round();
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitnessStats &&
          other.steps == steps &&
          other.calories == calories &&
          other.distance == distance &&
          other.heartRate == heartRate &&
          other.maxHeartRate == maxHeartRate &&
          other.activeMinutes == activeMinutes &&
          other.date.year == date.year &&
          other.date.month == date.month &&
          other.date.day == date.day;

  @override
  int get hashCode => Object.hash(
    steps,
    calories,
    distance,
    heartRate,
    maxHeartRate,
    activeMinutes,
    date.year,
    date.month,
    date.day,
  );

  @override
  String toString() =>
      'FitnessStats(steps: $steps, cal: $calories, '
      'dist: ${distance.toStringAsFixed(1)}km, '
      'bpm: $heartRate/$maxHeartRate, sleep: $sleepLabel, real: $isRealData)';
}

// ─────────────────────────────────────────────────────────────────────────────
// WORKOUT SESSION — a single logged workout
// ─────────────────────────────────────────────────────────────────────────────

class WorkoutSession {
  final String id;
  final String memberId;
  final String type;
  final WorkoutType workoutType;
  final DateTime startTime;
  final int duration; // minutes
  final int caloriesBurned;
  final String? notes;
  final WorkoutSource source;

  const WorkoutSession({
    required this.id,
    required this.memberId,
    required this.type,
    required this.startTime,
    required this.duration,
    required this.caloriesBurned,
    this.notes,
    this.source = WorkoutSource.manual,
    WorkoutType? workoutType,
  }) : workoutType = workoutType ?? WorkoutType.other;

  // ── Firestore round-trip ──────────────────────────────────────────────────

  factory WorkoutSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    final rawType = data['type'] as String? ?? 'Workout';
    return WorkoutSession(
      id: doc.id,
      memberId: data['memberId'] as String? ?? '',
      type: rawType,
      workoutType: WorkoutType.fromString(rawType),
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      duration: (data['duration'] as num?)?.toInt() ?? 0,
      caloriesBurned: (data['calories'] as num?)?.toInt() ?? 0,
      notes: data['notes'] as String?,
      source: _sourceFromString(data['source'] as String? ?? 'manual'),
    );
  }

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'type': type,
    'workoutType': workoutType.name,
    'startTime': Timestamp.fromDate(startTime),
    'duration': duration,
    'calories': caloriesBurned,
    if (notes != null) 'notes': notes,
    'source': source.name,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  // ── copyWith ──────────────────────────────────────────────────────────────

  WorkoutSession copyWith({
    String? id,
    String? memberId,
    String? type,
    WorkoutType? workoutType,
    DateTime? startTime,
    int? duration,
    int? caloriesBurned,
    String? notes,
    WorkoutSource? source,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      type: type ?? this.type,
      workoutType: workoutType ?? this.workoutType,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      source: source ?? this.source,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static WorkoutSource _sourceFromString(String s) {
    switch (s) {
      case 'healthKit':
        return WorkoutSource.healthKit;
      case 'healthConnect':
        return WorkoutSource.healthConnect;
      default:
        return WorkoutSource.manual;
    }
  }

  String get sourceLabel {
    switch (source) {
      case WorkoutSource.healthKit:
        return 'Apple Health';
      case WorkoutSource.healthConnect:
        return 'Health Connect';
      case WorkoutSource.manual:
        return 'Manual';
    }
  }

  String get durationLabel {
    if (duration < 60) return '${duration}m';
    final h = duration ~/ 60;
    final m = duration % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  // ── Equality ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WorkoutSession && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'WorkoutSession(id: $id, type: $type, '
      'dur: $durationLabel, cal: $caloriesBurned, src: ${source.name})';
}
