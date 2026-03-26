import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_profile_model.dart';
import '../models/body_metrics_log_model.dart';
import '../models/fitness_test_model.dart';

class HealthProfileService {
  final FirebaseFirestore _db;

  HealthProfileService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<HealthProfileModel?> getHealthProfile(String memberId) async {
    final doc = await _db.collection('healthProfiles').doc(memberId).get();
    if (!doc.exists) return null;
    return HealthProfileModel.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
  }

  Future<void> saveHealthProfile(HealthProfileModel profile) async {
    await _db
        .collection('healthProfiles')
        .doc(profile.id)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<void> logBodyMetrics(String memberId, BodyMetricsLogModel log) async {
    final docRef = _db
        .collection('bodyMetricsLogs')
        .doc(memberId)
        .collection('logs')
        .doc(log.id.isEmpty ? null : log.id);

    final updatedLog = log.copyWith(id: docRef.id);
    await docRef.set(updatedLog.toMap());
  }

  Future<List<BodyMetricsLogModel>> getMetricsHistory(
    String memberId, {
    int limit = 30,
  }) async {
    final snapshot = await _db
        .collection('bodyMetricsLogs')
        .doc(memberId)
        .collection('logs')
        .orderBy('loggedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => BodyMetricsLogModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> saveFitnessTest(FitnessTestModel test) async {
    final docRef = _db
        .collection('fitnessTests')
        .doc(test.memberId)
        .collection('tests')
        .doc(test.id.isEmpty ? null : test.id);

    final updatedTest = test.copyWith(id: docRef.id);
    await docRef.set(updatedTest.toMap());
  }

  Future<FitnessTestModel?> getLatestFitnessTest(String memberId) async {
    final snapshot = await _db
        .collection('fitnessTests')
        .doc(memberId)
        .collection('tests')
        .orderBy('testedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return FitnessTestModel.fromMap(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  Stream<HealthProfileModel?> watchHealthProfile(String memberId) {
    return _db.collection('healthProfiles').doc(memberId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return HealthProfileModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    });
  }
}
