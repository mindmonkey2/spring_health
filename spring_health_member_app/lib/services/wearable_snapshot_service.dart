import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/wearable_snapshot_model.dart';
import 'health_profile_service.dart';

class WearableSnapshotService {
  WearableSnapshotService._internal({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance,
      _health = Health();

  static final WearableSnapshotService instance = WearableSnapshotService._internal();

  factory WearableSnapshotService({FirebaseFirestore? db}) {
    return WearableSnapshotService._internal(db: db);
  }

  final FirebaseFirestore _db;
  final Health _health;

  final List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_SDNN,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BODY_TEMPERATURE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.BASAL_ENERGY_BURNED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WATER,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.IRREGULAR_HEART_RATE_EVENT,
    HealthDataType.HIGH_HEART_RATE_EVENT,
    HealthDataType.LOW_HEART_RATE_EVENT,
  ];

  Future<WearableSnapshotModel?> syncTodaySnapshot(String memberId) async {
    try {
      // 1. Request permissions for available types
      List<HealthDataType> availableTypes = [];
      for (final type in _types) {
        try {
          final isRequested = await _health.requestAuthorization([type]);
          if (isRequested) {
            availableTypes.add(type);
          } else {
            debugPrint('⚠️ Health permissions not granted: $type');
          }
        } catch (e) {
          debugPrint('⚠️ Health type $type not available on platform: $e');
        }
      }

      if (availableTypes.isEmpty) {
        debugPrint('⚠️ No health permissions granted');
        return null;
      }

      // 2. Define time ranges
      final now = DateTime.now();
      final last24h = now.subtract(const Duration(hours: 24));

      final yesterdayAt6pm = DateTime(now.year, now.month, now.day - 1, 18);

      // Use yesterdayAt6pm -> todayAt10am for sleep, else last24h -> now
      // Note: `health` package `getHealthDataFromTypes` takes a single start and end time.
      // So we fetch everything from yesterday at 6pm to now to be safe.
      final startTime = yesterdayAt6pm.isBefore(last24h) ? yesterdayAt6pm : last24h;

      // 3. Fetch health data
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: availableTypes,
        startTime: startTime,
        endTime: now,
      );

      // 4. Aggregate data
      int steps = 0;
      double? weightKg;
      double? bpSystolic;
      double? bpDiastolic;
      double? restingHeartRate;
      double? heartRateVariability;
      double? bloodOxygen;
      double? respiratoryRate;
      double? bodyTemperature;
      bool irregularHeartRateEvent = false;

      double? bodyFatPercentage;
      double activeCaloriesBurned = 0;
      double? basalCaloriesBurned;
      int exerciseMinutes = 0;
      double? distanceMeters;

      int totalSleepMinutes = 0;
      int deepSleepMinutes = 0;
      int remSleepMinutes = 0;
      int awakeDuringSleepMinutes = 0;

      double? bloodGlucoseMgDl;
      double? waterLitres;

      List<double> heartRates = [];

      for (var point in healthData) {
        final val = point.value;
        if (val is NumericHealthValue) {
          final doubleValue = val.numericValue.toDouble();

          switch (point.type) {
            case HealthDataType.STEPS:
              if (point.dateFrom.isAfter(last24h)) {
                steps += doubleValue.toInt();
              }
              break;
            case HealthDataType.HEART_RATE:
              if (point.dateFrom.isAfter(last24h)) {
                heartRates.add(doubleValue);
              }
              break;
            case HealthDataType.RESTING_HEART_RATE:
              if (point.dateFrom.isAfter(last24h)) {
                restingHeartRate = doubleValue; // latest value
              }
              break;
            case HealthDataType.HEART_RATE_VARIABILITY_SDNN:
              if (point.dateFrom.isAfter(last24h)) {
                heartRateVariability = doubleValue;
              }
              break;
            case HealthDataType.BLOOD_OXYGEN:
              if (point.dateFrom.isAfter(last24h)) {
                bloodOxygen = doubleValue;
              }
              break;
            case HealthDataType.RESPIRATORY_RATE:
              if (point.dateFrom.isAfter(last24h)) {
                respiratoryRate = doubleValue;
              }
              break;
            case HealthDataType.BODY_TEMPERATURE:
              if (point.dateFrom.isAfter(last24h)) {
                bodyTemperature = doubleValue;
              }
              break;
            case HealthDataType.WEIGHT:
              if (point.dateFrom.isAfter(last24h)) {
                weightKg = doubleValue;
              }
              break;
            case HealthDataType.BODY_FAT_PERCENTAGE:
              if (point.dateFrom.isAfter(last24h)) {
                bodyFatPercentage = doubleValue;
              }
              break;
            case HealthDataType.ACTIVE_ENERGY_BURNED:
              if (point.dateFrom.isAfter(last24h)) {
                activeCaloriesBurned += doubleValue;
              }
              break;
            case HealthDataType.BASAL_ENERGY_BURNED:
              if (point.dateFrom.isAfter(last24h)) {
                basalCaloriesBurned = (basalCaloriesBurned ?? 0) + doubleValue;
              }
              break;
            case HealthDataType.EXERCISE_TIME:
              if (point.dateFrom.isAfter(last24h)) {
                exerciseMinutes += doubleValue.toInt();
              }
              break;
            case HealthDataType.DISTANCE_WALKING_RUNNING:
              if (point.dateFrom.isAfter(last24h)) {
                distanceMeters = (distanceMeters ?? 0) + doubleValue;
              }
              break;
            case HealthDataType.BLOOD_GLUCOSE:
              if (point.dateFrom.isAfter(last24h)) {
                bloodGlucoseMgDl = doubleValue;
              }
              break;
            case HealthDataType.WATER:
              if (point.dateFrom.isAfter(last24h)) {
                waterLitres = (waterLitres ?? 0) + doubleValue;
              }
              break;
            case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
              if (point.dateFrom.isAfter(last24h)) {
                bpSystolic = doubleValue;
              }
              break;
            case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
              if (point.dateFrom.isAfter(last24h)) {
                bpDiastolic = doubleValue;
              }
              break;
            default:
              break;
          }
        }

        // Sleep handling: depending on platform, sleep might be a sleep session or discrete types
        if (point.type == HealthDataType.SLEEP_ASLEEP ||
            point.type == HealthDataType.SLEEP_DEEP ||
            point.type == HealthDataType.SLEEP_REM ||
            point.type == HealthDataType.SLEEP_AWAKE) {

          final duration = point.dateTo.difference(point.dateFrom).inMinutes;

          switch (point.type) {
             case HealthDataType.SLEEP_ASLEEP:
                totalSleepMinutes += duration;
                break;
             case HealthDataType.SLEEP_DEEP:
                deepSleepMinutes += duration;
                break;
             case HealthDataType.SLEEP_REM:
                remSleepMinutes += duration;
                break;
             case HealthDataType.SLEEP_AWAKE:
                awakeDuringSleepMinutes += duration;
                break;
             default:
                break;
          }
        }

        // Irregular heart rate event
        if (point.type == HealthDataType.IRREGULAR_HEART_RATE_EVENT) {
          if (point.dateFrom.isAfter(last24h)) {
            irregularHeartRateEvent = true;
          }
        }
      }

      double? avgHeartRateDuringDay;
      if (heartRates.isNotEmpty) {
        avgHeartRateDuringDay = heartRates.reduce((a, b) => a + b) / heartRates.length;
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      final rawSnapshot = WearableSnapshotModel.fromMap({
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
        'syncedAt': Timestamp.now(),
      }, dateStr);

      // 5. Write to Firestore
      final snapshotRef = _db
          .collection('wearableSnapshots')
          .doc(memberId)
          .collection('daily')
          .doc(dateStr);

      await snapshotRef.set(rawSnapshot.toMap());

      // 6. Update HealthProfileModel
      if (weightKg != null || bpSystolic != null || bpDiastolic != null || restingHeartRate != null) {
        try {
           final profileService = HealthProfileService(db: _db);
           final currentProfile = await profileService.getHealthProfile(memberId);
           if (currentProfile != null) {
             final updatedProfile = currentProfile.copyWith(
               weightKg: weightKg ?? currentProfile.weightKg,
               bpSystolic: bpSystolic?.toInt() ?? currentProfile.bpSystolic,
               bpDiastolic: bpDiastolic?.toInt() ?? currentProfile.bpDiastolic,
             );

             // HealthProfileModel may not have restingHeartRate yet but will use saveHealthProfile
             await profileService.saveHealthProfile(updatedProfile);
           }
        } catch (e) {
           debugPrint('⚠️ Failed to update HealthProfile from wearables: $e');
        }
      }

      return rawSnapshot;
    } catch (e) {
      debugPrint('⚠️ Error syncing wearable snapshot: $e');
      return null;
    }
  }

  Future<List<WearableSnapshotModel>> getLatestSnapshots(String memberId, {int days = 7}) async {
    try {
      final snapshot = await _db
          .collection('wearableSnapshots')
          .doc(memberId)
          .collection('daily')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(days)
          .get();

      return snapshot.docs
          .map((doc) => WearableSnapshotModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('⚠️ Error getting latest wearable snapshots: $e');
      return [];
    }
  }

  Future<WearableSnapshotModel?> getTodaySnapshot(String memberId) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);

      final doc = await _db
          .collection('wearableSnapshots')
          .doc(memberId)
          .collection('daily')
          .doc(dateStr)
          .get();

      if (doc.exists && doc.data() != null) {
        return WearableSnapshotModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error getting today wearable snapshot: $e');
      return null;
    }
  }
}
