class AdminLeaderboardEntry {
  final int rank;
  final String memberId;
  final String memberName;
  final String? photoUrl;
  final String? branch;
  final String? phone;
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final int totalCheckIns;
  final int earnedBadgeCount;
  final List<Map<String, dynamic>>? recentXpEvents;  // ← NEW

  const AdminLeaderboardEntry({
    required this.rank,
    required this.memberId,
    required this.memberName,
    this.photoUrl,
    this.branch,
    this.phone,
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWorkouts,
    required this.totalCheckIns,
    required this.earnedBadgeCount,
    this.recentXpEvents,                             // ← NEW
  });

  // ← NEW — alias used by the detail sheet
  int get badgeCount => earnedBadgeCount;

  factory AdminLeaderboardEntry.fromMap(
    Map<String, dynamic> map,
    String id,
    int rank,
  ) {
    return AdminLeaderboardEntry(
      rank: rank,
      memberId: id,
      memberName: map['memberName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      branch: map['branch'] as String?,
      phone: map['phone'] as String?,
      totalXp: (map['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (map['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (map['longestStreak'] as num?)?.toInt() ?? 0,
      totalWorkouts: (map['totalWorkouts'] as num?)?.toInt() ?? 0,
      totalCheckIns: (map['totalCheckIns'] as num?)?.toInt() ?? 0,
      earnedBadgeCount:
      (map['earnedBadgeIds'] as List?)?.length ?? 0,
      recentXpEvents: (map['recentXpEvents'] as List?)
      ?.map((e) => Map<String, dynamic>.from(e as Map))
      .toList(),
    );
  }
}
