import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../models/attendance_model.dart';
import '../models/announcement_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== MEMBER METHODS ====================

  /// Update member's profile image URL
  Future<void> updateProfileImageUrl(String memberId, String imageUrl) async {
    try {
      await _firestore.collection('members').doc(memberId).update({
        'photoUrl': imageUrl,
      });
      debugPrint('Profile image URL updated successfully for $memberId');
    } catch (e) {
      debugPrint('Error updating profile image URL: $e');
      rethrow;
    }
  }

  /// Get member data by ID
  Future<MemberModel?> getMemberById(String id) async {
    try {
      final doc = await _firestore.collection('members').doc(id).get();

      if (doc.exists && doc.data() != null) {
        return MemberModel.fromMap({...doc.data()!, 'id': doc.id});
      }

      return null;
    } catch (e) {
      debugPrint('Error getting member: $e');
      return null;
    }
  }

  /// Get member data by phone number
  Future<MemberModel?> getMemberByPhone(String phone) async {
    try {
      final snapshot = await _firestore
          .collection('members')
          .where('phone', isEqualTo: phone)
          .where('isArchived', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return MemberModel.fromMap({
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        });
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching member by phone: $e');
      return null;
    }
  }

  /// Stream member data (real-time updates)
  Stream<MemberModel?> getMemberStream(String memberId) {
    try {
      return _firestore.collection('members').doc(memberId).snapshots().map((
        doc,
      ) {
        if (doc.exists && doc.data() != null) {
          return MemberModel.fromMap({...doc.data()!, 'id': doc.id});
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error streaming member data: $e');
      return Stream.value(null);
    }
  }

  // ==================== ATTENDANCE METHODS ====================

  /// Get member's attendance history
  Stream<List<AttendanceModel>> getAttendanceByMember(String memberId) {
    try {
      return _firestore
          .collection('attendance')
          .where('memberId', isEqualTo: memberId)
          .orderBy('checkInTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return AttendanceModel.fromMap({...doc.data(), 'id': doc.id});
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting attendance: $e');
      return Stream.value([]);
    }
  }

  /// Get attendance for specific date range
  Future<List<AttendanceModel>> getAttendanceForDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('memberId', isEqualTo: memberId)
          .where(
            'checkInTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            'checkInTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .orderBy('checkInTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      debugPrint('Error getting attendance for date range: $e');
      return [];
    }
  }

  /// Check if member has checked in today
  Future<bool> hasCheckedInToday(String memberId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('attendance')
          .where('memberId', isEqualTo: memberId)
          .where(
            'checkInTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where(
            'checkInTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
          )
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking today attendance: $e');
      return false;
    }
  }

  /// Get attendance count for current month
  Future<int> getMonthlyAttendanceCount(String memberId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _firestore
          .collection('attendance')
          .where('memberId', isEqualTo: memberId)
          .where(
            'checkInTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
          )
          .where(
            'checkInTime',
            isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth),
          )
          .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting monthly attendance count: $e');
      return 0;
    }
  }

  // ==================== ANNOUNCEMENT METHODS ====================

  /// Get all announcements for member's branch
  Stream<List<AnnouncementModel>> getAnnouncements(String branch) {
    try {
      return _firestore
          .collection('announcements')
          .where('targetBranches', arrayContains: branch)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return AnnouncementModel.fromMap(doc.data(), doc.id);
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting announcements: $e');
      return Stream.value([]);
    }
  }

  /// Get all announcements (for all branches)
  Stream<List<AnnouncementModel>> getAllAnnouncements() {
    try {
      return _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return AnnouncementModel.fromMap(doc.data(), doc.id);
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting all announcements: $e');
      return Stream.value([]);
    }
  }

  /// Mark announcement as read
  Future<void> markAnnouncementAsRead(
    String announcementId,
    String memberId,
  ) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([memberId]),
      });
    } catch (e) {
      debugPrint('Error marking announcement as read: $e');
    }
  }

  // ==================== PAYMENT METHODS ====================

  /// Get member's payment history
  Stream<List<PaymentModel>> getPaymentsByMember(String memberId) {
    try {
      return _firestore
          .collection('payments')
          .where('memberId', isEqualTo: memberId)
          .orderBy('paymentDate', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return PaymentModel.fromMap({...doc.data(), 'id': doc.id});
            }).toList();
          });
    } catch (e) {
      debugPrint('Error getting payments: $e');
      return Stream.value([]);
    }
  }

  /// Get payment by ID
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();

      if (doc.exists && doc.data() != null) {
        return PaymentModel.fromMap({...doc.data()!, 'id': doc.id});
      }

      return null;
    } catch (e) {
      debugPrint('Error getting payment: $e');
      return null;
    }
  }

  // ==================== FITNESS DATA METHODS ====================

  /// Save daily fitness data
  Future<void> saveFitnessData(
    String memberId,
    Map<String, dynamic> fitnessData,
  ) async {
    try {
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _firestore
          .collection('fitnessData')
          .doc('${memberId}_$dateKey')
          .set({
            'memberId': memberId,
            'date': Timestamp.fromDate(today),
            ...fitnessData,
            'syncedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving fitness data: $e');
      rethrow;
    }
  }

  /// Get fitness data for date range
  Future<List<Map<String, dynamic>>> getFitnessData(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('fitnessData')
          .where('memberId', isEqualTo: memberId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Error getting fitness data: $e');
      return [];
    }
  }

  /// Stream today's fitness data
  Stream<Map<String, dynamic>?> getTodaysFitnessData(String memberId) {
    try {
      final today = DateTime.now();
      final dateKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      return _firestore
          .collection('fitnessData')
          .doc('${memberId}_$dateKey')
          .snapshots()
          .map((doc) => doc.exists ? doc.data() : null);
    } catch (e) {
      debugPrint('Error streaming today\'s fitness data: $e');
      return Stream.value(null);
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Check if member's subscription is active
  Future<bool> isMembershipActive(String memberId) async {
    try {
      final member = await getMemberById(memberId);
      if (member == null) return false;

      final now = DateTime.now();
      return now.isBefore(member.expiryDate) && !member.isArchived;
    } catch (e) {
      debugPrint('Error checking membership status: $e');
      return false;
    }
  }

  /// Get days until membership expires
  Future<int> getDaysUntilExpiry(String memberId) async {
    try {
      final member = await getMemberById(memberId);
      if (member == null) return 0;

      final now = DateTime.now();
      final difference = member.expiryDate.difference(now);

      return difference.inDays;
    } catch (e) {
      debugPrint('Error calculating days until expiry: $e');
      return 0;
    }
  }
}

// ==================== PAYMENT MODEL ====================
// Add this if you don't have PaymentModel yet

class PaymentModel {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final double cashAmount;
  final double upiAmount;
  final double discount;
  final String paymentMode;
  final DateTime paymentDate;
  final String branch;
  final String? remarks;

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.cashAmount,
    required this.upiAmount,
    required this.discount,
    required this.paymentMode,
    required this.paymentDate,
    required this.branch,
    this.remarks,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      cashAmount: (map['cashAmount'] ?? 0).toDouble(),
      upiAmount: (map['upiAmount'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      paymentMode: map['paymentMode'] ?? 'Cash',
      paymentDate: (map['paymentDate'] as Timestamp).toDate(),
      branch: map['branch'] ?? '',
      remarks: map['remarks'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'cashAmount': cashAmount,
      'upiAmount': upiAmount,
      'discount': discount,
      'paymentMode': paymentMode,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'branch': branch,
      'remarks': remarks,
    };
  }
}
