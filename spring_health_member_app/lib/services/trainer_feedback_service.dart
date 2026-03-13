// lib/services/trainer_feedback_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer_feedback_model.dart';

class TrainerFeedbackService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _feedbackRef(
    String trainerId) =>
    _db
    .collection('trainers')
    .doc(trainerId)
    .collection('feedback');

    /// Stream all feedback for a trainer (Studio side — real-time)
    Stream<List<TrainerFeedbackModel>> streamFeedback(String trainerId) {
      return _feedbackRef(trainerId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs
      .map((d) => TrainerFeedbackModel.fromMap(d.data(), d.id))
      .toList());
    }

    /// Fetch all feedback once (Member App side)
    Future<List<TrainerFeedbackModel>> getFeedback(String trainerId) async {
      final snap = await _feedbackRef(trainerId)
      .orderBy('createdAt', descending: true)
      .get();
      return snap.docs
      .map((d) => TrainerFeedbackModel.fromMap(d.data(), d.id))
      .toList();
    }

    /// Submit new feedback from a member
    Future<void> submitFeedback({
      required String trainerId,
      required String memberId,
      required String memberName,
      required String memberPhone,
      required String workoutType,
      required String message,
      required int rating,
    }) async {
      final now = DateTime.now();
      final feedback = TrainerFeedbackModel(
        id: '',
        memberId: memberId,
        memberName: memberName,
        memberPhone: memberPhone,
        workoutType: workoutType,
        message: message,
        rating: rating,
        createdAt: now,
      );
      await _feedbackRef(trainerId).add(feedback.toMap());
    }
}
