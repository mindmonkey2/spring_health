import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';
import '../screens/notifications/notifications_screen.dart';
import '../services/in_app_notification_service.dart';

// ── Background handler — must be top-level ────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Phone Background notification: ${message.notification?.title}');
}

// ════════════════════════════════════════════════════════════════
//  NOTIFICATION SERVICE
// ════════════════════════════════════════════════════════════════

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifs = FlutterLocalNotificationsPlugin();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isInitialized = false;

  // ── Public: Initialize ────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // 1. Request permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint(' Notification permission denied');
        return;
      }
      debugPrint('Check Notification permission: ${settings.authorizationStatus}');

      // 2. Local notifications
      await _initLocalNotifications();

      // 3. FCM token
      // await saveFCMToken(); // Removed to avoid missing parameter, it's called explicitly with memberId in main_screen.dart.

      // 4. Message listeners
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onTap);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 5. Cold start tap
      final initial = await _messaging.getInitialMessage();
      if (initial != null) _onTap(initial);

      _isInitialized = true;
      debugPrint('Check Notification service initialized successfully');
    } catch (e) {
      debugPrint(' NotificationService init error: $e');
    }
  }

  // ── Public: Token management ──────────────────────────────────────────────

  /// Call this right after login so the token is always fresh.
  Future<void> saveFCMToken(String memberId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint(' saveFCMToken: no logged-in user');
        return;
      }

      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint(' saveFCMToken: could not get FCM token');
        return;
      }
      debugPrint('Phone FCM Token: $token');

      // ✅ FIX: Save to fcmTokens/{authUid} — NOT members/{authUid}
      // Member docs use custom UUIDs, not Firebase Auth UIDs.
      await _db.collection('fcmTokens').doc(user.uid).set({
        'token': token,
        'uid': user.uid,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ✅ Also update the member doc (look up by user_id field)
      await _updateMemberFcmToken(user.uid, token);

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint(' FCM token refreshed');
        await _db.collection('fcmTokens').doc(user.uid).update({
          'token': newToken,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        await _updateMemberFcmToken(user.uid, newToken);
      });

      debugPrint('Check FCM token saved');
    } catch (e) {
      debugPrint(' Error saving FCM token: $e');
    }
  }

  /// Look up member by user_id (auth UID stored in member doc) and update token.
  Future<void> _updateMemberFcmToken(String uid, String token) async {
    try {
      final snap = await _db
          .collection('members')
          .where('user_id', isEqualTo: uid)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return;

      await snap.docs.first.reference.update({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
      debugPrint('Check Member fcmToken updated');
    } catch (e) {
      // Non-fatal — fcmTokens collection is the source of truth
      debugPrint(' Could not update member fcmToken: $e');
    }
  }

  // ── Public: Topics ────────────────────────────────────────────────────────

  Future<void> subscribeToTopics(String branch) async {
    try {
      await _messaging.subscribeToTopic('announcements_all');
      final slug = branch.toLowerCase().replaceAll(' ', '_');
      await _messaging.subscribeToTopic('announcements_$slug');
      debugPrint('Check Subscribed to topics: all, $branch');
    } catch (e) {
      debugPrint(' Subscribe error: $e');
    }
  }

  Future<void> unsubscribeFromTopics(String branch) async {
    try {
      await _messaging.unsubscribeFromTopic('announcements_all');
      final slug = branch.toLowerCase().replaceAll(' ', '_');
      await _messaging.unsubscribeFromTopic('announcements_$slug');
      debugPrint('Check Unsubscribed from topics');
    } catch (e) {
      debugPrint(' Unsubscribe error: $e');
    }
  }

  // ── Public: Misc ──────────────────────────────────────────────────────────

  Future<void> clearAllNotifications() async => _localNotifs.cancelAll();

  // ── Private: Local notifications init ────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifs.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(' Notification tapped: ${response.payload}');
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
      },
    );

    // Create Android channels
    await _createChannel(
      id: 'high_importance_channel',
      name: 'Announcements',
      description: 'Important announcements from Spring Health',
      importance: Importance.high,
    );
    await _createChannel(
      id: 'payment_channel',
      name: 'Payments',
      description: 'Payment reminders and receipts',
      importance: Importance.high,
    );
    await _createChannel(
      id: 'challenge_channel',
      name: 'Challenges',
      description: 'Clash challenge updates',
      importance: Importance.defaultImportance,
    );

    debugPrint('Check Local notifications initialized');
  }

  Future<void> _createChannel({
    required String id,
    required String name,
    required String description,
    required Importance importance,
  }) async {
    final channel = AndroidNotificationChannel(
      id,
      name,
      description: description,
      importance: importance,
      playSound: true,
      enableVibration: true,
    );
    await _localNotifs
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // ── Private: Message handlers ─────────────────────────────────────────────

  void _onForeground(RemoteMessage message) {
    debugPrint('Phone Foreground: ${message.notification?.title}');
    if (message.notification == null) return;

    final type = message.data['type'] as String? ?? 'announcement';
    final channel = _channelForType(type);

    _showLocalNotification(
      title: message.notification!.title ?? 'Spring Health',
      body: message.notification!.body ?? '',
      payload: message.data['id']?.toString(),
      channelId: channel,
    );

    // Write to in-app feed
    InAppNotificationService().addNotification(
      type: _notifTypeFromString(type),
      title: message.notification!.title ?? 'Spring Health',
      body: message.notification!.body ?? '',
      metadata: Map<String, dynamic>.from(message.data),
    );
  }

  void _onTap(RemoteMessage message) {
    debugPrint(' Notification tapped: ${message.data}');
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  // ── Private: Show local notification ─────────────────────────────────────

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'high_importance_channel',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFFCDFF00),
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifs.show(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  // ── Private: Helpers ──────────────────────────────────────────────────────

  String _channelForType(String type) {
    switch (type) {
      case 'payment':
        return 'payment_channel';
      case 'challenge':
        return 'challenge_channel';
      default:
        return 'high_importance_channel';
    }
  }

  NotificationType _notifTypeFromString(String type) {
    return NotificationType.announcement;
  }
}
