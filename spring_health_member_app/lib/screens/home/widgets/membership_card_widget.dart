import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/member_model.dart';

class MembershipCardWidget extends StatelessWidget {
  final MemberModel member;

  const MembershipCardWidget({super.key, required this.member});

  Color _getStatusColor() {
    final daysRemaining = member.daysRemaining;
    if (daysRemaining > 7) return AppColors.neonLime;
    if (daysRemaining > 0) return AppColors.neonOrange;
    return Colors.red;
  }

  String _getStatusText() {
    final daysRemaining = member.daysRemaining;
    if (daysRemaining > 7) return 'ACTIVE';
    if (daysRemaining > 0) return 'EXPIRING SOON';
    return 'EXPIRED';
  }

  // ✅ UPDATED: Show QR Code Dialog - NOW USES ACTUAL QR FROM FIRESTORE
  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: AppColors.neonLime.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with animated glow
              Text(
                ' SCAN FOR CHECK-IN',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.neonLime,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: AppColors.neonLime.withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Show this QR code at reception',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
              ),
              const SizedBox(height: 24),

              // ✅ QR Code - USING REAL DATA FROM FIRESTORE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonLime.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: QrImageView(
                  data:
                      member.qrCode, // ✅ NOW USES member.qrCode (SPRING_abc123)
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Member Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.backgroundBlack, AppColors.cardSurface],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonLime.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Member ID', member.id),
                    const SizedBox(height: 12),
                    _buildInfoRow('Name', member.name.toUpperCase()),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Status',
                      _getStatusText(),
                      valueColor: _getStatusColor(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.neonLime.withValues(alpha: 0.5),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
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

  // Helper widget for info rows
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.2),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MEMBERSHIP CARD',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray400,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(member.name, style: AppTextStyles.heading3),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Plan and Expiry
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PLAN',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.membershipPlan,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRES IN',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.daysRemaining > 0
                          ? '${member.daysRemaining} days'
                          : 'Expired',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ✅ QR Code Button with Glow Effect
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showQRCodeDialog(context),
              icon: const Icon(Icons.qr_code_2_rounded, size: 24),
              label: const Text(
                'SHOW QR CODE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: statusColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: statusColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
