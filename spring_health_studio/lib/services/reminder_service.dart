import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import 'whatsapp_service.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get members with pending dues
  Future<List<MemberModel>> getMembersWithDues({String? branch}) async {
    try {
      Query query = _firestore.collection('members').where('isActive', isEqualTo: true);

      if (branch != null && branch.isNotEmpty) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();
      final members = snapshot.docs
      .map((doc) => MemberModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
      .where((member) => member.dueAmount > 0)
      .toList();

      return members;
    } catch (e) {
      debugPrint('Error fetching members with dues: $e');
      return [];
    }
  }

  // Get members expiring in next X days
  Future<List<MemberModel>> getMembersExpiringSoon({
    required int days,
    String? branch,
  }) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final endDate = startOfToday.add(Duration(days: days));

      Query query = _firestore.collection('members').where('isActive', isEqualTo: true);

      if (branch != null && branch.isNotEmpty) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();
      final members = snapshot.docs
      .map((doc) => MemberModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
      .where((member) {
        final expiryDate = DateTime(
          member.expiryDate.year,
          member.expiryDate.month,
          member.expiryDate.day,
        );

        // Check if expiring between today and endDate (inclusive)
        return (expiryDate.isAfter(startOfToday.subtract(const Duration(days: 1))) &&
        expiryDate.isBefore(endDate.add(const Duration(days: 1))));
      }).toList();

      // Sort by expiry date (earliest first)
      members.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

      return members;
    } catch (e) {
      debugPrint('Error fetching expiring members: $e');
      return [];
    }
  }

  // Get members with birthdays today
  Future<List<MemberModel>> getTodayBirthdays({String? branch}) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      Query query = _firestore.collection('members').where('isActive', isEqualTo: true);

      if (branch != null && branch.isNotEmpty) {
        query = query.where('branch', isEqualTo: branch);
      }

      final snapshot = await query.get();
      final members = snapshot.docs
      .map((doc) => MemberModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
      .where((member) {
        if (member.dateOfBirth == null) return false;
        return member.dateOfBirth!.month == today.month &&
        member.dateOfBirth!.day == today.day;
      }).toList();

      return members;
    } catch (e) {
      debugPrint('Error fetching birthday members: $e');
      return [];
    }
  }

  // Send dues reminder to single member
  Future<bool> sendDuesReminder(MemberModel member) async {
    try {
      await WhatsAppService.sendDuePaymentReminder(member);

      // Log reminder
      await _logReminder(
        memberId: member.id,
        type: 'dues',
        status: 'sent',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending dues reminder: $e');
      await _logReminder(
        memberId: member.id,
        type: 'dues',
        status: 'failed',
        error: e.toString(),
      );
      return false;
    }
  }

  // Send expiry reminder to single member
  Future<bool> sendExpiryReminder(MemberModel member, {required int daysLeft}) async {
    try {
      await WhatsAppService.sendExpiryReminder(member, daysLeft);

      // Log reminder
      await _logReminder(
        memberId: member.id,
        type: 'expiry',
        status: 'sent',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending expiry reminder: $e');
      await _logReminder(
        memberId: member.id,
        type: 'expiry',
        status: 'failed',
        error: e.toString(),
      );
      return false;
    }
  }

  // Send birthday wish to single member
  Future<bool> sendBirthdayWish(MemberModel member) async {
    try {
      await WhatsAppService.sendBirthdayWish(member);

      // Log reminder
      await _logReminder(
        memberId: member.id,
        type: 'birthday',
        status: 'sent',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending birthday wish: $e');
      await _logReminder(
        memberId: member.id,
        type: 'birthday',
        status: 'failed',
        error: e.toString(),
      );
      return false;
    }
  }

  // Send bulk dues reminders
  Future<Map<String, int>> sendBulkDuesReminders({String? branch}) async {
    final members = await getMembersWithDues(branch: branch);
    int sent = 0;
    int failed = 0;

    for (var member in members) {
      final success = await sendDuesReminder(member);
      if (success) {
        sent++;
      } else {
        failed++;
      }

      // Small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return {
      'total': members.length,
      'sent': sent,
      'failed': failed,
    };
  }

  // Send bulk expiry reminders
  Future<Map<String, int>> sendBulkExpiryReminders({required int days, String? branch}) async {
    final members = await getMembersExpiringSoon(days: days, branch: branch);
    int sent = 0;
    int failed = 0;

    for (var member in members) {
      final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
      final success = await sendExpiryReminder(member, daysLeft: daysLeft);

      if (success) {
        sent++;
      } else {
        failed++;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return {
      'total': members.length,
      'sent': sent,
      'failed': failed,
    };
  }

  // Send bulk birthday wishes
  Future<Map<String, int>> sendBulkBirthdayWishes({String? branch}) async {
    final members = await getTodayBirthdays(branch: branch);
    int sent = 0;
    int failed = 0;

    for (var member in members) {
      final success = await sendBirthdayWish(member);

      if (success) {
        sent++;
      } else {
        failed++;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return {
      'total': members.length,
      'sent': sent,
      'failed': failed,
    };
  }

  // Log reminder activity
  Future<void> _logReminder({
    required String memberId,
    required String type,
    required String status,
    String? error,
  }) async {
    try {
      await _firestore.collection('reminder_logs').add({
        'memberId': memberId,
        'type': type,
        'status': status,
        'error': error,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging reminder: $e');
    }
  }

  // Get message templates
  Map<String, String> getMessageTemplates() {
    return {
      'dues_payment': '''
      💰 *Payment Reminder* 💰

      Hi [Member Name]!

      You have a pending payment at *Spring Health Studio*.

      *Payment Details:*
      ⚠️ Due Amount: ₹[Amount]
      📅 Membership: [Start Date] to [End Date]

      *Please clear your dues at the earliest.*

      Visit our [Branch] branch or contact us to make the payment.

      Thank you! 🙏

      *Spring Health Studio*
      [Branch] Branch
      ''',
      'expiry_3_days': '''
      ⚠️ *Membership Expiring Soon!* ⚠️

      Hi [Member Name]!

      Your membership at *Spring Health Studio* is expiring soon!

      *Current Membership:*
      📅 Valid Till: [Expiry Date]
      ⏰ Days Remaining: 3 days

      *Don't Miss Out!*
      ✅ Renew now to continue your fitness journey
      ✅ Contact us to renew your membership
      ✅ Visit our [Branch] branch

      Stay consistent, stay fit! 💪

      *Spring Health Studio*
      [Branch] Branch
      ''',
      'expiry_1_day': '''
      🚨 *Membership Expiring Tomorrow!* 🚨

      Hi [Member Name]!

      Your membership at *Spring Health Studio* expires tomorrow!

      *Current Membership:*
      📅 Valid Till: [Expiry Date]
      ⏰ Days Remaining: 1 day

      *Act Now!*
      ✅ Renew today to avoid interruption
      ✅ Contact us immediately
      ✅ Visit our [Branch] branch

      Stay consistent, stay fit! 💪

      *Spring Health Studio*
      [Branch] Branch
      ''',
      'birthday': '''
      🎂🎉 *HAPPY BIRTHDAY!* 🎉🎂

      Dear [Member Name]!

      Wishing you a fantastic birthday filled with joy, health, and happiness! 🥳

      May this year bring you:
      💪 Stronger muscles
      🏃 Better stamina
      😊 Great health
      🎯 Achieved fitness goals

      Thank you for being a valued member of our fitness family!

      Enjoy your special day! 🎈

      *Spring Health Studio Team*
      [Branch] Branch

      *PS:* Visit us today and get a special birthday surprise! 🎁
      ''',
    };
  }

  // Get reminder statistics
  Future<Map<String, int>> getReminderStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _firestore
      .collection('reminder_logs')
      .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
      .get();

      final logs = snapshot.docs;

      return {
        'total': logs.length,
        'sent': logs.where((doc) => doc.data()['status'] == 'sent').length,
        'failed': logs.where((doc) => doc.data()['status'] == 'failed').length,
        'dues': logs.where((doc) => doc.data()['type'] == 'dues').length,
        'expiry': logs.where((doc) => doc.data()['type'] == 'expiry').length,
        'birthday': logs.where((doc) => doc.data()['type'] == 'birthday').length,
      };
    } catch (e) {
      debugPrint('Error fetching reminder stats: $e');
      return {
        'total': 0,
        'sent': 0,
        'failed': 0,
        'dues': 0,
        'expiry': 0,
        'birthday': 0,
      };
    }
  }

  // Send rejoin message to single expired member
  Future<bool> sendRejoinMessage(MemberModel member) async {
    try {
      await WhatsAppService.sendRejoinMessage(member);

      // Log reminder
      await _logReminder(
        memberId: member.id,
        type: 'rejoin',
        status: 'sent',
      );

      return true;
    } catch (e) {
      debugPrint('Error sending rejoin message: $e');
      await _logReminder(
        memberId: member.id,
        type: 'rejoin',
        status: 'failed',
        error: e.toString(),
      );
      return false;
    }
  }

  // Send bulk rejoin messages to expired members
  Future<Map<String, int>> sendBulkRejoinMessages({String? branch}) async {
    // Get expired members
    Query query = _firestore.collection('members').where('isActive', isEqualTo: true);

    if (branch != null && branch.isNotEmpty) {
      query = query.where('branch', isEqualTo: branch);
    }

    final snapshot = await query.get();
    final allMembers = snapshot.docs
    .map((doc) => MemberModel.fromMap(doc.data() as Map<String, dynamic>, id: doc.id))
    .toList();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final expiredMembers = allMembers.where((member) {
      final expiryDate = DateTime(
        member.expiryDate.year,
        member.expiryDate.month,
        member.expiryDate.day,
      );
      return expiryDate.isBefore(today);
    }).toList();

    int sent = 0;
    int failed = 0;

    for (var member in expiredMembers) {
      final success = await sendRejoinMessage(member);

      if (success) {
        sent++;
      } else {
        failed++;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return {
      'total': expiredMembers.length,
      'sent': sent,
      'failed': failed,
    };
  }
}
