import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/gamification_model.dart';
// 🆕 Notification feed imports
import '../models/notification_model.dart';
import 'in_app_notification_service.dart';
import 'badge_service.dart';
import 'firebase_auth_service.dart';

class GamificationService {
  static final GamificationService instance = GamificationService._internal();
  factory GamificationService() => instance;
  GamificationService._internal();
  final _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // GET OR CREATE
  // ─────────────────────────────────────────────
  Future<MemberGamification> getOrCreate(String memberId) async {
    final doc = await _db.collection('gamification').doc(memberId).get();
    if (doc.exists) {
      return MemberGamification.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    final empty = MemberGamification.empty(memberId);
    await _db.collection('gamification').doc(memberId).set(empty.toMap());
    return empty;
  }

  // ─────────────────────────────────────────────
  // LOYALTY HELPERS
  // ─────────────────────────────────────────────
  Future<bool> _isMilestoneAlreadyAwarded(String memberId, String event) async {
    final doc = await FirebaseFirestore.instance
        .collection('gamification')
        .doc(memberId)
        .get();
    if (!doc.exists) return false;
    final awarded = List<String>.from(
      doc.data()?['loyaltyMilestonesAwarded'] ?? [],
    );
    return awarded.contains(event);
  }

  String _loyaltyLabel(String event) {
    switch (event) {
      case 'loyalty_3m':
        return '3-month loyalty bonus';
      case 'loyalty_6m':
        return '6-month loyalty bonus';
      case 'loyalty_1y':
        return '1-year loyalty bonus';
      default:
        return 'Loyalty bonus';
    }
  }

  // ─────────────────────────────────────────────
  // PROCESS EVENT
  // ─────────────────────────────────────────────
  Future<void> processEvent(String event, String memberId, {int? customXP}) async {
    int xp = 0;
    String reason = '';
    switch (event) {
      case 'daily_checkin':
      case 'check_in':
        xp = 20;
        reason = 'Gym check-in';
        break;
      case 'workout':
        xp = customXP ?? 30;
        reason = 'Workout complete';
        break;
      case 'personal_best':
        xp = 50;
        reason = 'New personal best';
        break;
      case 'streak_milestone':
        xp = customXP ?? 100;
        reason = 'Streak milestone';
        break;
      case 'loyalty_3m':
      case 'loyalty_6m':
      case 'loyalty_1y':
        final alreadyAwarded = await _isMilestoneAlreadyAwarded(
          memberId,
          event,
        );
        if (alreadyAwarded) return;
        xp = event == 'loyalty_3m'
            ? 100
            : event == 'loyalty_6m'
            ? 250
            : 500;
        reason = _loyaltyLabel(event);
        await awardXp(memberId, reason, xp);
        await FirebaseFirestore.instance
            .collection('gamification')
            .doc(memberId)
            .update({
              'loyaltyMilestonesAwarded': FieldValue.arrayUnion([event]),
            });
        await calculateStreak(memberId);
        await BadgeService.instance.checkAndAward(memberId);
        return; // early return — XP already awarded above, skip fall-through
      case 'war_participate':
        xp = 20;
        reason = 'Weekly War participation';
        break;
      case 'war_top3':
        xp = customXP ?? 150;
        reason = 'Weekly War podium';
        break;
      case 'war_winner':
        xp = 500;
        reason = 'Weekly War champion';
        break;
      case 'challenge_win':
        xp = 20;
        reason = '1v1 Challenge win bonus';
        break;
      case 'challenge_lose':
        xp = -10;
        reason = '1v1 Challenge loss';
        break;
      case 'challenge_participate':
        xp = 5;
        reason = '1v1 Challenge participation';
        break;
      default:
        return;
    }
    await awardXp(
      memberId,
      reason,
      xp,
      isCheckIn: event == 'check_in',
      isWorkout: event == 'workout',
    );
    await calculateStreak(memberId);
    await BadgeService.instance.checkAndAward(memberId);
  }

  // ─────────────────────────────────────────────
  // CALCULATE STREAK
  // ─────────────────────────────────────────────
  Future<int> calculateStreak(String memberId) async {
    final snap = await _db
        .collection('attendance')
        .where('memberId', isEqualTo: memberId)
        .orderBy('checkInTime', descending: true)
        .get();

    if (snap.docs.isEmpty) {
      await _db.collection('gamification').doc(memberId).update({
        'currentStreak': 0,
        'longestStreak': 0,
      });
      return 0;
    }

    final dates = snap.docs
        .map((doc) {
          final t = doc.data()['checkInTime'] as Timestamp;
          final dt = t.toDate();
          return DateTime(dt.year, dt.month, dt.day);
        })
        .toSet()
        .toList();

    int currentStreak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dates.contains(today) || dates.contains(yesterday)) {
      DateTime checkDate = dates.contains(today) ? today : yesterday;
      while (dates.contains(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      }
    }

    final gamDoc = await _db.collection('gamification').doc(memberId).get();
    int longestStreak = currentStreak;
    if (gamDoc.exists) {
      final data = gamDoc.data()!;
      longestStreak = data['longestStreak'] ?? 0;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }

    await _db.collection('gamification').doc(memberId).update({
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    });

    return currentStreak;
  }

  // ─────────────────────────────────────────────
  // EVENT LISTENER
  // ─────────────────────────────────────────────
  void listenForPendingLoyaltyEvents(String memberId) {
    FirebaseFirestore.instance
        .collection('gamification_events')
        .where('memberId', isEqualTo: memberId)
        .where('processed', isEqualTo: false)
        .snapshots()
        .listen((snapshot) async {
          for (final doc in snapshot.docs) {
            final event = doc.data()['event'] as String?;
            if (event != null) {
              await processEvent(event, memberId);
              await doc.reference.update({'processed': true});
            }
          }
        });
  }

  // ─────────────────────────────────────────────
  // REAL-TIME STREAM
  // ─────────────────────────────────────────────
  Stream<MemberGamification> stream(String memberId) {
    return _db.collection('gamification').doc(memberId).snapshots().map((doc) {
      if (doc.exists) return MemberGamification.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      return MemberGamification.empty(memberId);
    });
  }

  // ─────────────────────────────────────────────
  // AWARD XP — Firestore Transaction (race-safe)
  // ─────────────────────────────────────────────
  Future<List<BadgeDefinition>> awardXp(
    String memberId,
    String reason,
    int xp, {
    bool isCheckIn = false,
    bool isWorkout = false,
    int workoutVolumeKg = 0,
  }) async {
    final current = await getOrCreate(memberId);
    final earnedBadgeIds = List<String>.from(current.earnedBadgeIds);
    final newlyEarned = <BadgeDefinition>[];

    // ── Counters ──
    int newCheckIns = current.totalCheckIns;
    int newWorkouts = current.totalWorkouts;
    int newVolume = current.totalVolumeKg;
    int newStreak = current.currentStreak;
    int newLongest = current.longestStreak;
    DateTime? newLastCheckIn = current.lastCheckIn;

    if (isCheckIn) {
      newCheckIns++;
      // ✅ subtract() — safe across month/year boundaries
      final now = DateTime.now();
      final yesterdayDate = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1));
      final lastDate = current.lastCheckIn != null
          ? DateTime(
              current.lastCheckIn!.year,
              current.lastCheckIn!.month,
              current.lastCheckIn!.day,
            )
          : null;
      if (lastDate == null || lastDate.isBefore(yesterdayDate)) {
        newStreak = 1; // reset
      } else if (lastDate == yesterdayDate) {
        newStreak = current.currentStreak + 1; // extend
      }
      // same day → no streak change (implicit)
      newLongest = newStreak > current.longestStreak
          ? newStreak
          : current.longestStreak;
      newLastCheckIn = now;
    }

    if (isWorkout) {
      newWorkouts++;
      newVolume += workoutVolumeKg;
    }

    // ── Badge Checks ──
    void checkBadge(String id) {
      if (!earnedBadgeIds.contains(id)) {
        final badge = BadgeDefinition.findById(id);
        if (badge != null) {
          earnedBadgeIds.add(id);
          newlyEarned.add(badge);
        }
      }
    }

    // Check-in badges
    if (isCheckIn && newCheckIns == 1) checkBadge('first_checkin');
    if (newStreak >= 7) checkBadge('streak_7');
    if (newStreak >= 30) checkBadge('streak_30');
    // Workout badges
    if (isWorkout && newWorkouts == 1) checkBadge('first_workout');
    if (newWorkouts >= 10) checkBadge('workouts_10');
    if (newWorkouts >= 50) checkBadge('workouts_50');
    if (newWorkouts >= 100) checkBadge('workouts_100');
    // Volume badges
    if (newVolume >= 1000) checkBadge('volume_1000');
    if (newVolume >= 10000) checkBadge('volume_10000');
    // Level badges
    final baseXp = current.totalXp + xp;
    final newLevel = GymLevel.forXp(baseXp);
    if (newLevel.level >= 4) checkBadge('level_champion');
    if (newLevel.level >= 6) checkBadge('level_legend');
    // Time-based badges
    if (isCheckIn) {
      final hour = DateTime.now().hour;
      if (hour < 7) checkBadge('early_bird');
      if (hour >= 20) checkBadge('night_owl');
    }

    // ── XP Totals ──
    final badgeXpBonus = newlyEarned.fold<int>(
      0,
      (total, b) => total + b.xpReward,
    );
    final totalNewXp = baseXp + badgeXpBonus;

    // ── XP Event Log (keep latest 20) ──
    final events = List<XpEvent>.from(current.recentXpEvents);
    events.insert(
      0,
      XpEvent(
        reason: reason,
        xpEarned: xp + badgeXpBonus,
        timestamp: DateTime.now(),
        badgeEarned: newlyEarned.isNotEmpty ? newlyEarned.first.title : null,
      ),
    );
    if (events.length > 20) events.removeRange(20, events.length);

    // ── Build Updated Object ──
    final updated = MemberGamification(
      memberId: memberId,
      totalXp: totalNewXp,
      earnedBadgeIds: earnedBadgeIds,
      currentStreak: newStreak,
      longestStreak: newLongest,
      totalCheckIns: newCheckIns,
      totalWorkouts: newWorkouts,
      totalVolumeKg: newVolume,
      lastCheckIn: newLastCheckIn,
      recentXpEvents: events,
    );

    // ✅ Firestore transaction — prevents race conditions
    await _db.runTransaction((txn) async {
      final ref = _db.collection('gamification').doc(memberId);
      txn.set(ref, updated.toMap());
    });

    debugPrint(
      'Game XP awarded: +$xp (badge bonus: +$badgeXpBonus) '
      'for "$reason". New total: $totalNewXp',
    );

    // 🆕 Write XP notification to in-app feed
    final notifService = InAppNotificationService();
    final notifications = <NotificationData>[
      NotificationData(
        type: NotificationType.xp,
        title: '+$xp XP ${_xpEmoji(reason)}',
        body: reason,
        metadata: {
          'xpGained': xp,
          'bonusXp': badgeXpBonus,
          'totalXp': totalNewXp,
          'level': newLevel.level,
        },
      ),
    ];

    // 🆕 Write a badge notification for each newly unlocked badge
    for (final badge in newlyEarned) {
      notifications.add(
        NotificationData(
          type: NotificationType.badge,
          title: ' Badge Unlocked: ${badge.title}',
          body: badge.description,
          metadata: {'badgeId': badge.id, 'xpReward': badge.xpReward},
        ),
      );
      debugPrint(' Badge notification written: ${badge.title}');
    }

    final notifUid = FirebaseAuthService.instance.currentUser?.uid;
    if (notifUid != null) {
      await notifService.addNotificationsForMemberBatch(
        uid: notifUid,
        notifications: notifications,
      );
    }

    return newlyEarned;
  }

  // 🆕 Contextual emoji for XP notification titles
  String _xpEmoji(String reason) {
    final r = reason.toLowerCase();
    if (r.contains('check')) return 'Location';
    if (r.contains('workout')) return '';
    if (r.contains('streak')) return '';
    if (r.contains('payment')) return 'Check';
    if (r.contains('profile')) return '';
    return 'Energy';
  }

  // ─────────────────────────────────────────────
  // LEADERBOARD WITH MEMBER NAMES
  // ✅ Parallel fetches with Future.wait
  // ─────────────────────────────────────────────
  Future<List<LeaderboardEntry>> getLeaderboardWithNames({
    String sortBy = 'totalXp',
    int limit = 20,
  }) async {
    final snap = await _db
        .collection('gamification')
        .orderBy(sortBy, descending: true)
        .limit(limit)
        .get();
    if (snap.docs.isEmpty) return [];

    // ✅ Fetch all member docs in parallel — O(1) round trips
    final memberFutures = snap.docs.map(
      (doc) => _db.collection('members').doc(doc.id).get(),
    );
    final memberDocs = await Future.wait(memberFutures);

    final entries = <LeaderboardEntry>[];
    for (int i = 0; i < snap.docs.length; i++) {
      final doc = snap.docs[i];
      final data = doc.data();
      String memberName = 'Member';
      String? photoUrl;
      try {
        if (memberDocs[i].exists) {
          final mData = memberDocs[i].data()!;
          memberName = mData['name'] ?? 'Member';
          photoUrl = mData['photoUrl'];
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error fetching member info for leaderboard: $e');
        }
      }
      entries.add(
        LeaderboardEntry(
          rank: i + 1,
          memberId: doc.id,
          memberName: memberName,
          photoUrl: photoUrl,
          totalXp: data['totalXp'] ?? 0,
          currentStreak: data['currentStreak'] ?? 0,
          totalWorkouts: data['totalWorkouts'] ?? 0,
          totalCheckIns: data['totalCheckIns'] ?? 0,
          earnedBadgeCount:
              (data['earnedBadgeIds'] as List<dynamic>? ?? []).length,
          level: GymLevel.forXp(data['totalXp'] ?? 0),
        ),
      );
    }
    return entries;
  }

  // ─────────────────────────────────────────────
  // GET MEMBER'S RANK
  // ─────────────────────────────────────────────
  Future<int?> getMemberRank(
    String memberId, {
    String sortBy = 'totalXp',
  }) async {
    try {
      final myDoc = await _db.collection('gamification').doc(memberId).get();
      if (!myDoc.exists) return null;
      final myValue = myDoc.data()?[sortBy] ?? 0;
      final higherCount = await _db
          .collection('gamification')
          .where(sortBy, isGreaterThan: myValue)
          .count()
          .get();
      return (higherCount.count ?? 0) + 1;
    } catch (e) {
      debugPrint(' getMemberRank error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // LEGACY — kept for backward compat
  // ─────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getLeaderboard(String branch) async {
    final snap = await _db
        .collection('gamification')
        .orderBy('totalXp', descending: true)
        .limit(10)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      // ✅ Compute level once, not twice
      final level = GymLevel.forXp(data['totalXp'] ?? 0);
      return {
        'memberId': doc.id,
        'totalXp': data['totalXp'] ?? 0,
        'currentStreak': data['currentStreak'] ?? 0,
        'level': level.title,
        'levelNum': level.level,
      };
    }).toList();
  }
}
