import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spring_health_studio/theme/app_colors.dart';

class TrainerReadinessScreen extends StatelessWidget {
  final Map<String, dynamic>? flexibilityData;
  final String? memberAuthUid;
  final String? memberName;
  final String? trainerId;

  const TrainerReadinessScreen({
    super.key,
    this.flexibilityData,
    this.memberAuthUid,
    this.memberName,
    this.trainerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Readiness Screen Stub',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
            const SizedBox(height: 16),
            Text(
              'Readiness Screen Stub',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Flexibility Data Passed: ${flexibilityData != null ? 'Yes' : 'No'}',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
