import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_goal_model.dart';

class MemberGoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setGoal(MemberGoalModel goal) async {
    await _firestore
        .collection('memberGoals')
        .doc(goal.authUid) // Single active goal per user at memberGoals/{authUid}
        .set(goal.toMap(), SetOptions(merge: true));
  }

  Future<MemberGoalModel?> getActiveGoal(String authUid) async {
    final doc = await _firestore.collection('memberGoals').doc(authUid).get();
    if (doc.exists && doc.data() != null) {
      return MemberGoalModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
