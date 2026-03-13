import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trainer_model.dart';
import '../models/diet_plan_model.dart';

class TrainerService {
  final _db = FirebaseFirestore.instance;

  // ── Member's assigned trainer ─────────────────────────────────────────────

  Stream<TrainerModel?> getMyTrainerStream(String memberId) {
    return _db
    .collection('trainers')
    .where('assignedMembers', arrayContains: memberId)
    .limit(1)
    .snapshots()
    .map((snap) {
      if (snap.docs.isEmpty) return null;
      final trainer =
      TrainerModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
      return trainer.isActive ? trainer : null;
    });
  }

  // ── All active trainers at a branch ──────────────────────────────────────

  Stream<List<TrainerModel>> getTrainersStream(String branch) {
    return _db
    .collection('trainers')
    .where('branch', isEqualTo: branch)
    .where('isActive', isEqualTo: true)
    .snapshots()
    .map((snap) => snap.docs
    .map((d) => TrainerModel.fromMap(d.data(), d.id))
    .toList());
  }

  // ── Diet plan assigned to a member ────────────────────────────────────────
  // Doc ID = memberId for direct lookup — no query needed

  Stream<DietPlanModel?> getDietPlanStream(String memberId) {
    return _db
    .collection('dietPlans')
    .doc(memberId)
    .snapshots()
    .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final plan = DietPlanModel.fromFirestore(doc);
      return plan.isActive ? plan : null;
    });
  }
}
