import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/core/utils/date_time_utils.dart';

class WeeklyWarModel {
  final String id;
  final String branchId;
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String exercise;
  final String unit; // 'reps' or 'seconds'
  final String category;
  final String status; // 'active' | 'locked' | 'completed' | 'archived'
  final Map<String, int>
  prizePool; // {'rank1': 500, 'rank2': 300, 'rank3': 150, 'participation': 20}
  final String? winnerId;
  final String? winnerName;
  final DateTime createdAt;

  const WeeklyWarModel({
    required this.id,
    required this.branchId,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.exercise,
    required this.unit,
    required this.category,
    required this.status,
    required this.prizePool,
    this.winnerId,
    this.winnerName,
    required this.createdAt,
  });

  factory WeeklyWarModel.fromMap(String id, Map<String, dynamic> data) {
    return WeeklyWarModel(
      id: id,
      branchId: data['branchId'] as String? ?? '',
      weekNumber: data['weekNumber'] as int? ?? 0,
      startDate: DateTimeUtils.toDateTime(data['startDate']),
      endDate: DateTimeUtils.toDateTime(data['endDate']),
      exercise: data['exercise'] as String? ?? '',
      unit: data['unit'] as String? ?? 'reps',
      category: data['category'] as String? ?? 'strength',
      status: data['status'] as String? ?? 'active',
      prizePool: data['prizePool'] != null
          ? Map<String, int>.from(data['prizePool'] as Map)
          : {},
      winnerId: data['winnerId'] as String?,
      winnerName: data['winnerName'] as String?,
      createdAt: DateTimeUtils.toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'branchId': branchId,
      'weekNumber': weekNumber,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'exercise': exercise,
      'unit': unit,
      'category': category,
      'status': status,
      'prizePool': prizePool,
      if (winnerId != null) 'winnerId': winnerId,
      if (winnerName != null) 'winnerName': winnerName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class WarEntryModel {
  final String memberId;
  final String memberName;
  final int totalReps;
  final int sessionCount;
  final DateTime lastUpdated;
  final int? rank;
  final int? xpAwarded;

  const WarEntryModel({
    required this.memberId,
    required this.memberName,
    required this.totalReps,
    required this.sessionCount,
    required this.lastUpdated,
    this.rank,
    this.xpAwarded,
  });

  factory WarEntryModel.fromMap(String memberId, Map<String, dynamic> data) {
    return WarEntryModel(
      memberId: memberId,
      memberName: data['memberName'] as String,
      totalReps: data['totalReps'] as int,
      sessionCount: data['sessionCount'] as int,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      rank: data['rank'] as int?,
      xpAwarded: data['xpAwarded'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'totalReps': totalReps,
      'sessionCount': sessionCount,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      if (rank != null) 'rank': rank,
      if (xpAwarded != null) 'xpAwarded': xpAwarded,
    };
  }
}
