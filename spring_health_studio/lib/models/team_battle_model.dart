import 'package:cloud_firestore/cloud_firestore.dart';

class TeamBattleModel {
  final String id;
  final String organizerTrainerId;
  final String organizerName;
  final Map<String, dynamic> team1;
  // { trainerId: String, trainerName: String, memberIds: List<String> }
  final Map<String, dynamic> team2;
  final String metric;
  // 'total_sessions' | 'total_weight_lifted' | 'combined_attendance_days'
  final String title;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final double team1Score;
  final double team2Score;
  final String status; // 'active' | 'complete'
  final String winnerId; // 'team1' | 'team2' | 'draw' | ''
  final DateTime createdAt;

  TeamBattleModel({
    required this.id,
    required this.organizerTrainerId,
    required this.organizerName,
    required this.team1,
    required this.team2,
    required this.metric,
    required this.title,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.team1Score,
    required this.team2Score,
    required this.status,
    required this.winnerId,
    required this.createdAt,
  });

  factory TeamBattleModel.fromMap(Map<String, dynamic> data, String id) {
    return TeamBattleModel(
      id: id,
      organizerTrainerId: data['organizerTrainerId'] as String? ?? '',
      organizerName: data['organizerName'] as String? ?? '',
      team1: data['team1'] as Map<String, dynamic>? ?? {},
      team2: data['team2'] as Map<String, dynamic>? ?? {},
      metric: data['metric'] as String? ?? 'total_sessions',
      title: data['title'] as String? ?? 'Team Battle',
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 7,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      team1Score: (data['team1Score'] as num?)?.toDouble() ?? 0.0,
      team2Score: (data['team2Score'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] as String? ?? 'active',
      winnerId: data['winnerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizerTrainerId': organizerTrainerId,
      'organizerName': organizerName,
      'team1': team1,
      'team2': team2,
      'metric': metric,
      'title': title,
      'durationDays': durationDays,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'team1Score': team1Score,
      'team2Score': team2Score,
      'status': status,
      'winnerId': winnerId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TeamBattleModel copyWith({
    String? id,
    String? organizerTrainerId,
    String? organizerName,
    Map<String, dynamic>? team1,
    Map<String, dynamic>? team2,
    String? metric,
    String? title,
    int? durationDays,
    DateTime? startDate,
    DateTime? endDate,
    double? team1Score,
    double? team2Score,
    String? status,
    String? winnerId,
    DateTime? createdAt,
  }) {
    return TeamBattleModel(
      id: id ?? this.id,
      organizerTrainerId: organizerTrainerId ?? this.organizerTrainerId,
      organizerName: organizerName ?? this.organizerName,
      team1: team1 ?? this.team1,
      team2: team2 ?? this.team2,
      metric: metric ?? this.metric,
      title: title ?? this.title,
      durationDays: durationDays ?? this.durationDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
