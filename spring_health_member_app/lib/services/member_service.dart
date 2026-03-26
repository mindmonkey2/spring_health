import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import 'package:flutter/foundation.dart';

class MemberService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MemberModel?> getMemberData(String memberId) async {
    try {
      final doc = await _firestore.collection('members').doc(memberId).get();

      if (doc.exists && doc.data() != null) {
        return MemberModel.fromFirestore(doc.data()!, doc.id); // ⬅️ FIXED
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching member data: $e');
      return null;
    }
  }

  Future<MemberModel?> getMemberByPhone(String phone) async {
    try {
      final snapshot = await _firestore
          .collection('members')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return MemberModel.fromFirestore(doc.data(), doc.id); // ⬅️ FIXED
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching member by phone: $e');
      return null;
    }
  }

  Future<bool> isMembershipActive(String memberId) async {
    try {
      final member = await getMemberData(memberId);
      if (member == null) return false;

      return !member.isExpired && member.isActive; // ⬅️ FIXED
    } catch (e) {
      debugPrint('Error checking membership status: $e');
      return false;
    }
  }

  Stream<MemberModel?> getMemberStream(String memberId) {
    return _firestore.collection('members').doc(memberId).snapshots().map((
      doc,
    ) {
      if (doc.exists && doc.data() != null) {
        return MemberModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
