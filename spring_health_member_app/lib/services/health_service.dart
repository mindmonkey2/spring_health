import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/fitness_stats_model.dart';

enum HealthPermissionStatus { granted, denied, notDetermined, unavailable }

class HealthService {
  static final HealthService instance = HealthService._internal();
  factory HealthService() => instance;
  HealthService._internal();

  final Health _health = Health();
  bool _isInitialized = false;

  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.DISTANCE_DELTA, // Android specific distance
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;
    // FIX 1: useHealthConnectIfAvailable routes to HC on Android, HealthKit on iOS
    await _health.configure();
    _isInitialized = true;
  }

  // ─── Availability ─────────────────────────────────────────────────────────

  Future<bool> isAvailable() async {
    try {
      await initialize();
      if (Platform.isAndroid) {
        final status = await _health
            .getHealthConnectSdkStatus(); // FIX 5: use _health, not Health()
        debugPrint('[HealthService] SDK status: $status');
        return status != HealthConnectSdkStatus.sdkUnavailable;
      }
      return true;
    } catch (e) {
      debugPrint('[HealthService] isAvailable error: $e');
      return false;
    }
  }

  Future<bool> isConnected() async {
    final status = await checkPermissionStatus();
    return status == HealthPermissionStatus.granted;
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    await initialize();
    try {
      if (Platform.isAndroid) {
        // FIX 3: Check SDK status BEFORE requesting — this was causing silent false
        final sdkStatus = await _health.getHealthConnectSdkStatus();
        debugPrint('[HealthService] SDK status before request: $sdkStatus');

        if (sdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
          debugPrint(
            '[HealthService] Health Connect unavailable on this device',
          );
          return false;
        }

        if (sdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
          // Not installed — prompt install
          await _health.installHealthConnect();
          return false;
        }
        if (sdkStatus ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          // Installed but outdated — also prompt update via installHealthConnect()
          await _health.installHealthConnect();
          return false;
        }

        // FIX 2: Request activityRecognition independently — NEVER let it block HC
        // Samsung Android 15 may auto-deny this; that's fine, HC is separate
        await Permission.activityRecognition.request();
        // Intentionally not checking result ↑
      }

      final granted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      debugPrint('[HealthService] requestAuthorization result: $granted');
      return granted;
    } catch (e) {
      debugPrint('[HealthService] requestPermissions error: $e');
      return false;
    }
  }

  Future<HealthPermissionStatus> checkPermissionStatus() async {
    await initialize();
    try {
      if (Platform.isAndroid) {
        final sdkStatus = await _health.getHealthConnectSdkStatus();
        debugPrint('[HealthService] checkPermissionStatus SDK: $sdkStatus');
        if (sdkStatus == HealthConnectSdkStatus.sdkUnavailable) {
          return HealthPermissionStatus.unavailable;
        }
        if (sdkStatus ==
            HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
          return HealthPermissionStatus.notDetermined;
        }
      }

      final hasPerms = await _health.hasPermissions(
        _types,
        permissions: _permissions,
      );
      debugPrint('[HealthService] hasPermissions: $hasPerms');

      if (hasPerms == true) return HealthPermissionStatus.granted;

      // Android 14+: hasPermissions() always returns null for privacy reasons
      // even when fully granted. Probe by actually reading data to confirm.
      return await _probePermissionByReading();
    } catch (e) {
      debugPrint('[HealthService] checkPermissionStatus error: $e');
      return HealthPermissionStatus.notDetermined;
    }
  }

  /// Confirms HC permissions are active by attempting a real read.
  /// If it returns data (even 0 steps) → granted. If it throws → not granted.
  Future<HealthPermissionStatus> _probePermissionByReading() async {
    try {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      await _health.getTotalStepsInInterval(oneMinuteAgo, now);
      debugPrint('[HealthService] probe read succeeded → granted');
      return HealthPermissionStatus.granted;
    } catch (e) {
      debugPrint('[HealthService] probe read failed → $e');
      return HealthPermissionStatus.notDetermined;
    }
  }

  Future<void> openHealthConnectSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('[HealthService] openHealthConnectSettings error: $e');
    }
  }

  // ─── Today's Stats ────────────────────────────────────────────────────────

  Future<FitnessStats> getTodayStats() async {
    await initialize();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      int steps = 0;
      try {
        final val = await _health.getTotalStepsInInterval(startOfDay, now);
        if (val != null) steps = val;
      } catch (e) {
        debugPrint('[HealthService] Failed fetching today steps: $e');
      }

      List<HealthDataPoint> rawPoints = [];
      try {
        rawPoints = await _health.getHealthDataFromTypes(
          startTime: startOfDay,
          endTime: now,
          types: [
            HealthDataType.ACTIVE_ENERGY_BURNED,
            HealthDataType.TOTAL_CALORIES_BURNED,
            HealthDataType.HEART_RATE,
            HealthDataType.DISTANCE_WALKING_RUNNING,
            HealthDataType.DISTANCE_DELTA,
          ],
        );
      } catch (e) {
        debugPrint('[HealthService] Failed fetching today health points: $e');
      }

      double sleepMinutes = 0;
      try {
        sleepMinutes = await _fetchSleepMinutes();
      } catch (e) {
        debugPrint('[HealthService] Failed fetching today sleep: $e');
      }

      final points = _health.removeDuplicates(rawPoints);

      double activeCalories = 0;
      double totalCalories = 0;
      double distanceMeters = 0;
      final List<int> heartRates = [];

      for (final p in points) {
        final val = (p.value as NumericHealthValue).numericValue.toDouble();
        switch (p.type) {
          case HealthDataType.ACTIVE_ENERGY_BURNED:
            activeCalories += val;
            break;
          case HealthDataType.TOTAL_CALORIES_BURNED:
            totalCalories += val;
            break;
          case HealthDataType.DISTANCE_WALKING_RUNNING:
          case HealthDataType.DISTANCE_DELTA:
            distanceMeters += val;
            break;
          case HealthDataType.HEART_RATE:
            heartRates.add(val.toInt());
            break;
          default:
            break;
        }
      }

      final calories = totalCalories > 0 ? totalCalories : activeCalories;
      final avgBpm = heartRates.isNotEmpty
          ? heartRates.reduce((a, b) => a + b) ~/ heartRates.length
          : 0;
      final maxBpm = heartRates.isNotEmpty
          ? heartRates.reduce((a, b) => a > b ? a : b)
          : 0;

      return FitnessStats(
        steps: steps,
        calories: calories.toInt(),
        distance: distanceMeters / 1000,
        heartRate: avgBpm,
        maxHeartRate: maxBpm,
        activeMinutes: (steps / 100).clamp(0, 1440).toInt(),
        sleepHours: sleepMinutes / 60.0,
        date: now,
        isRealData: true,
      );
    } catch (e) {
      debugPrint('[HealthService] getTodayStats error: $e');
      return FitnessStats.empty();
    }
  }

  // ─── Weekly Stats ─────────────────────────────────────────────────────────

  Future<List<FitnessStats>> getWeeklyStats() async {
    await initialize();
    final now = DateTime.now();

    final futures = List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final start = DateTime(date.year, date.month, date.day);
      final end = (6 - i) == 0
          ? now
          : DateTime(date.year, date.month, date.day, 23, 59, 59);
      return _fetchDayStats(date, start, end);
    });

    return Future.wait(futures);
  }

  Future<FitnessStats> _fetchDayStats(
    DateTime date,
    DateTime start,
    DateTime end,
  ) async {
    try {
      int steps = 0;
      try {
        final val = await _health.getTotalStepsInInterval(start, end);
        if (val != null) steps = val;
      } catch (e) {
        debugPrint('[HealthService] Failed fetching day staps: $e');
      }

      List<HealthDataPoint> rawPoints = [];
      try {
        rawPoints = await _health.getHealthDataFromTypes(
          startTime: start,
          endTime: end,
          types: [
            HealthDataType.ACTIVE_ENERGY_BURNED,
            HealthDataType.TOTAL_CALORIES_BURNED,
            HealthDataType.HEART_RATE,
            HealthDataType.DISTANCE_WALKING_RUNNING,
            HealthDataType.DISTANCE_DELTA,
          ],
        );
      } catch (e) {
        debugPrint('[HealthService] Failed fetching day health points: $e');
      }

      final points = _health.removeDuplicates(rawPoints);

      double activeCalories = 0;
      double totalCalories = 0;
      double distanceMeters = 0;
      final List<int> heartRates = [];

      for (final p in points) {
        final val = (p.value as NumericHealthValue).numericValue.toDouble();
        if (p.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
          activeCalories += val;
        } else if (p.type == HealthDataType.TOTAL_CALORIES_BURNED) {
          totalCalories += val;
        } else if (p.type == HealthDataType.HEART_RATE) {
          heartRates.add(val.toInt());
        } else if (p.type == HealthDataType.DISTANCE_WALKING_RUNNING ||
            p.type == HealthDataType.DISTANCE_DELTA) {
          distanceMeters += val;
        }
      }

      final calories = totalCalories > 0 ? totalCalories : activeCalories;

      return FitnessStats(
        steps: steps,
        calories: calories.toInt(),
        distance: distanceMeters > 0
            ? (distanceMeters / 1000)
            : (steps * 0.000762),
        heartRate: heartRates.isNotEmpty
            ? heartRates.reduce((a, b) => a + b) ~/ heartRates.length
            : 0,
        maxHeartRate: heartRates.isNotEmpty
            ? heartRates.reduce((a, b) => a > b ? a : b)
            : 0,
        activeMinutes: (steps / 100).clamp(0, 1440).toInt(),
        date: date,
        isRealData: true,
      );
    } catch (e) {
      debugPrint('[HealthService] _fetchDayStats error for $date: $e');
      return FitnessStats.empty(date: date);
    }
  }

  // ─── Sleep ────────────────────────────────────────────────────────────────

  Future<double> getLastNightSleep() async {
    final minutes = await _fetchSleepMinutes();
    return minutes / 60.0;
  }

  Future<double> _fetchSleepMinutes() async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final start = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        20,
      );
      final end = DateTime(now.year, now.month, now.day, 12);

      final rawPoints = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.SLEEP_ASLEEP],
      );

      final points = _health.removeDuplicates(rawPoints);
      double totalMinutes = 0;

      for (final p in points) {
        final duration = p.dateTo.difference(p.dateFrom).inMinutes.toDouble();
        totalMinutes += duration;
      }

      return totalMinutes;
    } catch (e) {
      debugPrint('[HealthService] _fetchSleepMinutes error: $e');
      return 0;
    }
  }

  // ─── Firestore Sync ───────────────────────────────────────────────────────

  Future<void> saveToFirestore(String memberId, FitnessStats stats) async {
    try {
      final dateKey = DateFormat('yyyy-MM-dd').format(stats.date);
      await FirebaseFirestore.instance
          .collection('fitnessData')
          .doc(memberId)
          .collection('daily')
          .doc(dateKey)
          .set({
            'steps': stats.steps,
            'calories': stats.calories,
            'distanceKm': stats.distance,
            'heartRate': stats.heartRate,
            'maxHeartRate': stats.maxHeartRate,
            'activeMinutes': stats.activeMinutes,
            'sleepHours': stats.sleepHours,
            'date': Timestamp.fromDate(stats.date),
            'updatedAt': FieldValue.serverTimestamp(),
            'source': Platform.isIOS ? 'healthkit' : 'health_connect',
            'isRealData': stats.isRealData,
          }, SetOptions(merge: true));
      debugPrint('[HealthService] Saved to Firestore for $dateKey');
    } catch (e) {
      debugPrint('[HealthService] Firestore sync error: $e');
    }
  }

  Future<void> syncTodayToFirestore(String memberId) async {
    final stats = await getTodayStats();
    if (stats.isRealData) {
      await saveToFirestore(memberId, stats);
    }
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void reset() {
    _isInitialized = false;
  }
}
