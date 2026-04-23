import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/core/utils/date_time_utils.dart';

class HealthProfileModel {
  final String id;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPct;
  final double? waistCm;
  final double? chestCm;
  final double? armCm;
  final double? hipCm;
  final int? bpSystolic;
  final int? bpDiastolic;
  final int? restingHeartRate;
  final double? bmi;
  final String? bloodGroup;
  final String? fitnessGoal;
  final String? fitnessLevel;
  final List<String> jointRestrictions;
  final List<String> medicalConditions;
  final String? dietaryPreference;
  final DateTime? lastUpdated;

  const HealthProfileModel({
    required this.id,
    this.weightKg,
    this.heightCm,
    this.bodyFatPct,
    this.waistCm,
    this.chestCm,
    this.armCm,
    this.hipCm,
    this.bpSystolic,
    this.bpDiastolic,
    this.restingHeartRate,
    this.bmi,
    this.bloodGroup,
    this.fitnessGoal,
    this.fitnessLevel,
    this.jointRestrictions = const [],
    this.medicalConditions = const [],
    this.dietaryPreference,
    this.lastUpdated,
  });

  factory HealthProfileModel.fromMap(Map<String, dynamic> map, String id) {
    final weight = _toDouble(map['weightKg']);
    final height = _toDouble(map['heightCm']);

    double? calculatedBmi;
    if (weight != null && height != null && height > 0) {
      calculatedBmi = weight / ((height / 100) * (height / 100));
    }

    return HealthProfileModel(
      id: id,
      weightKg: weight,
      heightCm: height,
      bodyFatPct: _toDouble(map['bodyFatPct']),
      waistCm: _toDouble(map['waistCm']),
      chestCm: _toDouble(map['chestCm']),
      armCm: _toDouble(map['armCm']),
      hipCm: _toDouble(map['hipCm']),
      bpSystolic: map['bpSystolic'] as int?,
      bpDiastolic: map['bpDiastolic'] as int?,
      restingHeartRate: map['restingHeartRate'] as int?,
      bmi: calculatedBmi ?? _toDouble(map['bmi']),
      bloodGroup: map['bloodGroup'] as String?,
      fitnessGoal: map['fitnessGoal'] as String?,
      fitnessLevel: map['fitnessLevel'] as String?,
      jointRestrictions:
          (map['jointRestrictions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      medicalConditions:
          (map['medicalConditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      dietaryPreference: map['dietaryPreference'] as String?,
      lastUpdated: DateTimeUtils.toDateTimeNullable(map['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weightKg': weightKg,
      'heightCm': heightCm,
      'bodyFatPct': bodyFatPct,
      'waistCm': waistCm,
      'chestCm': chestCm,
      'armCm': armCm,
      'hipCm': hipCm,
      'bpSystolic': bpSystolic,
      'bpDiastolic': bpDiastolic,
      'restingHeartRate': restingHeartRate,
      'bmi': bmi,
      'bloodGroup': bloodGroup,
      'fitnessGoal': fitnessGoal,
      'fitnessLevel': fitnessLevel,
      'jointRestrictions': jointRestrictions,
      'medicalConditions': medicalConditions,
      'dietaryPreference': dietaryPreference,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  HealthProfileModel copyWith({
    String? id,
    double? weightKg,
    double? heightCm,
    double? bodyFatPct,
    double? waistCm,
    double? chestCm,
    double? armCm,
    double? hipCm,
    int? bpSystolic,
    int? bpDiastolic,
    int? restingHeartRate,
    double? bmi,
    String? bloodGroup,
    String? fitnessGoal,
    String? fitnessLevel,
    List<String>? jointRestrictions,
    List<String>? medicalConditions,
    String? dietaryPreference,
    DateTime? lastUpdated,
  }) {
    final newWeight = weightKg ?? this.weightKg;
    final newHeight = heightCm ?? this.heightCm;

    double? newBmi = bmi ?? this.bmi;
    if ((weightKg != null || heightCm != null) &&
        newWeight != null &&
        newHeight != null &&
        newHeight > 0) {
      newBmi = newWeight / ((newHeight / 100) * (newHeight / 100));
    }

    return HealthProfileModel(
      id: id ?? this.id,
      weightKg: newWeight,
      heightCm: newHeight,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      waistCm: waistCm ?? this.waistCm,
      chestCm: chestCm ?? this.chestCm,
      armCm: armCm ?? this.armCm,
      hipCm: hipCm ?? this.hipCm,
      bpSystolic: bpSystolic ?? this.bpSystolic,
      bpDiastolic: bpDiastolic ?? this.bpDiastolic,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      bmi: newBmi,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      jointRestrictions: jointRestrictions ?? this.jointRestrictions,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  static String bpCategory(int systolic, int diastolic) {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic >= 120 && systolic <= 129 && diastolic < 80) return 'Elevated';
    if ((systolic >= 130 && systolic <= 139) ||
        (diastolic >= 80 && diastolic <= 89)) {
      return 'Stage 1 Hypertension';
    }
    if (systolic > 180 || diastolic > 120) return 'Hypertensive Crisis';
    if (systolic >= 140 || diastolic >= 90) return 'Stage 2 Hypertension';

    return 'Normal'; // Fallback
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
