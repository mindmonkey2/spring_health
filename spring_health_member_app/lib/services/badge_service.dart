import 'package:cloud_firestore/cloud_firestore.dart';
import 'in_app_notification_service.dart';
import '../models/notification_model.dart';
import 'firebase_auth_service.dart';

class BadgeService {
  static final BadgeService instance = BadgeService._internal();
  BadgeService._internal();

  static const List<Map<String, dynamic>> badgeDefinitions = [
    {'id': 'first_checkin',  'label': 'First Step',        'type': 'checkins',      'threshold': 1},
    {'id': 'streak_7',       'label': '7-Day Warrior',     'type': 'streak',        'threshold': 7},
    {'id': 'streak_30',      'label': 'Iron Consistent',   'type': 'streak',        'threshold': 30},
    {'id': 'xp_500',         'label': 'Rising Star',       'type': 'xp',            'threshold': 500},
    {'id': 'xp_2000',        'label': 'XP Beast',          'type': 'xp',            'threshold': 2000},
    {'id': 'workouts_10',    'label': 'Dedicated Lifter',  'type': 'workouts',      'threshold': 10},
    {'id': 'workouts_50',    'label': 'Grind Mode',        'type': 'workouts',      'threshold': 50},
    {'id': 'pb_first',       'label': 'Personal Legend',   'type': 'pbs',           'threshold': 1},
    {'id': 'war_win',        'label': 'War Champion',      'type': 'warWins',       'threshold': 1},
    {'id': 'loyalty_3m',     'label': 'Loyal Member',      'type': 'loyaltyMonths', 'threshold': 3},
    {'id': 'loyalty_1y',     'label': 'Spring Legend',     'type': 'loyaltyMonths', 'threshold': 12},
  ];

  Future<void> checkAndAward(String memberId) async {
    final docRef = FirebaseFirestore.instance.collection('gamification').doc(memberId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) return;

    final data = docSnap.data()!;
    final earnedBadges = List<String>.from(data['badges'] ?? []);
    final totalXP = data['totalXp'] ?? data['totalXP'] ?? 0;
    final currentStreak = data['currentStreak'] ?? 0;
    final workoutCount = data['totalWorkouts'] ?? data['workoutCount'] ?? 0;
    final checkinCount = data['totalCheckIns'] ?? data['checkinCount'] ?? 0;
    final personalBestCount = data['personalBestCount'] ?? 0;
    final warWins = data['warWins'] ?? 0;
    final loyaltyMonths = data['loyaltyMonths'] ?? 0;

    final newlyEarned = <Map<String, dynamic>>[];

    for (final badge in badgeDefinitions) {
      final id = badge['id'] as String;
      if (earnedBadges.contains(id)) continue;

      final type = badge['type'] as String;
      final threshold = badge['threshold'] as int;

      bool earned = false;
      switch (type) {
        case 'checkins':
          earned = checkinCount >= threshold;
          break;
        case 'streak':
          earned = currentStreak >= threshold;
          break;
        case 'xp':
          earned = totalXP >= threshold;
          break;
        case 'workouts':
          earned = workoutCount >= threshold;
          break;
        case 'pbs':
          earned = personalBestCount >= threshold;
          break;
        case 'warWins':
          earned = warWins >= threshold;
          break;
        case 'loyaltyMonths':
          earned = loyaltyMonths >= threshold;
          break;
      }

      if (earned) {
        newlyEarned.add(badge);
      }
    }

    if (newlyEarned.isNotEmpty) {
      final newBadgeIds = newlyEarned.map((b) => b['id'] as String).toList();

      // Update Firestore
      await docRef.update({
        'badges': FieldValue.arrayUnion(newBadgeIds),
        // Add it to earnedBadgeIds too since gamification_service.dart uses it
        'earnedBadgeIds': FieldValue.arrayUnion(newBadgeIds),
      });

      // Send notifications
      final notifications = newlyEarned.map((badge) => NotificationData(
        type: NotificationType.badge,
        title: 'Badge Unlocked!',
        body: 'You earned ${badge['label']}!',
        metadata: {'badgeId': badge['id']},
      )).toList();

      final notifUid = FirebaseAuthService.instance.currentUser?.uid;
      if (notifUid != null) {
        await InAppNotificationService().addNotificationsForMemberBatch(
          uid: notifUid,
          notifications: notifications,
        );
      }
    }
  }
}
