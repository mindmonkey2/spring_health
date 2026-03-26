import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────
// EXERCISE SET
// ─────────────────────────────────────────────
class ExerciseSet {
  final int setNumber;
  final double weight; // in kg
  final int reps;
  final bool isCompleted;
  final bool isPersonalRecord; // ✅ NEW — PR flag

  ExerciseSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
    this.isPersonalRecord = false,
  });

  // ✅ Computed
  int get volume => (weight * reps).toInt();

  // ✅ copyWith
  ExerciseSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    bool? isCompleted,
    bool? isPersonalRecord,
  }) => ExerciseSet(
    setNumber: setNumber ?? this.setNumber,
    weight: weight ?? this.weight,
    reps: reps ?? this.reps,
    isCompleted: isCompleted ?? this.isCompleted,
    isPersonalRecord: isPersonalRecord ?? this.isPersonalRecord,
  );

  Map<String, dynamic> toMap() => {
    'setNumber': setNumber,
    'weight': weight,
    'reps': reps,
    'isCompleted': isCompleted,
    'isPersonalRecord': isPersonalRecord,
  };

  factory ExerciseSet.fromMap(Map<String, dynamic> map) => ExerciseSet(
    setNumber: map['setNumber'] as int? ?? 0,
    weight: (map['weight'] ?? 0).toDouble(),
    reps: map['reps'] as int? ?? 0,
    isCompleted: map['isCompleted'] as bool? ?? false,
    isPersonalRecord: map['isPersonalRecord'] as bool? ?? false,
  );
}

// ─────────────────────────────────────────────
// WORKOUT EXERCISE
// ─────────────────────────────────────────────
class WorkoutExercise {
  final String id;
  final String name;
  final String category; // chest, back, legs, arms, shoulders, core, cardio
  final List<ExerciseSet> sets;
  final String? notes;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.sets,
    this.notes,
  });

  // ✅ Computed getters
  int get totalVolume =>
      sets.fold<int>(0, (total, s) => total + s.volume); // ✅ explicit <int>

  int get completedSets => sets.where((s) => s.weight > 0 && s.reps > 0).length;

  int get totalSets => sets.length;

  bool get hasPersonalRecord => sets.any((s) => s.isPersonalRecord);

  double get maxWeight => sets.isEmpty
      ? 0
      : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  int get maxReps => sets.isEmpty
      ? 0
      : sets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);

  // ✅ copyWith
  WorkoutExercise copyWith({
    String? id,
    String? name,
    String? category,
    List<ExerciseSet>? sets,
    String? notes,
  }) => WorkoutExercise(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    sets: sets ?? this.sets,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'sets': sets.map((s) => s.toMap()).toList(),
    'notes': notes,
  };

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) => WorkoutExercise(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    category: map['category'] as String? ?? '',
    sets: (map['sets'] as List<dynamic>? ?? [])
        .map((s) => ExerciseSet.fromMap(s as Map<String, dynamic>))
        .toList(),
    notes: map['notes'] as String?,
  );
}

// ─────────────────────────────────────────────
// WORKOUT LOG
// ─────────────────────────────────────────────
class WorkoutLog {
  final String id;
  final String memberId;
  final String title;
  final DateTime date;
  final int durationMinutes;
  final List<WorkoutExercise> exercises;
  final String? notes;
  final int totalVolume; // total kg lifted
  final int totalSets;
  final int caloriesBurned; // ✅ NEW — fixes undefined_named_parameter error

  WorkoutLog({
    required this.id,
    required this.memberId,
    required this.title,
    required this.date,
    required this.durationMinutes,
    required this.exercises,
    this.notes,
    required this.totalVolume,
    required this.totalSets,
    this.caloriesBurned = 0, // ✅ default so existing callers don't break
  });

  // ✅ Computed getters
  int get totalExercises => exercises.length;

  int get completedSetsCount =>
      exercises.fold<int>(0, (total, e) => total + e.completedSets);

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  String get formattedDuration {
    if (durationMinutes < 60) return '${durationMinutes}m';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  // ✅ Most-worked category
  String get primaryCategory {
    if (exercises.isEmpty) return 'General';
    final counts = <String, int>{};
    for (final e in exercises) {
      counts[e.category] = (counts[e.category] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // ✅ copyWith
  WorkoutLog copyWith({
    String? id,
    String? memberId,
    String? title,
    DateTime? date,
    int? durationMinutes,
    List<WorkoutExercise>? exercises,
    String? notes,
    int? totalVolume,
    int? totalSets,
    int? caloriesBurned,
  }) => WorkoutLog(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    title: title ?? this.title,
    date: date ?? this.date,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    exercises: exercises ?? this.exercises,
    notes: notes ?? this.notes,
    totalVolume: totalVolume ?? this.totalVolume,
    totalSets: totalSets ?? this.totalSets,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
  );

  // ✅ Empty factory — useful for UI init
  factory WorkoutLog.empty(String memberId) => WorkoutLog(
    id: '',
    memberId: memberId,
    title: 'New Workout',
    date: DateTime.now(),
    durationMinutes: 0,
    exercises: [],
    totalVolume: 0,
    totalSets: 0,
    caloriesBurned: 0,
  );

  factory WorkoutLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutLog(
      id: doc.id,
      memberId: data['memberId'] as String? ?? '',
      title: data['title'] as String? ?? 'Workout',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: data['durationMinutes'] as int? ?? 0,
      exercises: (data['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExercise.fromMap(e as Map<String, dynamic>))
          .toList(),
      notes: data['notes'] as String?,
      totalVolume: data['totalVolume'] as int? ?? 0,
      totalSets: data['totalSets'] as int? ?? 0,
      caloriesBurned:
          data['caloriesBurned'] as int? ?? 0, // ✅ reads from Firestore
    );
  }

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'title': title,
    'date': Timestamp.fromDate(date),
    'durationMinutes': durationMinutes,
    'exercises': exercises.map((e) => e.toMap()).toList(),
    'notes': notes,
    'totalVolume': totalVolume,
    'totalSets': totalSets,
    'caloriesBurned': caloriesBurned, // ✅ writes to Firestore
  };
}
