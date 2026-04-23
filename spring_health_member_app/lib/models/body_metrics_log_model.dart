import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/core/utils/date_time_utils.dart';

class BodyMetricsLogModel {
  final String id;
  final String memberId;
  final double? weightKg;
  final double? bodyFatPct;
  final double? waistCm;
  final double? chestCm;
  final double? armCm;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? restingHeartRate;
  final String? notes;
  final DateTime loggedAt;

  const BodyMetricsLogModel({
    required this.id,
    required this.memberId,
    this.weightKg,
    this.bodyFatPct,
    this.waistCm,
    this.chestCm,
    this.armCm,
    this.bpSystolic,
    this.bpDiastolic,
    this.restingHeartRate,
    this.notes,
    required this.loggedAt,
  });

  factory BodyMetricsLogModel.fromMap(Map<String, dynamic> map, String id) {
    return BodyMetricsLogModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      weightKg: _toDouble(map['weightKg']),
      bodyFatPct: _toDouble(map['bodyFatPct']),
      waistCm: _toDouble(map['waistCm']),
      chestCm: _toDouble(map['chestCm']),
      armCm: _toDouble(map['armCm']),
      bpSystolic: map['bpSystolic'] as int?,
      bpDiastolic: map['bpDiastolic'] as int?,
      restingHeartRate: map['restingHeartRate'] as int?,
      notes: map['notes'] as String?,
      loggedAt: DateTimeUtils.toDateTime(map['loggedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'weightKg': weightKg,
      'bodyFatPct': bodyFatPct,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'armCm': armCm,
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'restingHeartRate': restingHeartRate,
      'notes': notes,
      'loggedAt': Timestamp.fromDate(loggedAt),
    };
  }

  BodyMetricsLogModel copyWith({
    String? id,
    String? memberId,
    double? weightKg,
    double? bodyFatPct,
    double? waistCm,
    double? chestCm,
    double? armCm,
    int? bpSystolic,
    int? bpDiastolic,
    int? restingHeartRate,
    String? notes,
    DateTime? loggedAt,
  }) {
    return BodyMetricsLogModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      armCm: armCm ?? this.armCm,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      notes: notes ?? this.notes,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
