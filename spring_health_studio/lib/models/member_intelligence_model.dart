class MemberIntelligenceModel {
  final String id;
  final List<String> strongLifts;
  final List<String> weakLifts;
  final List<String> injuryHistory;
  final int totalSessionsLogged;
  final List<String> tightAreas;
  final int latestFlexibilityScore;

  MemberIntelligenceModel({
    required this.id,
    required this.strongLifts,
    required this.weakLifts,
    required this.injuryHistory,
    required this.totalSessionsLogged,
    required this.tightAreas,
    required this.latestFlexibilityScore,
  });

  factory MemberIntelligenceModel.fromMap(Map<String, dynamic> map, String id) {
    return MemberIntelligenceModel(
      id: id,
      strongLifts: List<String>.from(map['strongLifts'] ?? []),
      weakLifts: List<String>.from(map['weakLifts'] ?? []),
      injuryHistory: List<String>.from(map['injuryHistory'] ?? []),
      totalSessionsLogged: map['totalSessionsLogged'] as int? ?? 0,
      tightAreas: List<String>.from(map['tightAreas'] ?? []),
      latestFlexibilityScore: map['latestFlexibilityScore'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'strongLifts': strongLifts,
      'weakLifts': weakLifts,
      'injuryHistory': injuryHistory,
      'totalSessionsLogged': totalSessionsLogged,
      'tightAreas': tightAreas,
      'latestFlexibilityScore': latestFlexibilityScore,
    };
  }
}
