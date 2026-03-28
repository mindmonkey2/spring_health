import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/attendance_model.dart';
import 'trainer_readiness_screen.dart';
import 'flexibility_assessment_screen.dart';

class TrainerScanScreen extends StatefulWidget {
  final String currentTrainerId;

  const TrainerScanScreen({super.key, required this.currentTrainerId});

  @override
  State<TrainerScanScreen> createState() => _TrainerScanScreenState();
}

class _TrainerScanScreenState extends State<TrainerScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _handleScan(BarcodeCapture capture) async {
    _scannerController.stop(); // CRITICAL RULE: FIRST LINE
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) {
      _scannerController.start();
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final qrData = barcodes.first.rawValue!;
      if (!qrData.startsWith('SPRING_')) {
        throw Exception('Invalid QR Code');
      }

      final memberId = qrData.replaceFirst('SPRING_', '');
      final member = await _firestoreService.getMemberById(memberId);
      if (member == null) {
        throw Exception('Member not found');
      }

      final assignedTrainerId = member.toMap()['assignedTrainerId'];
      if (assignedTrainerId != widget.currentTrainerId) {
        throw Exception('Not assigned to this member');
      }

      final now = DateTime.now();

      // Auto-mark attendance
      final alreadyCheckedIn = await _firestoreService.hasCheckedInToday(memberId, member.branch);
      if (!alreadyCheckedIn) {
        final attendance = AttendanceModel(
          id: '${memberId}_${now.millisecondsSinceEpoch}',
          memberId: memberId,
          memberName: member.name,
          branch: member.branch,
          checkInTime: now,
        );
        await _firestoreService.recordAttendance(attendance);
      }

      final authUid = member.toMap()['user_id'];

      // Calculate Age
      int age = 0;
      if (member.dateOfBirth != null) {
        age = now.year - member.dateOfBirth!.year;
        if (now.month < member.dateOfBirth!.month ||
            (now.month == member.dateOfBirth!.month && now.day < member.dateOfBirth!.day)) {
          age--;
        }
      }

      // Parallel Fetch
      final results = await Future.wait([
        _firestore.collection('memberIntelligence').doc(authUid).get(),
        _firestore.collection('wearableSnapshots').doc(authUid).collection('snapshots')
            .orderBy('date', descending: true).limit(1).get(),
        _firestore.collection('aiPlans').doc(authUid).collection('current')
            .where('status', isEqualTo: 'active').limit(1).get(),
        _firestore.collection('bodyMetricsLogs').doc(authUid).collection('logs')
            .orderBy('timestamp', descending: true).limit(4).get(),
        _firestore.collection('memberGoals').doc(authUid).get(),
        _firestore.collection('branches').doc(member.branch).get(), // for gymEquipment
        _firestore.collection('trainingSessions')
            .where('memberId', isEqualTo: memberId)
            .where('status', isEqualTo: 'completed')
            .orderBy('endTime', descending: true).limit(1).get(),
        _firestore.collection('healthProfiles').doc(authUid).get(),
        _firestore.collection('fitnessTests').doc(authUid).collection('tests')
            .orderBy('date', descending: true).limit(1).get(),
      ]);

      final intelligenceDoc = results[0] as DocumentSnapshot;
      final wearableSnap = results[1] as QuerySnapshot;
      // results[2] is aiPlanSnap but unused for local readiness calculations at this stage
      final metricsSnap = results[3] as QuerySnapshot;
      final goalsDoc = results[4] as DocumentSnapshot;
      final branchDoc = results[5] as DocumentSnapshot;
      final sessionsSnap = results[6] as QuerySnapshot;
      final healthDoc = results[7] as DocumentSnapshot;
      final testsSnap = results[8] as QuerySnapshot;

      final intelligenceData = intelligenceDoc.data() as Map<String, dynamic>?;
      final totalSessionsLogged = intelligenceData != null ? (intelligenceData['totalSessionsLogged'] ?? 0) : 0;
      final isFirstSession = !intelligenceDoc.exists || totalSessionsLogged == 0;

      // Extract Context Data
      final wearableData = wearableSnap.docs.isNotEmpty ? wearableSnap.docs.first.data() as Map<String, dynamic> : null;
      final lastSessionData = sessionsSnap.docs.isNotEmpty ? sessionsSnap.docs.first.data() as Map<String, dynamic> : null;
      final metricsDataList = metricsSnap.docs.map((d) => d.data() as Map<String, dynamic>).toList();
      final latestMetrics = metricsDataList.isNotEmpty ? metricsDataList.first : null;
      final goalsData = goalsDoc.exists ? goalsDoc.data() as Map<String, dynamic> : null;
      final healthData = healthDoc.exists ? healthDoc.data() as Map<String, dynamic> : null;
      final testData = testsSnap.docs.isNotEmpty ? testsSnap.docs.first.data() as Map<String, dynamic> : null;

      // Readiness Score
      double readinessScore = 70.0;
      if (wearableData != null) {
        final sleepH = (wearableData['sleepMinutes'] ?? 0) / 60.0;
        if (sleepH >= 7) {
          readinessScore += 10;
        }
        final hrv = wearableData['hrv'] ?? 0;
        if (hrv >= 50) {
          readinessScore += 10;
        }
        final rhr = wearableData['restingHeartRate'] ?? 0;
        if (rhr > 0 && rhr <= 65) {
          readinessScore += 5;
        }
      }
      if (lastSessionData != null) {
        final rpe = lastSessionData['rpe'] ?? 0;
        if (rpe <= 6) {
          readinessScore += 10;
        }
        if (rpe >= 9) {
          readinessScore -= 20;
        }
      }
      if (latestMetrics != null) {
        final bmi = latestMetrics['bmi'] ?? 0;
        if (bmi > 30) {
          readinessScore -= 5;
        }
      }
      readinessScore = readinessScore.clamp(0.0, 100.0);

      // Calculations locally
      final weightKg = (latestMetrics?['weight'] ?? healthData?['weightKg'] ?? 0).toDouble();
      final heightCm = (latestMetrics?['height'] ?? healthData?['heightCm'] ?? 0).toDouble();
      final gender = healthData?['gender'] ?? 'male'; // Fallback to male
      final weeklySessionTarget = goalsData?['weeklySessionTarget'] ?? 3;
      final primaryGoal = goalsData?['primaryGoal'] ?? 'general';

      double bmr = 0;
      if (weightKg > 0 && heightCm > 0) {
        if (gender.toString().toLowerCase() == 'female') {
          bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
        } else {
          bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        }
      }

      double tdee = 0;
      if (bmr > 0) {
        double multiplier = 1.375;
        if (weeklySessionTarget >= 5) {
          multiplier = 1.725;
        } else if (weeklySessionTarget >= 3) {
          multiplier = 1.55;
        }
        tdee = bmr * multiplier;
      }

      double caloricTarget = tdee;
      if (primaryGoal == 'weight_loss') {
        caloricTarget -= 500;
      } else if (primaryGoal == 'muscle_gain') {
        caloricTarget += 250;
      } else if (primaryGoal == 'endurance') {
        caloricTarget += 100;
      }

      // Goal Context
      int weeksRemaining = 0;
      double currentPace = 0.0;
      double weeklyRateNeeded = 0.0;
      String paceStatus = 'not_started';

      if (goalsData != null && goalsData['targetDate'] != null) {
        final targetDate = (goalsData['targetDate'] as Timestamp).toDate();
        weeksRemaining = targetDate.difference(now).inDays ~/ 7;
        if (weeksRemaining < 0) weeksRemaining = 0;

        if (primaryGoal == 'weight_loss' || primaryGoal == 'muscle_gain') {
          final targetValue = (goalsData['targetValue'] ?? 0).toDouble();

          if (weeksRemaining > 0) {
             weeklyRateNeeded = (targetValue - weightKg).abs() / weeksRemaining;
          }

          if (metricsDataList.length >= 2) {
             final oldestMetric = metricsDataList.last;
             final daysDiff = (latestMetrics!['timestamp'] as Timestamp).toDate().difference((oldestMetric['timestamp'] as Timestamp).toDate()).inDays;
             if (daysDiff > 0) {
               final weightDiff = (latestMetrics['weight'] - oldestMetric['weight']).abs();
               currentPace = (weightDiff / daysDiff) * 7; // weekly pace

               if (currentPace >= weeklyRateNeeded * 0.9 && currentPace <= weeklyRateNeeded * 1.1) {
                 paceStatus = 'on_track';
               } else if (currentPace > weeklyRateNeeded * 1.1) {
                 paceStatus = 'ahead';
               } else {
                 paceStatus = 'behind';
               }
             }
          }
        }
      }

      final contextData = {
        'memberId': memberId,
        'authUid': authUid,
        'memberName': member.name,
        'age': age,
        'readinessScore': readinessScore,
        'bmr': bmr,
        'tdee': tdee,
        'caloricTarget': caloricTarget,
        'weeksRemaining': weeksRemaining,
        'currentPace': currentPace,
        'weeklyRateNeeded': weeklyRateNeeded,
        'paceStatus': paceStatus,
        'wearableData': wearableData,
        'lastSessionData': lastSessionData,
        'latestMetrics': latestMetrics,
        'metricsDataList': metricsDataList,
        'goalsData': goalsData,
        'gymEquipment': branchDoc.exists ? ((branchDoc.data() as Map<String, dynamic>?)?['equipment'] ?? []) : [],
        'flexibilityData': testData,
        'alreadyCheckedIn': alreadyCheckedIn,
      };

      if (!mounted) return;

      if (isFirstSession) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FlexibilityAssessmentScreen(
              memberAuthUid: authUid,
              memberName: member.name,
              trainerId: widget.currentTrainerId,
              contextData: contextData,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TrainerReadinessScreen(
              contextData: contextData,
              trainerId: widget.currentTrainerId,
            ),
          ),
        );
      }

    } catch (e) {
      _showError(e.toString());
      _scannerController.start();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Member')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleScan,
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
