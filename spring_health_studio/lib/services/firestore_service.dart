import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../models/attendance_model.dart';
import '../models/expense_model.dart';
import '../models/diet_plan_model.dart';
import '../models/trainer_feedback_model.dart';
import '../models/payment_model.dart';
import '../models/trainer_model.dart';
import '../models/document_sent_model.dart';


class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== USER METHODS ====================

  Future<Map<String, dynamic>> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() ?? {};
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return {};
    }
  }

  // ==================== MEMBER METHODS ====================

  Future<void> addMember(MemberModel member) async {
    try {
      await _firestore.collection('members').doc(member.id).set(member.toMap());
    } catch (e) {
      debugPrint('Error adding member: $e');
      rethrow;
    }
  }

  Future<void> updateMember(MemberModel member) async {
    try {
      await _firestore.collection('members').doc(member.id).update(member.toMap());
    } catch (e) {
      debugPrint('Error updating member: $e');
      rethrow;
    }
  }

  // ==================== DOCUMENT HISTORY METHODS ====================

  /// Add a document send record to member's history
  Future<void> addDocumentHistory(String memberId, DocumentSentModel document) async {
    try {
      await _firestore.collection('members').doc(memberId).update({
        'documentHistory': FieldValue.arrayUnion([document.toMap()]),
      });
    } catch (e) {
      debugPrint('Error adding document history: $e');
      rethrow;
    }
  }

  /// Add multiple document records at once
  Future<void> addDocumentHistoryBatch(String memberId, List<DocumentSentModel> documents) async {
    try {
      final batch = _firestore.batch();
      final memberRef = _firestore.collection('members').doc(memberId);

      for (var document in documents) {
        batch.update(memberRef, {
          'documentHistory': FieldValue.arrayUnion([document.toMap()]),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding document history batch: $e');
      rethrow;
    }
  }

  /// Get document history for a member
  Future<List<DocumentSentModel>> getDocumentHistory(String memberId) async {
    try {
      final doc = await _firestore.collection('members').doc(memberId).get();

      if (!doc.exists) return [];

      final data = doc.data();
      if (data == null || !data.containsKey('documentHistory')) return [];

      final historyList = data['documentHistory'] as List<dynamic>;
      return historyList
      .map((item) => DocumentSentModel.fromMap(item as Map<String, dynamic>))
      .toList();
    } catch (e) {
      debugPrint('Error getting document history: $e');
      return [];
    }
  }

  /// Clear all document history for a member
  Future<void> clearDocumentHistory(String memberId) async {
    try {
      await _firestore.collection('members').doc(memberId).update({
        'documentHistory': [],
      });
    } catch (e) {
      debugPrint('Error clearing document history: $e');
      rethrow;
    }
  }

  /// Get members who haven't received welcome package
  Future<List<MemberModel>> getMembersWithoutWelcomePackage(String? branch) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
      .collection('members')
      .where('isArchived', isEqualTo: false);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      final members = snapshot.docs
      .map((doc) => MemberModel.fromMap({...doc.data(), 'id': doc.id}))
      .where((member) => !member.hasDocumentBeenSent('welcome'))
      .toList();

      return members;
    } catch (e) {
      debugPrint('Error getting members without welcome package: $e');
      return [];
    }
  }

  /// Get members with recent document sends (last N days)
  Future<List<MemberModel>> getMembersWithRecentDocuments(int days, String? branch) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
      .collection('members')
      .where('isArchived', isEqualTo: false);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      final members = snapshot.docs
      .map((doc) => MemberModel.fromMap({...doc.data(), 'id': doc.id}))
      .where((member) => member.hasDocumentsSentInLastDays(days))
      .toList();

      return members;
    } catch (e) {
      debugPrint('Error getting members with recent documents: $e');
      return [];
    }
  }

  /// Get document history statistics
  Future<Map<String, dynamic>> getDocumentHistoryStats(String? branch) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
      .collection('members')
      .where('isArchived', isEqualTo: false);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      int totalMembers = 0;
      int welcomeSent = 0;
      int rejoinSent = 0;
      int receiptsSent = 0;
      int resendCount = 0;
      int totalDocumentsSent = 0;
      int totalFailed = 0;

      for (var doc in snapshot.docs) {
        final member = MemberModel.fromMap({...doc.data(), 'id': doc.id});
        totalMembers++;

        if (member.hasDocumentBeenSent('welcome')) welcomeSent++;
        if (member.hasDocumentBeenSent('rejoin')) rejoinSent++;
        if (member.hasDocumentBeenSent('receipt')) receiptsSent++;

        resendCount += member.getDocumentsByType('resend').length;
        totalDocumentsSent += member.totalDocumentsSent;
        totalFailed += member.totalFailedDocuments;
      }

      return {
        'totalMembers': totalMembers,
        'welcomePackagesSent': welcomeSent,
        'rejoinPackagesSent': rejoinSent,
        'receiptsSent': receiptsSent,
        'resendCount': resendCount,
        'totalDocumentsSent': totalDocumentsSent,
        'totalFailed': totalFailed,
        'successRate': totalDocumentsSent > 0
        ? ((totalDocumentsSent - totalFailed) / totalDocumentsSent * 100).toStringAsFixed(1)
        : '0.0',
      };
    } catch (e) {
      debugPrint('Error getting document history stats: $e');
      return {
        'totalMembers': 0,
        'welcomePackagesSent': 0,
        'rejoinPackagesSent': 0,
        'receiptsSent': 0,
        'resendCount': 0,
        'totalDocumentsSent': 0,
        'totalFailed': 0,
        'successRate': '0.0',
      };
    }
  }


  Future<MemberModel?> getMemberById(String id) async {
    try {
      final doc = await _firestore.collection('members').doc(id).get();
      if (doc.exists) {
        return MemberModel.fromMap({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      debugPrint('Error getting member: $e');
      return null;
    }
  }

  Future<MemberModel?> getMemberByQrCode(String qrCode) async {
    try {
      final snapshot = await _firestore
      .collection('members')
      .where('qrCode', isEqualTo: qrCode)
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
      debugPrint('Error getting member by QR code: $e');
      return null;
    }
  }

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

  Stream<List<MemberModel>> getAllMembers({bool includeArchived = false}) {
    try {
      Query query = _firestore.collection('members');

      if (!includeArchived) {
        query = query.where('isArchived', isEqualTo: false);
      }

      // NO orderBy
      return query.snapshots().map((snapshot) {
        var members = snapshot.docs.map((doc) {
          return MemberModel.fromMap(
            {...doc.data() as Map<String, dynamic>},
            id: doc.id
          );
        }).toList();

        // Sort in memory
        members.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return members;
      });
    } catch (e) {
      debugPrint('Error getting all members: $e');
      return Stream.value([]);
    }
  }


  Stream<List<MemberModel>> getMembersByBranch(
    String branch,
    {bool includeArchived = false}
  ) {
    try {
      Query query = _firestore
      .collection('members')
      .where('branch', isEqualTo: branch);

      if (!includeArchived) {
        query = query.where('isArchived', isEqualTo: false);
      }

      // NO orderBy to avoid index issues
      return query.snapshots().map((snapshot) {
        var members = snapshot.docs.map((doc) {
          return MemberModel.fromMap(
            {...doc.data() as Map<String, dynamic>},
            id: doc.id
          );
        }).toList();

        // Sort in memory
        members.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return members;
      });
    } catch (e) {
      debugPrint('Error getting members by branch: $e');
      return Stream.value([]);
    }
  }



  Stream<List<MemberModel>> getMembers({String? branch}) {
    try {
      Query query = _firestore.collection('members');

      // Filter by branch if provided
      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      // Filter out archived members
      query = query.where('isArchived', isEqualTo: false);

      // NO orderBy! Sort in memory instead
      return query.snapshots().map((snapshot) {
        var members = snapshot.docs.map((doc) {
          return MemberModel.fromMap(
            {...doc.data() as Map<String, dynamic>},
            id: doc.id
          );
        }).toList();

        // Sort by createdAt in memory
        members.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return members;
      });
    } catch (e) {
      debugPrint('Error getting members: $e');
      return Stream.value([]);
    }
  }


  // Add this method
  Stream<List<MemberModel>> getArchivedMembers({String? branch}) {
    try {
      Query query = _firestore
      .collection('members')
      .where('isArchived', isEqualTo: true);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      // IMPORTANT: NO .orderBy() here!
      return query.snapshots().map((snapshot) {
        var members = snapshot.docs.map((doc) {
          return MemberModel.fromMap(
            {...doc.data() as Map<String, dynamic>},
            id: doc.id
          );
        }).toList();

        // Sort in memory
        members.sort((a, b) => a.name.compareTo(b.name));

        return members;
      });
    } catch (e) {
      debugPrint('Error getting archived members: $e');
      return Stream.value([]);
    }
  }




  // ==================== TRAINER METHODS ====================

  Future<void> addTrainer(TrainerModel trainer) async {
    try {
      await _firestore.collection('trainers').doc(trainer.id).set(trainer.toMap());
    } catch (e) {
      debugPrint('Error adding trainer: $e');
      rethrow;
    }
  }

  Future<void> updateTrainer(TrainerModel trainer) async {
    try {
      await _firestore.collection('trainers').doc(trainer.id).update(trainer.toMap());
    } catch (e) {
      debugPrint('Error updating trainer: $e');
      rethrow;
    }
  }

  Future<TrainerModel?> getTrainerById(String id) async {
    try {
      final doc = await _firestore.collection('trainers').doc(id).get();
      if (doc.exists) {
        return TrainerModel.fromMap({...doc.data()!}, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting trainer: $e');
      return null;
    }
  }

  Stream<List<TrainerModel>> getAllTrainers({String? branch}) {
    try {
      Query query = _firestore
      .collection('trainers')
      .where('isActive', isEqualTo: true)
      .orderBy('name');

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return TrainerModel.fromMap({...doc.data() as Map<String, dynamic>}, doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting trainers: $e');
      return Stream.value([]);
    }
  }

  Stream<List<TrainerModel>> getTrainersByBranch(String branch) {
    try {
      return _firestore
      .collection('trainers')
      .where('branch', isEqualTo: branch)
      .where('isActive', isEqualTo: true)
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return TrainerModel.fromMap({...doc.data()}, doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting trainers by branch: $e');
      return Stream.value([]);
    }
  }

  // Assign a member to a trainer
  Future<void> assignMemberToTrainer(String trainerId, String memberId) async {
    try {
      await _firestore.collection('trainers').doc(trainerId).update({
        'assignedMembers': FieldValue.arrayUnion([memberId]),
      });

      // Also update member with trainer info
      await _firestore.collection('members').doc(memberId).update({
        'trainerId': trainerId,
      });
    } catch (e) {
      debugPrint('Error assigning member to trainer: $e');
      rethrow;
    }
  }

  // Remove a member from trainer
  Future<void> removeMemberFromTrainer(String trainerId, String memberId) async {
    try {
      await _firestore.collection('trainers').doc(trainerId).update({
        'assignedMembers': FieldValue.arrayRemove([memberId]),
      });

      // Remove trainer from member
      await _firestore.collection('members').doc(memberId).update({
        'trainerId': null,
      });
    } catch (e) {
      debugPrint('Error removing member from trainer: $e');
      rethrow;
    }
  }

  // Get members assigned to a trainer
  Stream<List<MemberModel>> getMembersByTrainer(String trainerId) {
    try {
      return _firestore
      .collection('members')
      .where('trainerId', isEqualTo: trainerId)
      .where('isArchived', isEqualTo: false)
      .orderBy('name')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return MemberModel.fromMap({...doc.data()}, id: doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting members by trainer: $e');
      return Stream.value([]);
    }
  }

  // Get trainer statistics
  Future<Map<String, dynamic>> getTrainerStats(String trainerId) async {
    try {
      final trainer = await getTrainerById(trainerId);
      if (trainer == null) return {};

      final members = await getMembersByTrainer(trainerId).first;
      final activeMembers = members.where((m) => m.isActive).length;
      final totalMembers = members.length;

      return {
        'totalAssigned': totalMembers,
        'activeMembers': activeMembers,
        'inactiveMembers': totalMembers - activeMembers,
        'specialization': trainer.specialization,
      };
    } catch (e) {
      debugPrint('Error getting trainer stats: $e');
      return {};
    }
  }

  // ==================== ATTENDANCE METHODS ====================

  /// ✅ NEW: Record attendance from QR scan (main method for QR scanner)
  Future<void> recordAttendance(AttendanceModel attendance) async {
    await addAttendance(attendance);
  }

  Future addAttendance(AttendanceModel attendance) async {
    try {
      // Check if already checked in today
      final alreadyCheckedIn = await hasCheckedInToday(attendance.memberId, attendance.branch);
      if (alreadyCheckedIn) {
        throw Exception('Member has already checked in today');
      }

      await _firestore.collection('attendance').doc(attendance.id).set(attendance.toMap());

      // Update member's last check-in
      await _firestore.collection('members').doc(attendance.memberId).update({
        'lastCheckIn': Timestamp.fromDate(attendance.checkInTime),
      });
    } catch (e) {
      debugPrint('Error adding attendance: $e');
      rethrow;
    }
  }

  Future<bool> hasCheckedInToday(String memberId, String branch) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore
      .collection('attendance')
      .where('memberId', isEqualTo: memberId)
      .where('branch', isEqualTo: branch)
      .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('checkInTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .limit(1)
      .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking today attendance: $e');
      return false;
    }
  }

  Stream<List<AttendanceModel>> getAttendanceByMember(String memberId, {String? branch}) {
    try {
      Query query = _firestore
      .collection('attendance')
      .where('memberId', isEqualTo: memberId);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      query = query.orderBy('checkInTime', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return AttendanceModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting attendance by member: $e');
      return Stream.value([]);
    }
  }

  Stream<List<AttendanceModel>> getAttendanceByBranch(String branch, DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return _firestore
      .collection('attendance')
      .where('branch', isEqualTo: branch)
      .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('checkInTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .orderBy('checkInTime', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return AttendanceModel.fromMap({...doc.data(), 'id': doc.id});
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting attendance by branch: $e');
      return Stream.value([]);
    }
  }

  Stream<List<AttendanceModel>> getAttendanceForDateRange(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      Query query = _firestore.collection('attendance')
      .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('checkInTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
      .orderBy('checkInTime', descending: true);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return AttendanceModel.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting attendance for date range: $e');
      return Stream.value([]);
    }
  }

  Future<int> getTodayCheckInsCount(String branch) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final snapshot = await _firestore.collection('attendance')
      .where('branch', isEqualTo: branch)
      .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .where('checkInTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
      .get();

      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting today check-ins count: $e');
      return 0;
    }
  }

  /// ✅ NEW: Get recent check-ins for display
  Future<List<AttendanceModel>> getRecentCheckIns(String? branch, {int limit = 10}) async {
    try {
      Query query = _firestore
      .collection('attendance')
      .orderBy('checkInTime', descending: true)
      .limit(limit);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return AttendanceModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } catch (e) {
      debugPrint('Error getting recent check-ins: $e');
      return [];
    }
  }


  // ==================== PAYMENT METHODS ====================

  Future<void> addPayment(PaymentModel payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).set(payment.toMap());
    } catch (e) {
      debugPrint('Error adding payment: $e');
      rethrow;
    }
  }

  Stream<List<PaymentModel>> getPaymentsByMember(String memberId, {String? branch}) {
    try {
      Query query = _firestore
      .collection('payments')
      .where('memberId', isEqualTo: memberId);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      query = query.orderBy('paymentDate', descending: true);

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return PaymentModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id});
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting payments by member: $e');
      return Stream.value([]);
    }
  }

  Stream<List<PaymentModel>> getPaymentsForDateRange(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      Query query = _firestore.collection('payments')
      .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
      .orderBy('paymentDate', descending: true);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return PaymentModel.fromMap({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting payments for date range: $e');
      return Stream.value([]);
    }
  }

  Future<Map<String, dynamic>> getMonthlyRevenue(String? branch) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      Query query = _firestore.collection('payments')
      .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
      .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      double totalRevenue = 0;
      double cashRevenue = 0;
      double upiRevenue = 0;
      double totalDiscount = 0; // ✅ NEW: Monthly discount

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRevenue += (data['amount'] ?? 0).toDouble();
        cashRevenue += (data['cashAmount'] ?? 0).toDouble();
        upiRevenue += (data['upiAmount'] ?? 0).toDouble();
        totalDiscount += (data['discount'] ?? 0).toDouble(); // ✅ NEW: Sum discount
      }

      return {
        'total': totalRevenue,
        'cash': cashRevenue,
        'upi': upiRevenue,
        'discount': totalDiscount, // ✅ NEW: Return monthly discount
      };
    } catch (e) {
      debugPrint('Error getting monthly revenue: $e');
      return {'total': 0, 'cash': 0, 'upi': 0, 'discount': 0}; // ✅ NEW: Default discount
    }
  }

  Future<Map<String, dynamic>> getRevenueForDateRange(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      Query query = _firestore.collection('payments')
      .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      final payments = snapshot.docs
      .map((doc) => PaymentModel.fromMap({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
      .toList();

      final total = payments.fold(0.0, (acc, p) => acc + p.amount);
      final cash = payments.fold(0.0, (acc, p) => acc + p.cashAmount);
      final upi = payments.fold(0.0, (acc, p) => acc + p.upiAmount);

      return {
        'total': total,
        'cash': cash,
        'upi': upi,
        'count': payments.length,
      };
    } catch (e) {
      debugPrint('Error getting revenue for date range: $e');
      return {'total': 0.0, 'cash': 0.0, 'upi': 0.0, 'count': 0};
    }
  }

  // ==================== DASHBOARD STATS ====================

  Future<Map<String, dynamic>> getDashboardStats(String? branch) async {
    try {
      Query membersQuery = _firestore.collection('members').where('isArchived', isEqualTo: false);

      if (branch != null) {
        membersQuery = membersQuery.where('branch', isEqualTo: branch);
      }

      final membersSnapshot = await membersQuery.get();
      final members = membersSnapshot.docs.map((doc) {
        return MemberModel.fromJson(
          {...doc.data() as Map<String, dynamic>, 'id': doc.id},
        );
      }).toList();

      final now = DateTime.now();
      int totalMembers = members.length;
      int activeMembers = members.where((m) => now.isBefore(m.expiryDate)).length;

      int nearExpiry = members.where((m) {
        final daysLeft = m.expiryDate.difference(now).inDays;
        return daysLeft >= 0 && daysLeft <= 7 && now.isBefore(m.expiryDate);
      }).length;

      double totalDues = 0;
      double totalRevenue = 0;
      double cashRevenue = 0;
      double upiRevenue = 0;
      double totalDiscount = 0;
      int membersWithDues = 0;

      for (var member in members) {
        totalDues += member.dueAmount;
        totalRevenue += (member.finalAmount - member.dueAmount);
        cashRevenue += member.cashAmount;
        upiRevenue += member.upiAmount;
        totalDiscount += member.discount;
        if (member.dueAmount > 0) {
          membersWithDues++;
        }
      }

      return {
        'totalMembers': totalMembers,
        'activeMembers': activeMembers,
        'nearExpiry': nearExpiry,
        'totalDues': totalDues,
        'totalRevenue': totalRevenue,
        'cashRevenue': cashRevenue,
        'upiRevenue': upiRevenue,
        'totalDiscount': totalDiscount,
        'membersWithDues': membersWithDues,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'totalMembers': 0,
        'activeMembers': 0,
        'nearExpiry': 0,
        'totalDues': 0,
        'totalRevenue': 0,
        'cashRevenue': 0,
        'upiRevenue': 0,
        'totalDiscount': 0,
        'membersWithDues': 0,
      };
    }
  }

  Future<Map<String, Map<String, dynamic>>> getBranchWiseStats() async {
    try {
      final branches = ['Hanamkonda', 'Warangal'];
      final Map<String, Map<String, dynamic>> branchStats = {};

      for (var branch in branches) {
        final stats = await getDashboardStats(branch);
        branchStats[branch] = stats;
      }

      return branchStats;
    } catch (e) {
      debugPrint('Error getting branch-wise stats: $e');
      return {};
    }
  }

  // ✅ ADDED: getStatistics method for analytics
  Future<Map<String, dynamic>> getStatistics(String? branch) async {
    try {
      Query query = _firestore.collection('members').where('isArchived', isEqualTo: false);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      int totalMembers = 0;
      int activeMembers = 0;
      final now = DateTime.now();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalMembers++;

        final expiryDate = (data['expiryDate'] as Timestamp).toDate();
        if (now.isBefore(expiryDate)) {
          activeMembers++;
        }
      }

      return {
        'totalMembers': totalMembers,
        'activeMembers': activeMembers,
      };
    } catch (e) {
      debugPrint('Error getting statistics: $e');
      return {
        'totalMembers': 0,
        'activeMembers': 0,
      };
    }
  }

  Future<int> getMembersWithDuesCount(String? branch) async {
    try {
      Query query = _firestore.collection('members')
      .where('dueAmount', isGreaterThan: 0)
      .where('isArchived', isEqualTo: false);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting members with dues count: $e');
      return 0;
    }
  }

  // ==================== EXPENSE METHODS ====================

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').doc(expense.id).set(expense.toMap());
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').doc(expense.id).update(expense.toMap());
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  Stream<List<ExpenseModel>> getExpenses(String? branch) {
    try {
      Query query = _firestore.collection('expenses').orderBy('expenseDate', descending: true);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting expenses: $e');
      return Stream.value([]);
    }
  }

  Stream<List<ExpenseModel>> getExpensesForDateRange(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      Query query = _firestore.collection('expenses')
      .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('expenseDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
      .orderBy('expenseDate', descending: true);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      debugPrint('Error getting expenses for date range: $e');
      return Stream.value([]);
    }
  }

  Future<double> getTotalExpenses(String? branch, DateTime startDate, DateTime endDate) async {
    try {
      Query query = _firestore.collection('expenses')
      .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('expenseDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        total += (data['amount'] ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      debugPrint('Error getting total expenses: $e');
      return 0;
    }
  }

  Future<Map<String, double>> getExpensesByCategory(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      Query query = _firestore.collection('expenses')
      .where('expenseDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('expenseDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      Map<String, double> categoryTotals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final category = data['category'] as String;
        final amount = (data['amount'] ?? 0).toDouble();

        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      return categoryTotals;
    } catch (e) {
      debugPrint('Error getting expenses by category: $e');
      return {};
    }
  }

  // ==================== ANALYTICS METHODS ====================

  Future<Map<String, double>> getDailyRevenue(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      Query query = _firestore.collection('payments')
      .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      Map<String, double> dailyRevenue = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['paymentDate'] as Timestamp).toDate();
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final amount = (data['amount'] ?? 0).toDouble();

        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + amount;
      }

      return dailyRevenue;
    } catch (e) {
      debugPrint('Error getting daily revenue: $e');
      return {};
    }
  }

  Future<Map<String, int>> getMemberGrowth(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      Query query = _firestore.collection('members')
      .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
      .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
      .where('isArchived', isEqualTo: false);

      if (branch != null) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();

      Map<String, int> growth = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['createdAt'] as Timestamp).toDate();
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        growth[dateKey] = (growth[dateKey] ?? 0) + 1;
      }

      return growth;
    } catch (e) {
      debugPrint('Error getting member growth: $e');
      return {};
    }
  }

  // ==================== TRAINER ROLE METHODS ====================

  /// Fetch members assigned to the logged-in trainer respecting branch
  Future<List<MemberModel>> getAssignedMembers(String branch, List<String> assignedIds) async {
    if (assignedIds.isEmpty) return [];
    try {
      final snapshot = await _firestore.collection('members')
          .where('branch', isEqualTo: branch)
          .where('isArchived', isEqualTo: false)
          .where(FieldPath.documentId, whereIn: assignedIds)
          .get();

      return snapshot.docs
          .map((doc) => MemberModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting assigned members: $e');
      return [];
    }
  }

  /// Create or update a diet plan using WriteBatch
  Future<void> saveDietPlan(DietPlanModel dietPlan) async {
    try {
      final batch = _firestore.batch();
      final docRef = _firestore.collection('dietPlans').doc(dietPlan.id);

      batch.set(docRef, dietPlan.toMap(), SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      debugPrint('Error saving diet plan: $e');
      rethrow;
    }
  }

  /// Get diet plans for a member
  Stream<List<DietPlanModel>> getDietPlans(String memberId) {
    return _firestore.collection('dietPlans')
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DietPlanModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Fetch trainer feedback
  Stream<List<TrainerFeedbackModel>> getTrainerFeedback(String trainerId) {
    return _firestore.collection('trainers')
        .doc(trainerId)
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainerFeedbackModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Reply to trainer feedback
  Future<void> replyToFeedback(String trainerId, String feedbackId, String reply) async {
    try {
      await _firestore.collection('trainers')
          .doc(trainerId)
          .collection('feedback')
          .doc(feedbackId)
          .update({'trainerReply': reply});
    } catch (e) {
      debugPrint('Error replying to feedback: $e');
      rethrow;
    }
  }


  Future<Map<String, dynamic>> getProfitLoss(
    String? branch,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final revenue = await getRevenueForDateRange(branch, startDate, endDate);
      final expenses = await getTotalExpenses(branch, startDate, endDate);

      final totalRevenue = revenue['total'] ?? 0;
      final profit = totalRevenue - expenses;

      return {
        'revenue': totalRevenue,
        'expenses': expenses,
        'profit': profit,
        'profitMargin': totalRevenue > 0 ? (profit / totalRevenue) * 100 : 0,
      };
    } catch (e) {
      debugPrint('Error getting profit/loss: $e');
      return {
        'revenue': 0,
        'expenses': 0,
        'profit': 0,
        'profitMargin': 0,
      };
    }
  }
}
