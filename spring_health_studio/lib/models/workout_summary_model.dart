
class WorkoutSummaryModel {
  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;
  final int totalSets;
  final int totalReps;
  final int volumeKg;
  final int xpEarned;

  const WorkoutSummaryModel({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.totalSets,
    required this.totalReps,
    required this.volumeKg,
    required this.xpEarned,
  });

  factory WorkoutSummaryModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate() {
      final raw = map['date'] ?? map['startTime'] ?? map['createdAt'];
      if (raw == null) return DateTime.now();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      // Firestore Timestamp
      try {
        return (raw as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    return WorkoutSummaryModel(
      id: id,
      name: (map['name'] as String?) ?? (map['workoutName'] as String?) ?? 'Workout',
      date: parseDate(),
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ??
      (map['duration'] as num?)?.toInt() ?? 0,
      caloriesBurned: (map['caloriesBurned'] as num?)?.toInt() ??
      (map['calories'] as num?)?.toInt() ?? 0,
      totalSets: (map['totalSets'] as num?)?.toInt() ?? 0,
      totalReps: (map['totalReps'] as num?)?.toInt() ?? 0,
      volumeKg: (map['totalVolumeKg'] as num?)?.toInt() ??
      (map['volumeKg'] as num?)?.toInt() ?? 0,
      xpEarned: (map['xpEarned'] as num?)?.toInt() ?? 0,
    );
  }
}
