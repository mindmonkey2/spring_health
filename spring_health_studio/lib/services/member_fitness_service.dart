
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_summary_model.dart';

class MemberFitnessService {
  MemberFitnessService({FirebaseFirestore? firestore})
  : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Fetches the last [limit] workout sessions for a member.
  /// Tries subcollection workouts/{memberId}/sessions first,
  /// then falls back to top-level workouts collection filtered by memberId.
  Future<List<WorkoutSummaryModel>> getWorkouts(
    String memberId, {
      int limit = 20,
    }) async {
      // Try subcollection path (member app writes here)
      try {
        final sub = await _db
        .collection('workouts')
        .doc(memberId)
        .collection('sessions')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

        if (sub.docs.isNotEmpty) {
          return sub.docs
          .map((d) => WorkoutSummaryModel.fromMap(d.data(), d.id))
          .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching workouts from subcollection: $e');
        }
      }

      // Fallback: top-level collection with memberId field
      try {
        final top = await _db
        .collection('workouts')
        .where('memberId', isEqualTo: memberId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

        return top.docs
        .map((d) => WorkoutSummaryModel.fromMap(d.data(), d.id))
        .toList();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching workouts from top-level collection: $e');
        }
        return [];
      }
    }

    /// Fetches the gamification profile for a single member.
    Future<Map<String, dynamic>?> getGamificationProfile(
      String memberId) async {
        try {
          final doc =
          await _db.collection('gamification').doc(memberId).get();
          if (doc.exists) return doc.data();
          return null;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error fetching gamification profile: $e');
          }
          return null;
        }
      }
}
