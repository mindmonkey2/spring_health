// lib/services/trainer_feedback_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer_feedback_model.dart';   // ✅ correct relative path

class TrainerFeedbackService {
  final _db = FirebaseFirestore.instance;

  // Collection: trainerFeedback/{feedbackId}
  CollectionReference<Map<String, dynamic>> get _col =>
  _db.collection('trainerFeedback');

  /// Stream of all feedback for a specific trainer
  Stream<List<TrainerFeedbackModel>> getFeedbackForTrainer(String trainerId) {
    return _col
    .where('trainerId', isEqualTo: trainerId)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((s) => s.docs
    .map((d) => TrainerFeedbackModel.fromMap(d.data(), d.id))
    .toList());
  }

  /// Add new feedback
  Future<void> addFeedback(TrainerFeedbackModel feedback) async {
    final ref = _col.doc();
    await ref.set({...feedback.toMap(), 'id': ref.id});
  }

  /// Delete feedback by id
  Future<void> deleteFeedback(String id) async {
    await _col.doc(id).delete();
  }
}
