import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/body_metrics_model.dart';

class BodyMetricsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _col = 'bodyMetrics';

  // Add a new entry
  Future<void> addMetrics(BodyMetricsModel metrics) async {
    try {
      await _db.collection(_col).add(metrics.toMap());
      debugPrint('BodyMetricsService: Entry saved successfully');
    } catch (e) {
      debugPrint('BodyMetricsService: Error saving — $e');
      rethrow;
    }
  }

  // Real-time stream — newest first, last 30 entries
  Stream<List<BodyMetricsModel>> getMetricsStream(String memberId) {
    return _db
        .collection(_col)
        .where('memberId', isEqualTo: memberId)
        .orderBy('recordedAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BodyMetricsModel.fromFirestore(d.data(), d.id))
              .toList(),
        );
  }

  // Delete a single entry
  Future<void> deleteMetrics(String id) async {
    try {
      await _db.collection(_col).doc(id).delete();
    } catch (e) {
      debugPrint('BodyMetricsService: Error deleting — $e');
      rethrow;
    }
  }
}
