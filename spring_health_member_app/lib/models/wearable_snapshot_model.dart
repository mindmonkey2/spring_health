import 'package:cloud_firestore/cloud_firestore.dart';

class WearableSnapshotModel {
  final String id;
  final String memberId;

  // Cardiovascular
  final double? restingHeartRate;
  final double? heartRateVariability;
  final double? bloodOxygen;
  final double? respiratoryRate;
  final double? bodyTemperature;
  final bool irregularHeartRateEvent;
  final double? avgHeartRateDuringDay;

  // Body
  final double? weightKg;
  final double? bodyFatPercentage;

  // Activity
  final int steps;
  final double activeCaloriesBurned;
  final double? basalCaloriesBurned;
  final int exerciseMinutes;
  final double? distanceMeters;

  // Sleep
  final int totalSleepMinutes;
  final int deepSleepMinutes;
  final int remSleepMinutes;
  final int awakeDuringSleepMinutes;

  // Metabolic
  final double? bloodGlucoseMgDl;
  final double? waterLitres;

  // Computed
  final double? totalDailyCalories;
  final String sleepQuality;
  final String recoveryStatus;

  final Timestamp syncedAt;

  const WearableSnapshotModel({
    required this.id,
    required this.memberId,
    this.restingHeartRate,
    this.heartRateVariability,
    this.bloodOxygen,
    this.respiratoryRate,
    this.bodyTemperature,
    this.irregularHeartRateEvent = false,
    this.avgHeartRateDuringDay,
    this.weightKg,
    this.bodyFatPercentage,
    this.steps = 0,
    this.activeCaloriesBurned = 0,
    this.basalCaloriesBurned,
    this.exerciseMinutes = 0,
    this.distanceMeters,
    this.totalSleepMinutes = 0,
    this.deepSleepMinutes = 0,
    this.remSleepMinutes = 0,
    this.awakeDuringSleepMinutes = 0,
    this.bloodGlucoseMgDl,
    this.waterLitres,
    this.totalDailyCalories,
    required this.sleepQuality,
    required this.recoveryStatus,
    required this.syncedAt,
  });

  factory WearableSnapshotModel.fromMap(Map<String, dynamic> map, String id) {
    final int totalSleepMinutes = (map['totalSleepMinutes'] as num?)?.toInt() ?? 0;
    final int deepSleepMinutes = (map['deepSleepMinutes'] as num?)?.toInt() ?? 0;

    // Derived Sleep Quality
    String sleepQuality = 'poor';
    if (deepSleepMinutes >= 90 && totalSleepMinutes >= 420) {
      sleepQuality = 'excellent';
    } else if (deepSleepMinutes >= 60 && totalSleepMinutes >= 360) {
      sleepQuality = 'good';
    } else if (deepSleepMinutes >= 30 && totalSleepMinutes >= 300) {
      sleepQuality = 'fair';
    }

    final double? bodyTemperature = (map['bodyTemperature'] as num?)?.toDouble();
    final bool irregularHeartRateEvent = map['irregularHeartRateEvent'] as bool? ?? false;
    final double? hrv = (map['heartRateVariability'] as num?)?.toDouble();

    // Derived Recovery Status
    String recoveryStatus;
    if (bodyTemperature != null && bodyTemperature > 37.5) {
      recoveryStatus = 'sick';
    } else if (irregularHeartRateEvent) {
      recoveryStatus = 'cardiac_flag';
    } else if (hrv != null) {
      if (hrv >= 60 && sleepQuality == 'excellent') {
        recoveryStatus = 'fully_recovered';
      } else if (hrv >= 45 && sleepQuality != 'poor') {
        recoveryStatus = 'recovered';
      } else if (hrv >= 30 || sleepQuality == 'good') {
        recoveryStatus = 'moderate';
      } else {
        recoveryStatus = 'fatigued';
      }
    } else {
      // Fallback if HRV is null
      if (sleepQuality == 'excellent') {
        recoveryStatus = 'fully_recovered';
      } else if (sleepQuality == 'good') {
        recoveryStatus = 'recovered';
      } else if (sleepQuality == 'fair') {
        recoveryStatus = 'moderate';
      } else {
        recoveryStatus = 'fatigued';
      }
    }

    final double activeCaloriesBurned = (map['activeCaloriesBurned'] as num?)?.toDouble() ?? 0;
    final double? basalCaloriesBurned = (map['basalCaloriesBurned'] as num?)?.toDouble();
    double? totalDailyCalories;
    if (basalCaloriesBurned != null) {
      totalDailyCalories = basalCaloriesBurned + activeCaloriesBurned;
    }

    return WearableSnapshotModel(
      id: id,
      memberId: map['memberId'] as String? ?? '',
      restingHeartRate: (map['restingHeartRate'] as num?)?.toDouble(),
      heartRateVariability: hrv,
      bloodOxygen: (map['bloodOxygen'] as num?)?.toDouble(),
      respiratoryRate: (map['respiratoryRate'] as num?)?.toDouble(),
      bodyTemperature: bodyTemperature,
      irregularHeartRateEvent: irregularHeartRateEvent,
      avgHeartRateDuringDay: (map['avgHeartRateDuringDay'] as num?)?.toDouble(),
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bodyFatPercentage: (map['bodyFatPercentage'] as num?)?.toDouble(),
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      activeCaloriesBurned: activeCaloriesBurned,
      basalCaloriesBurned: basalCaloriesBurned,
      exerciseMinutes: (map['exerciseMinutes'] as num?)?.toInt() ?? 0,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble(),
      totalSleepMinutes: totalSleepMinutes,
      deepSleepMinutes: deepSleepMinutes,
      remSleepMinutes: (map['remSleepMinutes'] as num?)?.toInt() ?? 0,
      awakeDuringSleepMinutes: (map['awakeDuringSleepMinutes'] as num?)?.toInt() ?? 0,
      bloodGlucoseMgDl: (map['bloodGlucoseMgDl'] as num?)?.toDouble(),
      waterLitres: (map['waterLitres'] as num?)?.toDouble(),
      totalDailyCalories: totalDailyCalories,
      sleepQuality: sleepQuality,
      recoveryStatus: recoveryStatus,
      syncedAt: map['syncedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'restingHeartRate': restingHeartRate,
      'heartRateVariability': heartRateVariability,
      'bloodOxygen': bloodOxygen,
      'respiratoryRate': respiratoryRate,
      'bodyTemperature': bodyTemperature,
      'irregularHeartRateEvent': irregularHeartRateEvent,
      'avgHeartRateDuringDay': avgHeartRateDuringDay,
      'weightKg': weightKg,
      'bodyFatPercentage': bodyFatPercentage,
      'steps': steps,
      'activeCaloriesBurned': activeCaloriesBurned,
      'basalCaloriesBurned': basalCaloriesBurned,
      'exerciseMinutes': exerciseMinutes,
      'distanceMeters': distanceMeters,
      'totalSleepMinutes': totalSleepMinutes,
      'deepSleepMinutes': deepSleepMinutes,
      'remSleepMinutes': remSleepMinutes,
      'awakeDuringSleepMinutes': awakeDuringSleepMinutes,
      'bloodGlucoseMgDl': bloodGlucoseMgDl,
      'waterLitres': waterLitres,
      'totalDailyCalories': totalDailyCalories,
      'sleepQuality': sleepQuality,
      'recoveryStatus': recoveryStatus,
      'syncedAt': syncedAt,
    };
  }

  WearableSnapshotModel copyWith({
    String? id,
    String? memberId,
    double? restingHeartRate,
    double? heartRateVariability,
    double? bloodOxygen,
    double? respiratoryRate,
    double? bodyTemperature,
    bool? irregularHeartRateEvent,
    double? avgHeartRateDuringDay,
    double? weightKg,
    double? bodyFatPercentage,
    int? steps,
    double? activeCaloriesBurned,
    double? basalCaloriesBurned,
    int? exerciseMinutes,
    double? distanceMeters,
    int? totalSleepMinutes,
    int? deepSleepMinutes,
    int? remSleepMinutes,
    int? awakeDuringSleepMinutes,
    double? bloodGlucoseMgDl,
    double? waterLitres,
    double? totalDailyCalories,
    String? sleepQuality,
    String? recoveryStatus,
    Timestamp? syncedAt,
  }) {
    return WearableSnapshotModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      heartRateVariability: heartRateVariability ?? this.heartRateVariability,
      bloodOxygen: bloodOxygen ?? this.bloodOxygen,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      bodyTemperature: bodyTemperature ?? this.bodyTemperature,
      irregularHeartRateEvent: irregularHeartRateEvent ?? this.irregularHeartRateEvent,
      avgHeartRateDuringDay: avgHeartRateDuringDay ?? this.avgHeartRateDuringDay,
      weightKg: weightKg ?? this.weightKg,
      bodyFatPercentage: bodyFatPercentage ?? this.bodyFatPercentage,
      steps: steps ?? this.steps,
      activeCaloriesBurned: activeCaloriesBurned ?? this.activeCaloriesBurned,
      basalCaloriesBurned: basalCaloriesBurned ?? this.basalCaloriesBurned,
      exerciseMinutes: exerciseMinutes ?? this.exerciseMinutes,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      totalSleepMinutes: totalSleepMinutes ?? this.totalSleepMinutes,
      deepSleepMinutes: deepSleepMinutes ?? this.deepSleepMinutes,
      remSleepMinutes: remSleepMinutes ?? this.remSleepMinutes,
      awakeDuringSleepMinutes: awakeDuringSleepMinutes ?? this.awakeDuringSleepMinutes,
      bloodGlucoseMgDl: bloodGlucoseMgDl ?? this.bloodGlucoseMgDl,
      waterLitres: waterLitres ?? this.waterLitres,
      totalDailyCalories: totalDailyCalories ?? this.totalDailyCalories,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      recoveryStatus: recoveryStatus ?? this.recoveryStatus,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
