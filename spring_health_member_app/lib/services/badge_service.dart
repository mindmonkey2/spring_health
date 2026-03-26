import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'in_app_notification_service.dart';

class BadgeService {
  static final BadgeService instance = BadgeService._internal();
  BadgeService._internal();

  // Badge definitions — id, label, condition type, threshold
  static const List<Map<String, dynamic>> badgeDefinitions = [
    {
      'id': 'first_checkin',
      'label': 'First Step',
      'type': 'checkins',
      'threshold': 1,
    },
    {
      'id': 'streak_7',
      'label': '7-Day Warrior',
      'type': 'streak',
      'threshold': 7,
    },
    {
      'id': 'streak_30',
      'label': 'Iron Consistent',
      'type': 'streak',
      'threshold': 30,
    },
    {'id': 'xp_500', 'label': 'Rising Star', 'type': 'xp', 'threshold': 500},
    {'id': 'xp_2000', 'label': 'XP Beast', 'type': 'xp', 'threshold': 2000},
    {
      'id': 'workouts_10',
      'label': 'Dedicated Lifter',
      'type': 'workouts',
      'threshold': 10,
    },
    {
      'id': 'workouts_50',
      'label': 'Grind Mode',
      'type': 'workouts',
      'threshold': 50,
    },
    {
      'id': 'pb_first',
      'label': 'Personal Legend',
      'type': 'pbs',
      'threshold': 1,
    },
    {
      'id': 'war_win',
      'label': 'War Champion',
      'type': 'war_wins',
      'threshold': 1,
    },
    {
      'id': 'loyalty_3m',
      'label': 'Loyal Member',
      'type': 'loyalty_months',
      'threshold': 3,
    },
    {
      'id': 'loyalty_1y',
      'label': 'Spring Legend',
      'type': 'loyalty_months',
      'threshold': 12,
    },
  ];

  Future<void> checkAndAward(String memberId) async {
    final doc = await FirebaseFirestore.instance
        .collection('gamification')
        .doc(memberId)
        .get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final existingBadges = List<String>.from(data['badges'] ?? []);

    final int currentXP = data['totalXP'] ?? 0;
    final int currentStreak = data['currentStreak'] ?? 0;
    final int workoutCount = data['workoutCount'] ?? 0;
    final int checkinCount = data['checkinCount'] ?? 0;
    final int pbCount = data['personalBestCount'] ?? 0;
    final int warWins = data['warWins'] ?? 0;
    final int loyaltyMonths = data['loyaltyMonths'] ?? 0;

    final List<String> newlyAwarded = [];

    for (final badge in badgeDefinitions) {
      final String id = badge['id'];
      if (existingBadges.contains(id)) continue;
      bool earned = false;
      switch (badge['type']) {
        case 'xp':
          earned = currentXP >= badge['threshold'];
          break;
        case 'streak':
          earned = currentStreak >= badge['threshold'];
          break;
        case 'workouts':
          earned = workoutCount >= badge['threshold'];
          break;
        case 'checkins':
          earned = checkinCount >= badge['threshold'];
          break;
        case 'pbs':
          earned = pbCount >= badge['threshold'];
          break;
        case 'war_wins':
          earned = warWins >= badge['threshold'];
          break;
        case 'loyalty_months':
          earned = loyaltyMonths >= badge['threshold'];
          break;
      }
      if (earned) newlyAwarded.add(id);
    }

    if (newlyAwarded.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('gamification')
        .doc(memberId)
        .update({'badges': FieldValue.arrayUnion(newlyAwarded)});

    for (final badgeId in newlyAwarded) {
      final badgeDef = badgeDefinitions.firstWhere((b) => b['id'] == badgeId);
      await InAppNotificationService().addNotificationForMember(
        uid: memberId,
        type: NotificationType.badge,
        title: '🏅 Badge Unlocked!',
        body: 'You earned: ${badgeDef['label']}',
        metadata: {'badgeId': badgeId},
      );
    }
  }
}
