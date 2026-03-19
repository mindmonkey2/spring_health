import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';
import '../../models/member_model.dart';
import '../../models/attendance_model.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_colors.dart';
import 'package:intl/intl.dart';

class QRScannerScreen extends StatefulWidget {
  final String? branch;

  const QRScannerScreen({super.key, this.branch});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _firestoreService = FirestoreService();
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _torchEnabled = false;
  MemberModel? _lastScannedMember;
  String? _lastError;

  static const Color sageGreen = AppColors.success;
  static const Color warmYellow = AppColors.warning;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // FIX 1: Central reset — always called after any dialog closes
  void _resetScanner() {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    _scannerController.start();
  }

  // ── Main QR handler ───────────────────────────────────────────────────────
  Future<void> _handleQRCode(String qrData) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _lastError = null;
    });

    // FIX 2: Stop scanner immediately — prevents repeated onDetect fires
    await _scannerController.stop();

    try {
      if (!qrData.startsWith('SPRING_')) {
        throw Exception('Invalid QR Code - Not a Spring Health member code');
      }

      final memberId = qrData.replaceFirst('SPRING_', '');
      if (memberId.isEmpty) {
        throw Exception('Invalid QR Code - Member ID is empty');
      }

      final member = await _firestoreService.getMemberById(memberId);
      if (member == null) throw Exception('Member not found in database');

      if (widget.branch != null && member.branch != widget.branch) {
        throw Exception('Wrong branch! Member belongs to \${member.branch}');
      }

      if (member.isArchived) throw Exception('Member is archived');

      final now = DateTime.now();
      if (now.isAfter(member.expiryDate)) {
        final daysExpired = now.difference(member.expiryDate).inDays;
        throw Exception(
          'Membership expired $daysExpired day${daysExpired > 1 ? "s" : ""} ago',
        );
      }

      // FIX 3: Check duplicate check-in BEFORE recording attendance
      final alreadyCheckedIn = await _firestoreService.hasCheckedInToday(memberId, member.branch);
      if (alreadyCheckedIn) {
        if (!mounted) return;
        await _showAlreadyCheckedInDialog(member);
        _resetScanner();
        return;
      }

      final hasDues = member.dueAmount > 0;

      final attendance = AttendanceModel(
        id: '\${memberId}_\${now.millisecondsSinceEpoch}',
        memberId: memberId,
        memberName: member.name,
        branch: member.branch,
        checkInTime: now,
      );

      await _firestoreService.recordAttendance(attendance);

      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 100);
      }

      setState(() {
        _lastScannedMember = member;
        _isProcessing = false;
      });

      if (!mounted) return;
      await _showSuccessDialog(member, hasDues);
      _resetScanner();
    } catch (e) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: [0, 100, 100, 100]);
      }

      if (!mounted) return;
      setState(() {
        _lastError = e.toString().replaceFirst('Exception: ', '');
        _isProcessing = false;
      });

      await _showErrorDialog(_lastError!);
      _resetScanner(); // FIX 1: always resume after error
    }
  }

  // ── Already checked-in dialog (NEW) ───────────────────────────────────────
  Future<void> _showAlreadyCheckedInDialog(MemberModel member) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade600),
            const SizedBox(width: 12),
            const Text('Already Checked In'),
          ],
        ),
        content: const Text(
          '\${member.name} has already checked in today.\n\nNo duplicate record was created.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: sageGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Success dialog ─────────────────────────────────────────────────────────
  Future<void> _showSuccessDialog(MemberModel member, bool hasDues) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: sageGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: sageGreen,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: sageGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                member.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('ID', member.id),
                    const Divider(height: 20),
                    _buildInfoRow('Plan', member.plan),
                    const Divider(height: 20),
                    _buildInfoRow(
                      'Expires',
                      DateFormat('dd MMM yyyy').format(member.expiryDate),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      'Days Left',
                      '\${member.expiryDate.difference(DateTime.now()).inDays} days',
                      valueColor: sageGreen,
                    ),
                    if (hasDues) ...[
                      const Divider(height: 20),
                      _buildInfoRow(
                        'Pending Dues',
                        'Rs.\${member.dueAmount.toStringAsFixed(0)}',
                        valueColor: Colors.orange,
                      ),
                    ],
                  ],
                ),
              ),
              if (hasDues) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: warmYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: warmYellow),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: warmYellow, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Remind member about pending dues',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // FIX: removed setState(_isProcessing=false) here —
                  // _resetScanner() handles it after dialog closes
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sageGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error dialog ───────────────────────────────────────────────────────────
  Future<void> _showErrorDialog(String error) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // FIX: was default true — tapping outside hung the scanner
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Scan Failed'),
          ],
        ),
        content: Text(
          error,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  // ── Info row helper ────────────────────────────────────────────────────────
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
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
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Position QR code within frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.branch != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sageGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Branch: \${widget.branch}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                    CircularProgressIndicator(color: sageGreen),
                    SizedBox(height: 16),
                    Text(
                      'Verifying...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            if (_lastScannedMember != null && !_isProcessing)
              Positioned(
                bottom: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: sageGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: sageGreen.withValues(alpha: 0.3),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.black, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Last Check-in',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _lastScannedMember!.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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

// ── Scanner overlay painter ────────────────────────────────────────────────────
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
