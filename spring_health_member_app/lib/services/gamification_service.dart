import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/gamification_model.dart';
// 🆕 Notification feed imports
import '../models/notification_model.dart';
import 'in_app_notification_service.dart';

class GamificationService {
  final _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────
  // GET OR CREATE
  // ─────────────────────────────────────────────
  Future<MemberGamification> getOrCreate(String memberId) async {
    final doc =
    await _db.collection('gamification').doc(memberId).get();
    if (doc.exists) {
      return MemberGamification.fromFirestore(doc);
    }
    final empty = MemberGamification.empty(memberId);
    await _db
    .collection('gamification')
    .doc(memberId)
    .set(empty.toMap());
    return empty;
  }

  // ─────────────────────────────────────────────
  // REAL-TIME STREAM
  // ─────────────────────────────────────────────
  Stream<MemberGamification> stream(String memberId) {
    return _db
    .collection('gamification')
    .doc(memberId)
    .snapshots()
    .map((doc) {
      if (doc.exists) return MemberGamification.fromFirestore(doc);
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
        final yesterdayDate = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
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
      final badgeXpBonus =
      newlyEarned.fold<int>(0, (total, b) => total + b.xpReward);
      final totalNewXp = baseXp + badgeXpBonus;

      // ── XP Event Log (keep latest 20) ──
      final events = List<XpEvent>.from(current.recentXpEvents);
      events.insert(
        0,
        XpEvent(
          reason: reason,
          xpEarned: xp + badgeXpBonus,
          timestamp: DateTime.now(),
          badgeEarned:
          newlyEarned.isNotEmpty ? newlyEarned.first.title : null,
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
        '🎮 XP awarded: +$xp (badge bonus: +$badgeXpBonus) '
      'for "$reason". New total: $totalNewXp');

      // 🆕 Write XP notification to in-app feed
      final notifService = InAppNotificationService();
      await notifService.addNotification(
        type: NotificationType.xp,
        title: '+$xp XP ${_xpEmoji(reason)}',
        body: reason,
        metadata: {
          'xpGained': xp,
          'bonusXp': badgeXpBonus,
          'totalXp': totalNewXp,
          'level': newLevel.level,
        },
      );

      // 🆕 Write a badge notification for each newly unlocked badge
      for (final badge in newlyEarned) {
        await notifService.addNotification(
          type: NotificationType.badge,
          title: '🏅 Badge Unlocked: ${badge.title}',
          body: badge.description,
          metadata: {
            'badgeId': badge.id,
            'xpReward': badge.xpReward,
          },
        );
        debugPrint('🏅 Badge notification written: ${badge.title}');
      }

      return newlyEarned;
    }

    // 🆕 Contextual emoji for XP notification titles
    String _xpEmoji(String reason) {
      final r = reason.toLowerCase();
      if (r.contains('check')) return '📍';
      if (r.contains('workout')) return '💪';
      if (r.contains('streak')) return '🔥';
      if (r.contains('payment')) return '✅';
      if (r.contains('profile')) return '⭐';
      return '⚡';
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
        } catch (_) {}
        entries.add(LeaderboardEntry(
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
        ));
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
          final myDoc =
          await _db.collection('gamification').doc(memberId).get();
          if (!myDoc.exists) return null;
          final myValue = myDoc.data()?[sortBy] ?? 0;
          final higherCount = await _db
          .collection('gamification')
          .where(sortBy, isGreaterThan: myValue)
          .count()
          .get();
          return (higherCount.count ?? 0) + 1;
        } catch (e) {
          debugPrint('⚠️ getMemberRank error: $e');
          return null;
        }
      }

      // ─────────────────────────────────────────────
      // LEGACY — kept for backward compat
      // ─────────────────────────────────────────────
      Future<List<Map<String, dynamic>>> getLeaderboard(
        String branch) async {
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
