import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/user_model.dart';
import '../../models/member_model.dart';
import '../../models/attendance_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'flexibility_assessment_screen.dart';
import 'trainer_readiness_screen.dart';

class TrainerScanScreen extends StatefulWidget {
  final UserModel user;

  const TrainerScanScreen({super.key, required this.user});

  @override
  State<TrainerScanScreen> createState() => _TrainerScanScreenState();
}

class _TrainerScanScreenState extends State<TrainerScanScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _torchEnabled = false;
  String? _lastError;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _lastError = null;
    });
    _scannerController.start();
  }

  Future<void> _handleQRCode(String qrData) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    try {
      if (!qrData.startsWith('SPRING_')) {
        throw Exception('Invalid QR Code');
      }

      final memberId = qrData.replaceFirst('SPRING_', '');
      if (memberId.isEmpty) {
        throw Exception('Invalid QR Code - Member ID is empty');
      }

      final member = await _firestoreService.getMemberById(memberId);
      if (member == null) throw Exception('Member not found');

      // Verify member assigned to current trainer
      if (member.trainerId != widget.user.uid) {
        throw Exception('Member is not assigned to you');
      }

      // Check attendance
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

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }

      if (!mounted) return;
      _navigateNext(member);
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = e.toString().replaceFirst('Exception: ', '');
          _isProcessing = false;
        });
        Future.delayed(const Duration(seconds: 3), _resetScanner);
      }
    }
  }

  Future<void> _navigateNext(MemberModel member) async {
    try {
      // Calculate age
      int age = 0;
      if (member.dateOfBirth != null) {
        final now = DateTime.now();
        age = now.year - member.dateOfBirth!.year;
        if (now.month < member.dateOfBirth!.month ||
            (now.month == member.dateOfBirth!.month && now.day < member.dateOfBirth!.day)) {
          age--;
        }
      }

      // Fetch context data and training sessions
      final db = FirebaseFirestore.instance;

      final sessionsSnapshot = await db
          .collection('trainingSessions')
          .where('memberId', isEqualTo: member.id)
          .count()
          .get();

      final totalSessionsLogged = sessionsSnapshot.count ?? 0;

      if (!mounted) return;

      if (totalSessionsLogged == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FlexibilityAssessmentScreen(
              authUid: member.userId ?? '',
              memberName: member.name,
              member: member,
              user: widget.user,
              age: age,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TrainerReadinessScreen(
              authUid: member.userId ?? '',
              user: widget.user,
              member: member,
              age: age,
              memberIntelligence: null, // Will fetch inside TrainerReadinessScreen
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastError = 'Failed to load member data: $e';
          _isProcessing = false;
        });
        Future.delayed(const Duration(seconds: 3), _resetScanner);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_torchEnabled ? Icons.flash_on : Icons.flash_off),
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
              _scannerController.stop();
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
            painter: _ScannerOverlayPainter(),
            child: Container(),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.success),
                    SizedBox(height: 16),
                    Text(
                      'Verifying Member...',
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
                  color: Colors.red,
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

class _ScannerOverlayPainter extends CustomPainter {
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
        ..color = const Color(0xFFD0FD3E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final cornerPaint = Paint()
      ..color = const Color(0xFFD0FD3E)
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
