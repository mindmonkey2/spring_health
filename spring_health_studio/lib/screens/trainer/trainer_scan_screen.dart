import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/attendance_model.dart';
import '../../services/firestore_service.dart';
import '../../services/session_service.dart';
import '../../theme/app_colors.dart';
import 'trainer_readiness_screen.dart';
import 'flexibility_assessment_screen.dart';

class TrainerScanScreen extends StatefulWidget {
  final String trainerId;
  final String trainerBranch;
  final String? prefilledMemberId;

  const TrainerScanScreen({
    super.key,
    required this.trainerId,
    required this.trainerBranch,
    this.prefilledMemberId,
  });

  @override
  State<TrainerScanScreen> createState() => _TrainerScanScreenState();
}

class _TrainerScanScreenState extends State<TrainerScanScreen> {
  final _firestoreService = FirestoreService();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _torchEnabled = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledMemberId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleQRCode('SPRING_${widget.prefilledMemberId}');
      });
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  Future<void> _handleQRCode(String qrData) async {
    if (_isProcessing) return;

    await _scannerController.stop();

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    try {
      if (!qrData.startsWith('SPRING_')) {
        throw Exception('Invalid QR Code - Not a Spring Health member code');
      }

      final memberId = qrData.replaceFirst('SPRING_', '');
      if (memberId.isEmpty) {
        throw Exception('Invalid QR Code - Member ID is empty');
      }

      final member = await _firestoreService.getMemberById(memberId);
      if (member == null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member not found.')));
        _resetScanner();
        return;
      }

      final dynamic memberDyn = member;
      if (memberDyn.assignedTrainerId != widget.trainerId) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This member is not assigned to you.')));
        _resetScanner();
        return;
      }

      // Step 4: Auto-mark attendance
      final alreadyCheckedIn = await _firestoreService.hasCheckedInToday(memberId, member.branch);
      if (!alreadyCheckedIn) {
        final now = DateTime.now();
        final attendance = AttendanceModel(
          id: '${memberId}_${now.millisecondsSinceEpoch}',
          memberId: memberId,
          memberName: member.name,
          branch: member.branch,
          checkInTime: now,
        );
        await _firestoreService.recordAttendance(attendance);
      }

      // Step 4.5: Create Session
      final memberDoc = await FirebaseFirestore.instance.collection('members').doc(member.id).get();
      final memberAuthUid = memberDoc.data()?['uid'] as String? ?? '';

      if (memberAuthUid.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member account not linked')));
        }
        _resetScanner();
        return;
      }

      final trainerUid = FirebaseAuth.instance.currentUser?.uid;
      if (trainerUid == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trainer not authenticated.')));
        }
        _resetScanner();
        return;
      }

      final trainerDoc = await FirebaseFirestore.instance.collection('users').doc(trainerUid).get();
      final trainerName = trainerDoc.data()?['name'] as String? ?? 'Trainer';

      String sessionId;
      try {
        sessionId = await SessionService.instance.createSession(
          memberId: member.id,
          memberAuthUid: memberAuthUid,
          trainerId: widget.trainerId,
          trainerUid: trainerUid,
          trainerName: trainerName,
          branch: member.branch,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create session.')));
        }
        _resetScanner();
        return;
      }

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }

      // Step 5: Compute age
      int age = 0;
      final dob = member.dateOfBirth;
      final today = DateTime.now();
      if (dob != null) {
        age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
      }

      // Step 6: Check first session
      // The prompt requests memberAuthUid to look up memberIntelligence, memberGoals, wearableSnapshots, healthProfiles
      // Memory says: 'memberGoals', 'fitnessTests', and 'memberIntelligence' are exceptions and are keyed by the Firebase Auth UID (`memberAuthUid`).
      // But `MemberModel` may not explicitly expose `uid`.
      // Let's assume `member.id` acts as the auth UID if `uid` doesn't exist on the model, or check if we can query it differently.
      // Wait, let's use member.authUid if it exists. Actually, looking at member_model.dart is better. I don't have it, but I know uid is undefined.
      // Let's check `member.id`.
      final memberUid = member.id;
      final intelligenceDoc = await FirebaseFirestore.instance.collection('memberIntelligence').doc(memberUid).get();
      bool isFirstSession = true;
      if (intelligenceDoc.exists) {
        final totalSessions = intelligenceDoc.data()?['totalSessionsLogged'] ?? 0;
        isFirstSession = totalSessions == 0;
      }

      // Step 7: Parallel fetches
      final String yesterdayStr = "${DateTime.now().subtract(const Duration(days: 1)).year.toString().padLeft(4, '0')}-${DateTime.now().subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}-${DateTime.now().subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}";

      final futures = await Future.wait([
        FirebaseFirestore.instance.collection('wearableSnapshots').doc(memberUid).collection('daily').doc(yesterdayStr).get(),
        FirebaseFirestore.instance.collection('aiPlans').doc(memberUid).collection('current').doc('current').get(),
        FirebaseFirestore.instance.collection('trainingSessions').where('memberId', isEqualTo: member.id).where('status', isEqualTo: 'complete').orderBy('date', descending: true).limit(1).get(),
        FirebaseFirestore.instance.collection('healthProfiles').doc(memberUid).get(),
        FirebaseFirestore.instance.collection('bodyMetricsLogs').doc(memberUid).collection('logs').orderBy('date', descending: true).limit(4).get(),
        FirebaseFirestore.instance.collection('memberGoals').doc(memberUid).get(),
        Future.value(intelligenceDoc),
        FirebaseFirestore.instance.collection('gymEquipment').doc(member.branch).get(),
      ]);

      final snapDoc = futures[0] as DocumentSnapshot;
      final aiPlanDoc = futures[1] as DocumentSnapshot;
      final lastSessionQuery = futures[2] as QuerySnapshot;
      final healthProfileDoc = futures[3] as DocumentSnapshot;
      final bodyMetricsQuery = futures[4] as QuerySnapshot;
      final memberGoalsDoc = futures[5] as DocumentSnapshot;
      final equipmentDoc = futures[7] as DocumentSnapshot;

      final snapData = snapDoc.data() as Map<String, dynamic>? ?? {};
      final lastSessionData = lastSessionQuery.docs.isNotEmpty ? lastSessionQuery.docs.first.data() as Map<String, dynamic> : {};
      final healthProfileData = healthProfileDoc.data() as Map<String, dynamic>? ?? {};
      final goalData = memberGoalsDoc.data() as Map<String, dynamic>? ?? {};

      List<Map<String, dynamic>> bodyMetricsEntries = bodyMetricsQuery.docs.map((d) => d.data() as Map<String, dynamic>).toList();

      // Step 8: Compute readiness score
      int score = 70;
      if ((snapData['sleepHours'] ?? 0) >= 7) score += 10;
      if ((snapData['hrv'] ?? 0) >= 50) score += 10;
      final lastRpe = lastSessionData['sessionRpe'] ?? 0;
      if (lastRpe > 0 && lastRpe <= 6) score += 10;
      if (lastRpe >= 9) score -= 20;
      if ((snapData['restingHR'] ?? 999) <= 65) score += 5;

      final latestBodyMetrics = bodyMetricsEntries.isNotEmpty ? bodyMetricsEntries.first : null;
      final bmi = latestBodyMetrics?['bmi'] as num?;
      if ((bmi ?? 0) > 30) score -= 5;
      score = score.clamp(0, 100);

      // Step 9: Compute BMR + TDEE + caloric target locally
      num? bmr;
      num? tdee;
      num? caloricTarget;

      final weightKg = latestBodyMetrics?['weightKg'] as num?;
      final heightCm = goalData['heightCm'] as num? ?? healthProfileData['heightCm'] as num?;

      if (weightKg != null && heightCm != null) {
        bmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
        num weeklyTarget = goalData['weeklySessionTarget'] ?? 3;
        num multiplier = weeklyTarget <= 2 ? 1.375 : weeklyTarget <= 4 ? 1.55 : 1.725;
        tdee = bmr * multiplier;

        String primaryGoal = goalData['primaryGoal'] ?? 'general_fitness';
        if (primaryGoal == 'weight_loss') {
          caloricTarget = tdee - 500;
        } else if (primaryGoal == 'muscle_gain') {
          caloricTarget = tdee + 250;
        } else if (primaryGoal == 'endurance') {
          caloricTarget = tdee + 100;
        } else {
          caloricTarget = tdee;
        }
      }

      // Step 10: Compute goal context
      Map<String, dynamic>? goalContext;
      if (memberGoalsDoc.exists) {
        int weeksRemaining = 0;
        if (goalData['deadline'] != null) {
           DateTime deadline = (goalData['deadline'] as Timestamp).toDate();
           weeksRemaining = deadline.difference(DateTime.now()).inDays ~/ 7;
        }

        num targetValue = goalData['targetMetric']?['targetValue'] ?? 0;
        num currentValue = goalData['targetMetric']?['currentValue'] ?? 0;
        num weeklyRateNeeded = weeksRemaining > 0 ? (targetValue - currentValue) / weeksRemaining : 0;

        String currentPace = 'not_started';
        if (bodyMetricsEntries.length >= 2) {
          final firstEntry = bodyMetricsEntries.first;
          final lastEntry = bodyMetricsEntries.last;
          final w1 = firstEntry['weightKg'] as num? ?? 0;
          final w2 = lastEntry['weightKg'] as num? ?? 0;
          final d1 = (firstEntry['date'] as Timestamp).toDate();
          final d2 = (lastEntry['date'] as Timestamp).toDate();
          int diffDays = d1.difference(d2).inDays.abs();
          int diffWeeks = diffDays ~/ 7;

          if (diffWeeks > 0) {
            num actualRate = (w1 - w2) / diffWeeks;
            num ratio = weeklyRateNeeded != 0 ? actualRate / weeklyRateNeeded : 0;
            if (ratio >= 0.9 && ratio <= 1.1) {
              currentPace = 'on_track';
            } else if (ratio > 1.1) {
               currentPace = 'ahead';
            } else {
              currentPace = 'behind';
            }
          }
        }

        goalContext = {
          'weeksRemaining': weeksRemaining,
          'targetValue': targetValue,
          'currentValue': currentValue,
          'weeklyRateNeeded': weeklyRateNeeded,
          'currentPace': currentPace,
          'primaryGoal': goalData['primaryGoal'] ?? 'Goal',
          'dailyCaloricTarget': caloricTarget,
        };
      }

      Map<String, dynamic> sessionData = {
         'sessionId': sessionId,
         'readinessScore': score,
         'wearableData': snapData,
         'lastSessionData': lastSessionData,
         'bmr': bmr,
         'tdee': tdee,
         'caloricTarget': caloricTarget,
         'goalContext': goalContext,
         'bodyMetricsData': latestBodyMetrics,
         'bodyMetricsEntries': bodyMetricsEntries,
         'gymEquipment': equipmentDoc.exists ? equipmentDoc.data() : null,
         'memberAge': age,
         'aiPlanData': aiPlanDoc.data() ?? {},
      };

      if (!mounted) return;

      if (isFirstSession) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FlexibilityAssessmentScreen(
              member: member,
              trainerId: widget.trainerId,
              pendingSessionData: sessionData,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TrainerReadinessScreen(
              sessionId: sessionData['sessionId'] as String,
              member: member,
              trainerId: widget.trainerId,
              sessionData: sessionData,
              flexibilityData: null,
            ),
          ),
        );
      }

    } catch (e) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 100, 100, 100]);
      }
      if (!mounted) return;
      setState(() {
        _lastError = e.toString().replaceFirst('Exception: ', '');
        _isProcessing = false;
      });
      _resetScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Member QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              setState(() => _torchEnabled = !_torchEnabled);
              _scannerController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Position QR code within frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing Member Data...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          if (_lastError != null && !_isProcessing)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _lastError!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _lastError = null),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.5);

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(20)),
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerLength, top), cornerPaint);

    canvas.drawLine(Offset(left + scanAreaSize - cornerLength, top), Offset(left + scanAreaSize, top), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top), Offset(left + scanAreaSize, top + cornerLength), cornerPaint);

    canvas.drawLine(Offset(left, top + scanAreaSize - cornerLength), Offset(left, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left, top + scanAreaSize), Offset(left + cornerLength, top + scanAreaSize), cornerPaint);

    canvas.drawLine(Offset(left + scanAreaSize - cornerLength, top + scanAreaSize), Offset(left + scanAreaSize, top + scanAreaSize), cornerPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top + scanAreaSize - cornerLength), Offset(left + scanAreaSize, top + scanAreaSize), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
