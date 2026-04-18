import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// XP SOURCES
// ─────────────────────────────────────────────
class XpSource {
  static const int checkIn = 50;
  static const int workoutLogged = 100;
  static const int weeklyStreak = 200;
  static const int monthlyStreak = 500;
  static const int paymentOnTime = 150;
  static const int profileCompleted = 75;
  static const int firstCheckIn = 100;
  static const int earlyBird = 75; // check-in before 7am
  static const int nightOwl = 75; // check-in after 8pm
}

// ─────────────────────────────────────────────
// LEVEL DEFINITION
// ─────────────────────────────────────────────
class GymLevel {
  final int level;
  final String title;
  final int minXp;
  final int maxXp;
  final Color color;
  final IconData icon;

  const GymLevel({
    required this.level,
    required this.title,
    required this.minXp,
    required this.maxXp,
    required this.color,
    required this.icon,
  });

  static const List<GymLevel> levels = [
    GymLevel(
      level: 1,
      title: 'Beginner',
      minXp: 0,
      maxXp: 500,
      color: AppColors.gray400,
      icon: Icons.emoji_events_outlined,
    ),
    GymLevel(
      level: 2,
      title: 'Warrior',
      minXp: 500,
      maxXp: 1200,
      color: AppColors.neonTeal,
      icon: Icons.shield_rounded,
    ),
    GymLevel(
      level: 3,
      title: 'Fighter',
      minXp: 1200,
      maxXp: 2500,
      color: AppColors.neonLime,
      icon: Icons.sports_mma_rounded,
    ),
    GymLevel(
      level: 4,
      title: 'Champion',
      minXp: 2500,
      maxXp: 5000,
      color: AppColors.neonOrange,
      icon: Icons.military_tech_rounded,
    ),
    GymLevel(
      level: 5,
      title: 'Elite',
      minXp: 5000,
      maxXp: 10000,
      color: Colors.purpleAccent,
      icon: Icons.diamond_rounded,
    ),
    GymLevel(
      level: 6,
      title: 'Legend',
      minXp: 10000,
      maxXp: 999999,
      color: Colors.amber,
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  static GymLevel forXp(int xp) {
    for (final lvl in levels.reversed) {
      if (xp >= lvl.minXp) return lvl;
    }
    return levels.first;
  }

  double progressPercent(int xp) {
    if (level == 6) return 1.0;
    return ((xp - minXp) / (maxXp - minXp)).clamp(0.0, 1.0);
  }

  int xpToNextLevel(int xp) {
    if (level == 6) return 0;
    return (maxXp - xp).clamp(0, maxXp);
  }
}

// ─────────────────────────────────────────────
// BADGE DEFINITION
// ─────────────────────────────────────────────
class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int xpReward;

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.xpReward,
  });

  static const List<BadgeDefinition> all = [
    BadgeDefinition(
      id: 'first_checkin',
      title: 'First Step',
      description: 'Complete your first check-in',
      icon: Icons.login_rounded,
      color: AppColors.neonLime,
      xpReward: 100,
    ),
    BadgeDefinition(
      id: 'streak_7',
      title: '7-Day Warrior',
      description: 'Check in 7 days in a row',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.neonOrange,
      xpReward: 200,
    ),
    BadgeDefinition(
      id: 'streak_30',
      title: 'Iron Discipline',
      description: 'Check in 30 days in a row',
      icon: Icons.whatshot_rounded,
      color: Colors.deepOrange,
      xpReward: 500,
    ),
    BadgeDefinition(
      id: 'first_workout',
      title: 'Sweat Starter',
      description: 'Log your first workout',
      icon: Icons.fitness_center_rounded,
      color: AppColors.neonTeal,
      xpReward: 100,
    ),
    BadgeDefinition(
      id: 'workouts_10',
      title: 'Getting Serious',
      description: 'Log 10 workouts',
      icon: Icons.sports_gymnastics_rounded,
      color: AppColors.neonLime,
      xpReward: 200,
    ),
    BadgeDefinition(
      id: 'workouts_50',
      title: 'Gym Rat',
      description: 'Log 50 workouts',
      icon: Icons.emoji_events_rounded,
      color: AppColors.neonOrange,
      xpReward: 500,
    ),
    BadgeDefinition(
      id: 'workouts_100',
      title: 'Iron Will',
      description: 'Log 100 workouts',
      icon: Icons.military_tech_rounded,
      color: Colors.amber,
      xpReward: 1000,
    ),
    BadgeDefinition(
      id: 'volume_1000',
      title: 'Heavy Lifter',
      description: 'Lift 1,000 kg total volume',
      icon: Icons.monitor_weight_rounded,
      color: AppColors.neonTeal,
      xpReward: 300,
    ),
    BadgeDefinition(
      id: 'volume_10000',
      title: 'Beast Mode',
      description: 'Lift 10,000 kg total volume',
      icon: Icons.diamond_rounded,
      color: Colors.purpleAccent,
      xpReward: 750,
    ),
    BadgeDefinition(
      id: 'early_bird',
      title: 'Early Bird',
      description: 'Check in before 7:00 AM',
      icon: Icons.wb_sunny_rounded,
      color: Colors.amber,
      xpReward: 75,
    ),
    BadgeDefinition(
      id: 'night_owl',
      title: 'Night Owl',
      description: 'Check in after 8:00 PM',
      icon: Icons.nightlight_round,
      color: Colors.indigo,
      xpReward: 75,
    ),
    BadgeDefinition(
      id: 'level_champion',
      title: 'Champion',
      description: 'Reach Level 4',
      icon: Icons.shield_rounded,
      color: AppColors.neonOrange,
      xpReward: 0,
    ),
    BadgeDefinition(
      id: 'level_legend',
      title: 'Legend',
      description: 'Reach Level 6',
      icon: Icons.auto_awesome_rounded,
      color: Colors.amber,
      xpReward: 0,
    ),
  ];

  static BadgeDefinition? findById(String id) {
    try {
      return all.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────
// MEMBER GAMIFICATION DATA (stored in Firestore)
// ─────────────────────────────────────────────
class MemberGamification {
  final String memberId;
  final int totalXp;
  final List<String> earnedBadgeIds;
  final int currentStreak;
  final int longestStreak;
  final int totalCheckIns;
  final int totalWorkouts;
  final int totalVolumeKg;
  final DateTime? lastCheckIn;
  final List<XpEvent> recentXpEvents;

  MemberGamification({
    required this.memberId,
    required this.totalXp,
    required this.earnedBadgeIds,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCheckIns,
    required this.totalWorkouts,
    required this.totalVolumeKg,
    this.lastCheckIn,
    this.recentXpEvents = const [],
  });

  GymLevel get currentLevel => GymLevel.forXp(totalXp);

  List<BadgeDefinition> get earnedBadges => earnedBadgeIds
      .map((id) => BadgeDefinition.findById(id))
      .whereType<BadgeDefinition>()
      .toList();

  List<BadgeDefinition> get unearnedBadges =>
      BadgeDefinition.all.where((b) => !earnedBadgeIds.contains(b.id)).toList();

  factory MemberGamification.empty(String memberId) => MemberGamification(
    memberId: memberId,
    totalXp: 0,
    earnedBadgeIds: [],
    currentStreak: 0,
    longestStreak: 0,
    totalCheckIns: 0,
    totalWorkouts: 0,
    totalVolumeKg: 0,
  );

  factory MemberGamification.fromMap(Map<String, dynamic> data, String id) {
    return MemberGamification(
      memberId: id,
      totalXp: data['totalXp'] ?? 0,
      earnedBadgeIds: List<String>.from(data['earnedBadgeIds'] ?? []),
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      totalCheckIns: data['totalCheckIns'] ?? 0,
      totalWorkouts: data['totalWorkouts'] ?? 0,
      totalVolumeKg: data['totalVolumeKg'] ?? 0,
      lastCheckIn: data['lastCheckIn'] != null
          ? (data['lastCheckIn'] as Timestamp).toDate()
          : null,
      recentXpEvents: (data['recentXpEvents'] as List<dynamic>? ?? [])
          .map((e) => XpEvent.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory MemberGamification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberGamification.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'totalXp': totalXp,
    'earnedBadgeIds': earnedBadgeIds,
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'totalCheckIns': totalCheckIns,
    'totalWorkouts': totalWorkouts,
    'totalVolumeKg': totalVolumeKg,
    'lastCheckIn': lastCheckIn != null
        ? Timestamp.fromDate(lastCheckIn!)
        : null,
    'recentXpEvents': recentXpEvents.take(20).map((e) => e.toMap()).toList(),
  };
}

// ─────────────────────────────────────────────
// XP EVENT LOG
// ─────────────────────────────────────────────
class XpEvent {
  final String reason;
  final int xpEarned;
  final DateTime timestamp;
  final String? badgeEarned;

  XpEvent({
    required this.reason,
    required this.xpEarned,
    required this.timestamp,
    this.badgeEarned,
  });

  factory XpEvent.fromMap(Map<String, dynamic> map) => XpEvent(
    reason: map['reason'] ?? '',
    xpEarned: map['xpEarned'] ?? 0,
    timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    badgeEarned: map['badgeEarned'],
  );

  Map<String, dynamic> toMap() => {
    'reason': reason,
    'xpEarned': xpEarned,
    'timestamp': Timestamp.fromDate(timestamp),
    'badgeEarned': badgeEarned,
  };
}

// ─────────────────────────────────────────────
// LEADERBOARD ENTRY
// ─────────────────────────────────────────────
class LeaderboardEntry {
  final int rank;
  final String memberId;
  final String memberName;
  final String? photoUrl;
  final int totalXp;
  final int currentStreak;
  final int totalWorkouts;
  final int totalCheckIns;
  final int earnedBadgeCount;
  final GymLevel level;

  const LeaderboardEntry({
    required this.rank,
    required this.memberId,
    required this.memberName,
    required this.photoUrl,
    required this.totalXp,
    required this.currentStreak,
    required this.totalWorkouts,
    required this.totalCheckIns,
    required this.earnedBadgeCount,
    required this.level,
  });
}
