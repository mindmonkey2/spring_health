import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';

class WorkoutService {
  final _db = FirebaseFirestore.instance;

  // ✅ Save a completed workout
  Future<void> saveWorkout(WorkoutLog workout) async {
    await _db.collection('workouts').add(workout.toMap());
  }

  // ✅ Real-time stream of member's workout history
  Future<List<WorkoutLog>> getWorkoutHistory(String memberId) async {
    final snap = await _db
    .collection('workouts')
    .where('memberId', isEqualTo: memberId)
    .orderBy('date', descending: true)
    .get();

    return snap.docs
    .map((doc) => WorkoutLog.fromFirestore(doc))
    .toList();
  }

  // ✅ Get total workouts this week
  Future<int> getWeeklyWorkoutCount(String memberId) async {
    final weekAgo =
    DateTime.now().subtract(const Duration(days: 7));
    final snap = await _db
    .collection('workouts')
    .where('memberId', isEqualTo: memberId)
    .where('date',
           isGreaterThan: Timestamp.fromDate(weekAgo))
    .get();
    return snap.docs.length;
  }
}
