import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_model.dart';
import '../models/notification_model.dart';
import 'gamification_service.dart';
import 'in_app_notification_service.dart';

class WorkoutService {
  final _db = FirebaseFirestore.instance;
  final _gamificationService = GamificationService();
  final _notifService = InAppNotificationService();

  // ✅ Save a completed workout
  Future<DocumentReference> saveWorkout(WorkoutLog workout) async {
    final docRef = await _db.collection('workouts').add(workout.toMap());

    // ✅ Check and update Personal Bests if not a quick log
    if (workout.source != 'quick_log') {
      try {
        await checkAndUpdatePersonalBests(workout.memberId, docRef.id, workout.exercises);
      } catch (e) {
        debugPrint('Error updating personal bests: \$e');
      }
    }

    return docRef;
  }

  // ✅ PB DETECTION LOGIC
  Future<void> checkAndUpdatePersonalBests(
    String memberId,
    String sessionId,
    List<WorkoutExercise> exercises,
  ) async {
    final pbRef = _db.collection('personalbests').doc(memberId);
    final pbDoc = await pbRef.get();

    Map<String, dynamic> existingExercises = {};
    if (pbDoc.exists) {
      final data = pbDoc.data();
      if (data != null && data.containsKey('exercises')) {
        existingExercises = Map<String, dynamic>.from(data['exercises'] as Map);
      }
    }

    bool hasUpdates = false;
    final Map<String, dynamic> updates = {};
    final now = DateTime.now();

    for (final exercise in exercises) {
      // Find max weight or reps
      double maxWeight = 0;
      int maxReps = 0;
      for (final set in exercise.sets) {
        if (!set.isCompleted) continue;
        if (set.weight > maxWeight) {
          maxWeight = set.weight;
        }
        if (set.reps > maxReps) {
          maxReps = set.reps;
        }
      }

      double maxValue = 0;
      bool isWeight = false;
      if (maxWeight > 0) {
        maxValue = maxWeight;
        isWeight = true;
      } else if (maxReps > 0) {
        maxValue = maxReps.toDouble();
        isWeight = false;
      }

      if (maxValue == 0) continue;

      final exerciseName = exercise.name;
      final existingRecord = existingExercises[exerciseName] as Map<String, dynamic>?;
      final storedValue = existingRecord != null ? (existingRecord['value'] as num).toDouble() : 0.0;

      if (maxValue > storedValue) {
        hasUpdates = true;

        final lastXpAwardedAt = existingRecord?['lastXpAwardedAt'] as Timestamp?;
        bool awardXp = false;

        if (lastXpAwardedAt == null) {
          awardXp = true;
        } else {
          final daysSinceXp = now.difference(lastXpAwardedAt.toDate()).inDays;
          if (daysSinceXp > 7) {
            awardXp = true;
          }
        }

        updates['exercises.$exerciseName'] = {
          'value': maxValue,
          'unit': isWeight ? 'kg' : 'reps',
          'sessionId': sessionId,
          'setAt': FieldValue.serverTimestamp(),
          'lastXpAwardedAt': awardXp ? FieldValue.serverTimestamp() : lastXpAwardedAt,
        };

        if (awardXp) {
          // Award 50 XP
          await _gamificationService.awardXp(
            memberId,
            'New Personal Best: $exerciseName',
            50,
          );

          // Fire gamification event
          await _db.collection('gamification_events').add({
            'memberId': memberId,
            'type': 'personal_best',
            'exerciseName': exerciseName,
            'newValue': maxValue,
            'unit': isWeight ? 'kg' : 'reps',
            'timestamp': FieldValue.serverTimestamp(),
            'processed': false,
          });

          // Write in-app notification
          await _notifService.addNotificationsForMemberBatch(
            uid: memberId,
            notifications: [
              NotificationData(
                type: NotificationType.gym,
                title: 'Personal Best!',
                body: 'New PB: ${maxValue.toInt()}${isWeight ? 'kg' : 'reps'} on $exerciseName',
              ),
            ],
          );
        }
      }
    }

    if (hasUpdates) {
      await pbRef.set(updates, SetOptions(merge: true));
    }
  }

  // ✅ Real-time stream of member's workout history
  Future<List<WorkoutLog>> getWorkoutHistory(String memberId) async {
    final snap = await _db
        .collection('workouts')
        .where('memberId', isEqualTo: memberId)
        .orderBy('date', descending: true)
        .get();

    return snap.docs.map((doc) => WorkoutLog.fromFirestore(doc)).toList();
  }

  // ✅ Get total workouts this week
  Future<int> getWeeklyWorkoutCount(String memberId) async {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _db
        .collection('workouts')
        .where('memberId', isEqualTo: memberId)
        .where('date', isGreaterThan: Timestamp.fromDate(weekAgo))
        .get();
    return snap.docs.length;
  }
}
