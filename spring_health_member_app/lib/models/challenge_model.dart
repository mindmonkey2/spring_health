import 'package:cloud_firestore/cloud_firestore.dart';

// ── Team ──────────────────────────────────────────────────────────────────────

class ChallengeTeam {
  final String id;
  final String name;
  final String emoji;
  final int totalScore;
  final List<String> memberIds;

  const ChallengeTeam({
    required this.id,
    required this.name,
    required this.emoji,
    required this.totalScore,
    required this.memberIds,
  });

  factory ChallengeTeam.fromMap(Map<String, dynamic> map) => ChallengeTeam(
    id: map['id'] as String? ?? '',
    name: map['name'] as String? ?? '',
    emoji: map['emoji'] as String? ?? 'Energy',
    totalScore: (map['totalScore'] as num?)?.toInt() ?? 0,
    memberIds: List<String>.from(map['memberIds'] as List? ?? []),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'totalScore': totalScore,
    'memberIds': memberIds,
  };
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum ChallengeType { stepWars, caloriesCrusher, workoutWarrior }

enum ChallengeStatus { upcoming, active, completed }

// ── Challenge ─────────────────────────────────────────────────────────────────

class ChallengeModel {
  final String id;
  final String title;
  final ChallengeType type;
  final ChallengeStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeTeam teamA;
  final ChallengeTeam teamB;
  final String? winnerId;
  final int prizeXP;
  final String description;
  final DateTime createdAt;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.teamA,
    required this.teamB,
    this.winnerId,
    required this.prizeXP,
    required this.description,
    required this.createdAt,
  });

  // ── Computed ──────────────────────────────────────────────────────────────

  String get typeLabel {
    switch (type) {
      case ChallengeType.stepWars:
        return 'Step Wars';
      case ChallengeType.caloriesCrusher:
        return 'Calorie Crusher';
      case ChallengeType.workoutWarrior:
        return 'Workout Warrior';
    }
  }

  String get typeUnit {
    switch (type) {
      case ChallengeType.stepWars:
        return 'steps';
      case ChallengeType.caloriesCrusher:
        return 'cal';
      case ChallengeType.workoutWarrior:
        return 'workouts';
    }
  }

  String get typeEmoji {
    switch (type) {
      case ChallengeType.stepWars:
        return '';
      case ChallengeType.caloriesCrusher:
        return '';
      case ChallengeType.workoutWarrior:
        return '';
    }
  }

  int get totalScore => teamA.totalScore + teamB.totalScore;
  double get teamAPercent =>
      totalScore == 0 ? 0.5 : teamA.totalScore / totalScore;

  // ── Serialization ─────────────────────────────────────────────────────────

  factory ChallengeModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) => ChallengeModel(
    id: id,
    title: map['title'] as String? ?? '',
    type: ChallengeType.values.firstWhere(
      (e) => e.name == (map['type'] as String? ?? 'stepWars'),
      orElse: () => ChallengeType.stepWars,
    ),
    status: ChallengeStatus.values.firstWhere(
      (e) => e.name == (map['status'] as String? ?? 'active'),
      orElse: () => ChallengeStatus.active,
    ),
    startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    endDate:
        (map['endDate'] as Timestamp?)?.toDate() ??
        DateTime.now().add(const Duration(days: 7)),
    teamA: ChallengeTeam.fromMap((map['teamA'] as Map<String, dynamic>?) ?? {}),
    teamB: ChallengeTeam.fromMap((map['teamB'] as Map<String, dynamic>?) ?? {}),
    winnerId: map['winnerId'] as String?,
    prizeXP: (map['prizeXP'] as num?)?.toInt() ?? 200,
    description: map['description'] as String? ?? '',
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory ChallengeModel.fromFirestore(
    Map<String, dynamic> map,
    String id,
  ) => ChallengeModel.fromMap(map, id);

  Map<String, dynamic> toMap() => {
    'title': title,
    'type': type.name,
    'status': status.name,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'teamA': teamA.toMap(),
    'teamB': teamB.toMap(),
    if (winnerId != null) 'winnerId': winnerId,
    'prizeXP': prizeXP,
    'description': description,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ── Entry ─────────────────────────────────────────────────────────────────────

class ChallengeEntryModel {
  final String id;
  final String challengeId;
  final String memberId;
  final String memberName;
  final String teamId;
  final int score;
  final DateTime lastUpdated;

  const ChallengeEntryModel({
    required this.id,
    required this.challengeId,
    required this.memberId,
    required this.memberName,
    required this.teamId,
    required this.score,
    required this.lastUpdated,
  });

  factory ChallengeEntryModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) => ChallengeEntryModel(
    id: id,
    challengeId: map['challengeId'] as String? ?? '',
    memberId: map['memberId'] as String? ?? '',
    memberName: map['memberName'] as String? ?? '',
    teamId: map['teamId'] as String? ?? '',
    score: (map['score'] as num?)?.toInt() ?? 0,
    lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  factory ChallengeEntryModel.fromFirestore(
    Map<String, dynamic> map,
    String id,
  ) => ChallengeEntryModel.fromMap(map, id);

  Map<String, dynamic> toMap() => {
    'challengeId': challengeId,
    'memberId': memberId,
    'memberName': memberName,
    'teamId': teamId,
    'score': score,
    'lastUpdated': Timestamp.fromDate(lastUpdated),
  };
}
