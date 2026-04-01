import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session_model.dart';

class SessionService {
  static final SessionService instance = SessionService._internal();

  factory SessionService() {
    return instance;
  }

  SessionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSession({
    required String memberId,
    required String memberAuthUid,
    required String trainerId,
    required String trainerUid,
    required String trainerName,
    required String branch,
  }) async {
    final docRef = _firestore.collection('sessions').doc();

    await docRef.set({
      'memberId': memberId,
      'memberAuthUid': memberAuthUid,
      'trainerId': trainerId,
      'trainerUid': trainerUid,
      'trainerName': trainerName,
      'branch': branch,
      'date': Timestamp.now(),
      'status': 'created',
      'attendanceMarked': true,
      'dietPlanPushed': false,
      'sessionXpAwarded': false,
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  Future<void> updateStatus(String sessionId, String status) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'status': status,
    });
  }

  Future<void> writeWarmup(
    String sessionId,
    List<Map<String, dynamic>> warmupExercises,
  ) async {
    await _firestore.collection('sessions').doc(sessionId).set({
      'warmup': warmupExercises,
      'status': 'warmup',
    }, SetOptions(merge: true));
  }

  Future<void> writeExercises(
    String sessionId,
    List<Map<String, dynamic>> exercises,
  ) async {
    await _firestore.collection('sessions').doc(sessionId).set({
      'exercises': exercises,
      'status': 'planning',
    }, SetOptions(merge: true));
  }

  Future<void> markSetComplete(String sessionId, int exerciseIndex) async {
    final docRef = _firestore.collection('sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Session does not exist!');
      }

      final data = snapshot.data();
      if (data == null) return;

      final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
      if (exerciseIndex >= 0 && exerciseIndex < exercises.length) {
        final exercise = Map<String, dynamic>.from(exercises[exerciseIndex]);
        final completedSets = (exercise['completedSets'] as int?) ?? 0;
        final totalSets = (exercise['sets'] as int?) ?? 0;

        exercise['completedSets'] = completedSets + 1;

        if (exercise['completedSets'] as int >= totalSets) {
          exercise['status'] = 'complete';

          if (exerciseIndex + 1 < exercises.length) {
            final nextExercise = Map<String, dynamic>.from(exercises[exerciseIndex + 1]);
            nextExercise['status'] = 'active';
            exercises[exerciseIndex + 1] = nextExercise;
          }
        }

        exercises[exerciseIndex] = exercise;

        transaction.update(docRef, {'exercises': exercises});
      }
    });
  }

  Future<void> writeStretching(
    String sessionId,
    List<Map<String, dynamic>> stretchList,
    List<String> musclesWorked,
  ) async {
    await _firestore.collection('sessions').doc(sessionId).set({
      'stretching': stretchList,
      'musclesWorked': musclesWorked,
      'status': 'stretching',
    }, SetOptions(merge: true));
  }

  Stream<SessionModel?> getActiveSessionForMember(String memberAuthUid) {
    return _firestore
        .collection('sessions')
        .where('memberAuthUid', isEqualTo: memberAuthUid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final status = doc.data()['status'] as String?;

      if (status == 'complete' || status == 'cancelled') return null;

      return SessionModel.fromMap(doc.data(), doc.id);
    });
  }

  Stream<List<SessionModel>> getSessionsForTrainer(String trainerUid) {
    return _firestore
        .collection('sessions')
        .where('trainerUid', isEqualTo: trainerUid)
        .orderBy('date', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SessionModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
}
