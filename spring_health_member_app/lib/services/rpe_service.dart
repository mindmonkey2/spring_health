import 'package:cloud_firestore/cloud_firestore.dart';

class RpeService {
  static final RpeService instance = RpeService._internal();
  RpeService._internal();

  Future<void> submitRpe({
    required String memberId,
    required int rpe,
    required String label,
    required String sessionId,
    required List<String> muscleGroups,
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    // Write to rpeLog/{uid}/entries
    final entryRef = FirebaseFirestore.instance
        .collection('rpeLog')
        .doc(memberId)
        .collection('entries')
        .doc();

    batch.set(entryRef, {
      'rpe': rpe,
      'label': label,
      'workoutSessionId': sessionId,
      'muscleGroups': muscleGroups,
      'submittedAt': Timestamp.now(),
    });

    // Commit entry first, then update rolling average
    await batch.commit();

    // Compute rolling average of last 5 entries
    final recent = await FirebaseFirestore.instance
        .collection('rpeLog')
        .doc(memberId)
        .collection('entries')
        .orderBy('submittedAt', descending: true)
        .limit(5)
        .get();

    if (recent.docs.isEmpty) return;

    final values = recent.docs
        .map((d) => (d.data()['rpe'] as num).toDouble())
        .toList();
    final average = values.reduce((a, b) => a + b) / values.length;

    // Update aiPlans/{uid} with rolling average
    await FirebaseFirestore.instance.collection('aiPlans').doc(memberId).update({
      'lastAverageRpe': double.parse(average.toStringAsFixed(2)),
      'lastRpeSubmittedAt': Timestamp.now(),
    });
  }

  // Returns the last N RPE entries for use in plan generation context
  Future<List<Map<String, dynamic>>> getRecentRpe({required String memberId, int limit = 5}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('rpeLog')
        .doc(memberId)
        .collection('entries')
        .orderBy('submittedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }
}
