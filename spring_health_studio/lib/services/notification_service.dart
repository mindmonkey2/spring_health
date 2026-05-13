import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../services/firestore_service.dart';
import '../services/whatsapp_service.dart';

// Typed result instead of Map<String, List<String>> magic strings
class ExpiryReminderResult {
  final List<String> sevenDays;
  final List<String> threeDays;
  final List<String> oneDay;

  const ExpiryReminderResult({
    this.sevenDays = const [],
    this.threeDays = const [],
    this.oneDay = const [],
  });

  int get total => sevenDays.length + threeDays.length + oneDay.length;
}

class DailyReminderSummary {
  final List<String> birthdaysSent;
  final ExpiryReminderResult expirySent;
  final List<String> duesSent;

  const DailyReminderSummary({
    required this.birthdaysSent,
    required this.expirySent,
    required this.duesSent,
  });
}

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  final FirestoreService _firestoreService;
  final WhatsAppService _whatsAppService;

  NotificationService({FirestoreService? firestoreService, WhatsAppService? whatsAppService})
      : _firestoreService = firestoreService ?? FirestoreService.instance,
        _whatsAppService = whatsAppService ?? WhatsAppService.instance;

  NotificationService._internal()
      : _firestoreService = FirestoreService.instance,
        _whatsAppService = WhatsAppService.instance;

  // FIX 1: Centralized delay constant — easy to tune without hunting the file
  static const _kRateLimitDelay = Duration(seconds: 2);

  // FIX 2: Helper to normalize DateTime to date-only (removes time component)
  // Prevents inDays returning wrong value when expiry is midnight vs 11:59 PM
  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // FIX 3: Shared member fetch — avoids creating multiple Firestore connections
  // when _getMembers is called from multiple methods in the same session
  Future<List<MemberModel>> _getMembers(String? branch) =>
      _firestoreService.getMembers(branch: branch).first;

  // ─── Birthday Wishes ────────────────────────────────────────────────────────

  Future<List<String>> sendBirthdayWishes({
    String? branch,
    List<MemberModel>? membersList,
  }) async {
    try {
      final members = membersList ?? await _getMembers(branch);
      final today = _dateOnly(DateTime.now());

      final birthdayMembers = members.where((m) {
        if (m.dateOfBirth == null) return false;
        return m.dateOfBirth!.month == today.month &&
            m.dateOfBirth!.day == today.day;
      }).toList();

      final sentTo = <String>[];
      for (final member in birthdayMembers) {
        final sent = await _whatsAppService.sendBirthdayWish(member);
        if (sent) sentTo.add(member.name);
        await Future.delayed(_kRateLimitDelay);
      }

      debugPrint(
          'Birthday wishes sent: ${sentTo.length}/${birthdayMembers.length}');
      return sentTo;
    } catch (e) {
      debugPrint('Error sending birthday wishes: $e');
      return [];
    }
  }

  // ─── Expiry Reminders ───────────────────────────────────────────────────────

  Future<ExpiryReminderResult> sendExpiryReminders({
    String? branch,
    List<MemberModel>? membersList,
  }) async {
    try {
      final members = membersList ?? await _getMembers(branch);
      final today = _dateOnly(DateTime.now());

      final expiring7 = <MemberModel>[];
      final expiring3 = <MemberModel>[];
      final expiring1 = <MemberModel>[];

      for (final member in members) {
        final expiryDay = _dateOnly(member.expiryDate);
        // FIX 4: Only consider future/today expiries
        if (!expiryDay.isBefore(today)) {
          final daysLeft = expiryDay.difference(today).inDays;
          // FIX 5: Range check (<=) instead of exact match (==)
          // Catches members that were missed if app wasn't opened on exact day
          if (daysLeft <= 1) {
            expiring1.add(member);
          } else if (daysLeft <= 3) {
            expiring3.add(member);
          } else if (daysLeft <= 7) {
            expiring7.add(member);
          }
        }
      }

      // FIX 6: Send in priority order — most urgent first
      Future<List<String>> sendBatch(List<MemberModel> batch, int days) async {
        final sent = <String>[];
        for (final m in batch) {
          if (await _whatsAppService.sendExpiryReminder(m, days)) {
            sent.add(m.name);
          }
          await Future.delayed(_kRateLimitDelay);
        }
        return sent;
      }

      final oneDay = await sendBatch(expiring1, 1);
      final threeDays = await sendBatch(expiring3, 3);
      final sevenDays = await sendBatch(expiring7, 7);

      final result = ExpiryReminderResult(
        sevenDays: sevenDays,
        threeDays: threeDays,
        oneDay: oneDay,
      );

      debugPrint('Expiry reminders sent: ${result.total}');
      return result;
    } catch (e) {
      debugPrint('Error sending expiry reminders: $e');
      return const ExpiryReminderResult();
    }
  }

  // ─── Due Payment Reminders ──────────────────────────────────────────────────

  Future<List<String>> sendDuePaymentReminders({
    String? branch,
    List<MemberModel>? membersList,
  }) async {
    try {
      final members = membersList ?? await _getMembers(branch);
      final membersWithDues = members.where((m) => m.dueAmount > 0).toList();

      final sentTo = <String>[];
      for (final member in membersWithDues) {
        final sent = await _whatsAppService.sendDuePaymentReminder(member);
        if (sent) sentTo.add(member.name);
        await Future.delayed(_kRateLimitDelay);
      }

      debugPrint(
          'Due reminders sent: ${sentTo.length}/${membersWithDues.length}');
      return sentTo;
    } catch (e) {
      debugPrint('Error sending due payment reminders: $e');
      return [];
    }
  }

  // ─── Combined Daily Runner ──────────────────────────────────────────────────


  // ─── Combined Daily Runner ──────────────────────────────────────────────────

  // FIX 7: runDailyReminders() — single entry point for the daily cron-style run
  // Call this from app startup or a manual "Run All" button in the dashboard
  Future<DailyReminderSummary> runDailyReminders({String? branch}) async {
    debugPrint('--- Running daily reminders [branch: ${branch ?? "all"}] ---');

    // Optimization: fetch members once
    final members = await _getMembers(branch);

    final birthdays =
        await sendBirthdayWishes(branch: branch, membersList: members);
    final expiry =
        await sendExpiryReminders(branch: branch, membersList: members);
    final dues =
        await sendDuePaymentReminders(branch: branch, membersList: members);

    final summary = DailyReminderSummary(
      birthdaysSent: birthdays,
      expirySent: expiry,
      duesSent: dues,
    );

    debugPrint(
      'Daily reminders done — '
      'Birthdays: ${birthdays.length}, '
      'Expiry: ${expiry.total}, '
      'Dues: ${dues.length}',
    );

    return summary;
  }
}
