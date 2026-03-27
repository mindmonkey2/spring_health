import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyWarModel {
  final String id;
  final String branchId;
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final String exercise;
  final String unit; // 'reps' | 'seconds'
  final String category;
  final String status; // 'active' | 'locked' | 'completed' | 'archived'
  final Map<String, int> prizePool;
  final String? winnerId;
  final String? winnerName;

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
  });

  factory WeeklyWarModel.fromMap(Map<String, dynamic> map, String id) {
    return WeeklyWarModel(
      id: id,
      branchId: map['branchId'] ?? '',
      weekNumber: map['weekNumber'] ?? 0,
      startDate: _toDateTime(map['startDate']),
      endDate: _toDateTime(map['endDate']),
      exercise: map['exercise'] ?? '',
      unit: map['unit'] ?? 'reps',
      category: map['category'] ?? 'strength',
      status: map['status'] ?? 'active',
      prizePool: Map<String, int>.from(map['prizePool'] ?? {}),
      winnerId: map['winnerId'],
      winnerName: map['winnerName'],
    );
  }

  factory WeeklyWarModel.fromFirestore(DocumentSnapshot doc) {
    return WeeklyWarModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

class WarEntryModel {
  final String memberId;
  final String
  memberName; // Stored separately if needed, but often fetched via join or assumed available
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

  factory WarEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return WarEntryModel(
      memberId: map['memberId'] ?? id,
      memberName:
          map['memberName'] ??
          '', // Might not be in doc directly, handle carefully
      totalReps: map['totalReps'] ?? 0,
      sessionCount: map['sessionCount'] ?? 0,
      lastUpdated: _toDateTime(map['lastUpdated']),
      rank: map['rank'],
      xpAwarded: map['xpAwarded'],
    );
  }

  factory WarEntryModel.fromFirestore(DocumentSnapshot doc) {
    return WarEntryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}
