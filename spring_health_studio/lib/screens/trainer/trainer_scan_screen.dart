import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../theme/app_colors.dart';

class TrainerScanScreen extends StatelessWidget {
  final String trainerId;
  final MemberModel? prefilledMember;

  const TrainerScanScreen({
    super.key,
    required this.trainerId,
    this.prefilledMember,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Scan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          prefilledMember != null
              ? 'Starting session for ${prefilledMember!.name}...'
              : 'Scan member QR code...',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
