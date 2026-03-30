import 'package:cloud_firestore/cloud_firestore.dart';

class MemberIntelligenceModel {
  final String id;
  final List<String> strongLifts;
  final List<String> weakLifts;
  final List<String> preferredExercises;
  final List<String> avoidedExercises;
  final List<String> injuryHistory;
  final double avgSessionRpe;
  final int totalSessionsLogged;
  final Timestamp? lastSessionDate;
  final List<String> plateauWarnings;
  final String? bestPerformanceTime;
  final String? dietAdherence;
  final List<String> trainerObservations;
  final int? latestFlexibilityScore;
  final List<String> tightAreas;
  final Timestamp updatedAt;

  MemberIntelligenceModel({
    required this.id,
    required this.strongLifts,
    required this.weakLifts,
    required this.preferredExercises,
    required this.avoidedExercises,
    required this.injuryHistory,
    required this.avgSessionRpe,
    required this.totalSessionsLogged,
    this.lastSessionDate,
    required this.plateauWarnings,
    this.bestPerformanceTime,
    this.dietAdherence,
    required this.trainerObservations,
    this.latestFlexibilityScore,
    required this.tightAreas,
    required this.updatedAt,
  });

  factory MemberIntelligenceModel.fromMap(Map<String, dynamic> data, String id) {
    return MemberIntelligenceModel(
      id: id,
      strongLifts: data['strongLifts'] != null
          ? List<String>.from(data['strongLifts'] as List)
          : [],
      weakLifts: data['weakLifts'] != null
          ? List<String>.from(data['weakLifts'] as List)
          : [],
      preferredExercises: data['preferredExercises'] != null
          ? List<String>.from(data['preferredExercises'] as List)
          : [],
      avoidedExercises: data['avoidedExercises'] != null
          ? List<String>.from(data['avoidedExercises'] as List)
          : [],
      injuryHistory: data['injuryHistory'] != null
          ? List<String>.from(data['injuryHistory'] as List)
          : [],
      avgSessionRpe: (data['avgSessionRpe'] as num?)?.toDouble() ?? 0.0,
      totalSessionsLogged: data['totalSessionsLogged'] as int? ?? 0,
      lastSessionDate: data['lastSessionDate'] as Timestamp?,
      plateauWarnings: data['plateauWarnings'] != null
          ? List<String>.from(data['plateauWarnings'] as List)
          : [],
      bestPerformanceTime: data['bestPerformanceTime'] as String?,
      dietAdherence: data['dietAdherence'] as String?,
      trainerObservations: data['trainerObservations'] != null
          ? List<String>.from(data['trainerObservations'] as List)
          : [],
      latestFlexibilityScore: data['latestFlexibilityScore'] as int?,
      tightAreas: data['tightAreas'] != null
          ? List<String>.from(data['tightAreas'] as List)
          : [],
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'strongLifts': strongLifts,
      'weakLifts': weakLifts,
      'preferredExercises': preferredExercises,
      'avoidedExercises': avoidedExercises,
      'injuryHistory': injuryHistory,
      'avgSessionRpe': avgSessionRpe,
      'totalSessionsLogged': totalSessionsLogged,
      if (lastSessionDate != null) 'lastSessionDate': lastSessionDate,
      'plateauWarnings': plateauWarnings,
      if (bestPerformanceTime != null) 'bestPerformanceTime': bestPerformanceTime,
      if (dietAdherence != null) 'dietAdherence': dietAdherence,
      'trainerObservations': trainerObservations,
      if (latestFlexibilityScore != null) 'latestFlexibilityScore': latestFlexibilityScore,
      'tightAreas': tightAreas,
      'updatedAt': updatedAt,
    };
  }

  MemberIntelligenceModel copyWith({
    List<String>? strongLifts,
    List<String>? weakLifts,
    List<String>? preferredExercises,
    List<String>? avoidedExercises,
    List<String>? injuryHistory,
    double? avgSessionRpe,
    int? totalSessionsLogged,
    Timestamp? lastSessionDate,
    List<String>? plateauWarnings,
    String? bestPerformanceTime,
    String? dietAdherence,
    List<String>? trainerObservations,
    int? latestFlexibilityScore,
    List<String>? tightAreas,
    Timestamp? updatedAt,
  }) {
    return MemberIntelligenceModel(
      id: id,
      strongLifts: strongLifts ?? this.strongLifts,
      weakLifts: weakLifts ?? this.weakLifts,
      preferredExercises: preferredExercises ?? this.preferredExercises,
      avoidedExercises: avoidedExercises ?? this.avoidedExercises,
      injuryHistory: injuryHistory ?? this.injuryHistory,
      avgSessionRpe: avgSessionRpe ?? this.avgSessionRpe,
      totalSessionsLogged: totalSessionsLogged ?? this.totalSessionsLogged,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      plateauWarnings: plateauWarnings ?? this.plateauWarnings,
      bestPerformanceTime: bestPerformanceTime ?? this.bestPerformanceTime,
      dietAdherence: dietAdherence ?? this.dietAdherence,
      trainerObservations: trainerObservations ?? this.trainerObservations,
      latestFlexibilityScore: latestFlexibilityScore ?? this.latestFlexibilityScore,
      tightAreas: tightAreas ?? this.tightAreas,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
