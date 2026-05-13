import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_leaderboard_entry.dart';

class AdminGamificationService {
  AdminGamificationService({FirebaseFirestore? firestore})
  : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // In-memory cache for member documents to reduce redundant reads.
  // Values can be null (negative caching for non-existent members).
  static final Map<String, Map<String, dynamic>?> _memberCache = {};

  static void clearMemberCache() => _memberCache.clear();

  /// sortBy: totalXp | currentStreak | totalWorkouts | totalCheckIns | longestStreak
  Future<List<AdminLeaderboardEntry>> getLeaderboard({
    required String sortBy,
    int limit = 50,
    String? branch,
  }) async {
    final snap = await _db
    .collection('gamification')
    .orderBy(sortBy, descending: true)
    .limit(limit)
    .get();

    if (snap.docs.isEmpty) return [];

    // Join: gamification doc id == members doc id
    final memberIds = snap.docs.map((d) => d.id).toList();

    // Identify IDs not in cache
    final missingMemberIds = memberIds.where((id) => !_memberCache.containsKey(id)).toList();

    if (missingMemberIds.isNotEmpty) {
      // Parallelize chunked queries - Firestore whereIn limit is 30
      final memberFutures = <Future<QuerySnapshot<Map<String, dynamic>>>>[];
      for (var i = 0; i < missingMemberIds.length; i += 30) {
        final chunk = missingMemberIds.sublist(
          i,
          i + 30 > missingMemberIds.length ? missingMemberIds.length : i + 30,
        );
        memberFutures.add(_db
            .collection('members')
            .where(FieldPath.documentId, whereIn: chunk)
            .get());
      }

      final memberSnapshots = await Future.wait(memberFutures);
      final fetchedIds = <String>{};

      for (final memberSnap in memberSnapshots) {
        for (final doc in memberSnap.docs) {
          if (doc.exists && doc.data() != null) {
            _memberCache[doc.id] = doc.data();
            fetchedIds.add(doc.id);
          }
        }
      }

      // Negative caching: mark requested but missing IDs as null to avoid re-fetching
      for (final id in missingMemberIds) {
        if (!fetchedIds.contains(id)) {
          _memberCache[id] = null;
        }
      }
    }

    final entries = <AdminLeaderboardEntry>[];
    for (var i = 0; i < snap.docs.length; i++) {
      final gDoc = snap.docs[i];
      final g = gDoc.data();
      final m = _memberCache[gDoc.id];

      // Branch filter — in-memory to avoid composite index requirement
      if (branch != null && (m?['branch'] as String?) != branch) continue;

      final memberName =
      (m?['name'] as String?)?.trim().isNotEmpty == true
      ? (m!['name'] as String).trim()
      : 'Member';

      entries.add(AdminLeaderboardEntry(
        rank: entries.length + 1,             // re-rank after branch filter
        memberId: gDoc.id,
        memberName: memberName,
        photoUrl: m?['photoUrl'] as String?,
        branch: m?['branch'] as String?,
        phone: m?['phone'] as String?,
        totalXp: (g['totalXp'] as num?)?.toInt() ?? 0,
        currentStreak: (g['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (g['longestStreak'] as num?)?.toInt() ?? 0,
        totalWorkouts: (g['totalWorkouts'] as num?)?.toInt() ?? 0,
        totalCheckIns: (g['totalCheckIns'] as num?)?.toInt() ?? 0,
        earnedBadgeCount:
        ((g['earnedBadgeIds'] as List?) ?? const []).length,
        recentXpEvents: (g['recentXpEvents'] as List?)
        ?.map((e) => Map<String, dynamic>.from(e as Map))
        .toList(),
      ));
    }

    return entries;
  }

  Future<int> getChallengesCount() async {
    final snap = await _db.collection('challenges').get();
    return snap.size;
  }

  Future<int> getChallengeEntriesCount() async {
    final snap = await _db.collection('challengeEntries').get();
    return snap.size;
  }

  /// Gym-wide XP stats for the stats strip
  Future<Map<String, dynamic>> getGymXpStats() async {
    final snap = await _db.collection('gamification').get();
    int totalXp = 0;
    int activeMembers = 0;
    for (final doc in snap.docs) {
      final xp = (doc.data()['totalXp'] as num?)?.toInt() ?? 0;
      totalXp += xp;
      if (xp > 0) activeMembers++;
    }
    return {'totalXp': totalXp, 'activeMembers': activeMembers};
  }

  /// Add or deduct XP with reason logged to recentXpEvents
  // In admin_gamification_service.dart

  Future<void> adjustXp({
    required String memberId,
    required int delta,
    required String reason,
  }) async {
    await FirebaseFirestore.instance
    .collection('gamification')
    .doc(memberId)
    .set({
      'totalXp': FieldValue.increment(delta),
      'recentXpEvents': FieldValue.arrayUnion([
        {'xp': delta, 'reason': reason, 'at': Timestamp.now()}
      ]),
    }, SetOptions(merge: true)); // ← merge creates doc if missing
  }

  Future<void> awardBadge({
    required String memberId,
    required String badgeId,
  }) async {
    await FirebaseFirestore.instance
    .collection('gamification')
    .doc(memberId)
    .set({
      'earnedBadgeIds': FieldValue.arrayUnion([badgeId]),
    }, SetOptions(merge: true)); // ← merge creates doc if missing
  }


  /// Reset a member's current streak to 0
  Future<void> resetStreak({required String memberId}) async {
    await _db.collection('gamification').doc(memberId).update({
      'currentStreak': 0,
    });
  }
}
