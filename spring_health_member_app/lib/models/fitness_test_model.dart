import 'package:cloud_firestore/cloud_firestore.dart';

class FitnessTestModel {
  final String id;
  final String memberId;
  final int? pushupsMax;
  final int? pullupsMax;
  final int? squatsMax;
  final int? dipsMax;
  final double? plankSeconds;
  final double? squat1rmKg;
  final double? deadlift1rmKg;
  final double? benchpress1rmKg;
  final String? overallLevel;
  final DateTime testedAt;
  final DateTime? nextTestDue;

  const FitnessTestModel({
    required this.id,
    required this.memberId,
    this.pushupsMax,
    this.pullupsMax,
    this.squatsMax,
    this.dipsMax,
    this.plankSeconds,
    this.squat1rmKg,
    this.deadlift1rmKg,
    this.benchpress1rmKg,
    this.overallLevel,
    required this.testedAt,
    this.nextTestDue,
  });

  factory FitnessTestModel.fromMap(Map<String, dynamic> map, String id) {
    return FitnessTestModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      pushupsMax: map['pushupsMax'] as int?,
      pullupsMax: map['pullupsMax'] as int?,
      squatsMax: map['squatsMax'] as int?,
      dipsMax: map['dipsMax'] as int?,
      plankSeconds: _toDouble(map['plankSeconds']),
      squat1rmKg: _toDouble(map['squat1rmKg']),
      deadlift1rmKg: _toDouble(map['deadlift1rmKg']),
      benchpress1rmKg: _toDouble(map['benchpress1rmKg']),
      overallLevel: map['overallLevel'] as String?,
      testedAt: _toDateTime(map['testedAt']),
      nextTestDue: _toDateTimeNullable(map['nextTestDue']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'pushupsMax': pushupsMax,
      'pullupsMax': pullupsMax,
      'squatsMax': squatsMax,
      'dipsMax': dipsMax,
      'plankSeconds': plankSeconds,
      'squat1rmKg': squat1rmKg,
      'deadlift1rmKg': deadlift1rmKg,
      'benchpress1rmKg': benchpress1rmKg,
      'overallLevel': overallLevel,
      'testedAt': Timestamp.fromDate(testedAt),
      'nextTestDue':
          nextTestDue != null ? Timestamp.fromDate(nextTestDue!) : null,
    };
  }

  FitnessTestModel copyWith({
    String? id,
    String? memberId,
    int? pushupsMax,
    int? pullupsMax,
    int? squatsMax,
    int? dipsMax,
    double? plankSeconds,
    double? squat1rmKg,
    double? deadlift1rmKg,
    double? benchpress1rmKg,
    String? overallLevel,
    DateTime? testedAt,
    DateTime? nextTestDue,
  }) {
    return FitnessTestModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      pushupsMax: pushupsMax ?? this.pushupsMax,
      pullupsMax: pullupsMax ?? this.pullupsMax,
      squatsMax: squatsMax ?? this.squatsMax,
      dipsMax: dipsMax ?? this.dipsMax,
      plankSeconds: plankSeconds ?? this.plankSeconds,
      squat1rmKg: squat1rmKg ?? this.squat1rmKg,
      deadlift1rmKg: deadlift1rmKg ?? this.deadlift1rmKg,
      benchpress1rmKg: benchpress1rmKg ?? this.benchpress1rmKg,
      overallLevel: overallLevel ?? this.overallLevel,
      testedAt: testedAt ?? this.testedAt,
      nextTestDue: nextTestDue ?? this.nextTestDue,
    );
  }

  static String deriveOverallLevel({
    int? pushups,
    int? pullups,
    double? plank,
  }) {
    final pu = pushups ?? 0;
    final pll = pullups ?? 0;
    final plk = plank ?? 0.0;

    if (pu >= 30 && pll >= 10 && plk >= 120) {
      return 'advanced';
    } else if (pu >= 15 && pll >= 5 && plk >= 60) {
      return 'intermediate';
    } else {
      return 'beginner';
    }
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  static DateTime? _toDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }
}
