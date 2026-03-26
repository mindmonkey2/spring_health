import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../models/notification_model.dart';
import 'in_app_notification_service.dart';

class MembershipAlertService {
  static final MembershipAlertService _instance =
      MembershipAlertService._internal();
  factory MembershipAlertService() => _instance;
  MembershipAlertService._internal();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────────────────
  // Called from MainScreen.loadMemberData() after member loads
  // Fires once per threshold per expiry cycle — auto-resets on renewal
  // ─────────────────────────────────────────────────────────
  Future<void> checkAndNotify(MemberModel member) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final days = member.daysRemaining;
    final isExpired = member.isExpired;

    // Nothing to do if membership is healthy (> 7 days)
    if (!isExpired && days > 7) return;

    try {
      final alertRef = _db.collection('memberAlerts').doc(uid);
      final alertDoc = await alertRef.get();
      final data = alertDoc.data() ?? {};

      // Key by expiry date — auto-resets tracking when member renews
      final expiryKey =
          '${member.expiryDate.year}-'
          '${member.expiryDate.month.toString().padLeft(2, '0')}-'
          '${member.expiryDate.day.toString().padLeft(2, '0')}';
      final trackedExpiry = data['expiryKey'] as String? ?? '';

      // If expiry date changed (renewed), start fresh tracking
      Map<String, bool> alerted = {};
      if (trackedExpiry == expiryKey) {
        final raw = (data['alerted'] as Map<dynamic, dynamic>? ?? {});
        alerted = raw.map((k, v) => MapEntry(k.toString(), v as bool));
      }

      // Find the first un-alerted threshold in priority order
      String? alertKey;
      String? title;
      String? body;

      if (isExpired && alerted['expired'] != true) {
        alertKey = 'expired';
        title = '⚠️ Membership Expired';
        body =
            'Your ${member.plan} membership has expired. '
            'Visit reception to renew and regain full access.';
      } else if (!isExpired && days <= 1 && alerted['day1'] != true) {
        alertKey = 'day1';
        title = '🚨 Last Day — Membership Expires Today';
        body =
            'Your ${member.plan} membership expires today. '
            'Head to the front desk to renew now.';
      } else if (!isExpired && days <= 3 && alerted['day3'] != true) {
        alertKey = 'day3';
        title = '⏰ Expiring in $days Days';
        body =
            'Your ${member.plan} membership expires in $days days. '
            'Renew soon to avoid any interruption.';
      } else if (!isExpired && days <= 7 && alerted['day7'] != true) {
        alertKey = 'day7';
        title = '📅 Membership Expiring Soon — $days Days Left';
        body =
            'Your ${member.plan} membership expires in $days days. '
            'Plan your renewal early to stay uninterrupted.';
      }

      // Already alerted for every applicable threshold
      if (alertKey == null) return;

      // Write to in-app notification feed (Gym tab)
      await InAppNotificationService().addNotification(
        type: NotificationType.gym,
        title: title!,
        body: body!,
        metadata: {
          'alertType': 'membershipExpiry',
          'daysRemaining': days,
          'expiryDate': member.expiryDate.toIso8601String(),
          'plan': member.plan,
        },
      );

      // Mark this threshold as sent — persist in Firestore
      alerted[alertKey] = true;
      await alertRef.set({
        'expiryKey': expiryKey,
        'alerted': alerted,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('🔔 Membership alert sent: $title');
    } catch (e) {
      debugPrint('⚠️ MembershipAlertService error: $e');
      // Non-fatal — app continues normally
    }
  }
}
