import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/health_service.dart';

class HealthPermissionScreen extends StatefulWidget {
  final VoidCallback onPermissionGranted;
  const HealthPermissionScreen({super.key, required this.onPermissionGranted});

  @override
  State<HealthPermissionScreen> createState() => _HealthPermissionScreenState();
}

class _HealthPermissionScreenState extends State<HealthPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    final granted = await HealthService.instance.requestPermissions();
    if (!mounted) return;
    setState(() => _isRequesting = false);

    if (granted) {
      widget.onPermissionGranted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Platform.isIOS
            ? 'Please enable HealthKit in Settings → Health → Data Access.'
          : 'Please enable Health Connect permissions in your device settings.',
          ),
          backgroundColor: AppColors.neonOrange,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.black,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final platform = Platform.isIOS ? 'Apple Health' : 'Health Connect';
    final platformIcon = Platform.isIOS ? Icons.favorite_rounded : Icons.monitor_heart_rounded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.neonTeal.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonTeal.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(platformIcon, color: AppColors.neonTeal, size: 36),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 20),

          Text(
            'Connect $platform',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 8),

          Text(
            'Sync your real steps, calories, heart rate and distance — automatically.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // What we read
          ...[
            _PermRow(icon: Icons.directions_walk_rounded, color: AppColors.neonLime, label: 'Steps & Distance'),
            _PermRow(icon: Icons.local_fire_department_rounded, color: AppColors.neonOrange, label: 'Active Calories Burned'),
            _PermRow(icon: Icons.favorite_rounded, color: Colors.red, label: 'Heart Rate (BPM)'),
          ].animate(interval: 80.ms).fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRequesting ? null : _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonTeal,
                foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isRequesting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Icon(platformIcon, size: 18),
              label: Text(
                _isRequesting ? 'REQUESTING...' : 'CONNECT $platform'.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ).animate().fadeIn(delay: 500.ms).scale(),

          const SizedBox(height: 12),

          Text(
            'We only read data. We never write or share it.',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }
}

class _PermRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _PermRow({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
          const Spacer(),
          Icon(Icons.check_circle_rounded, color: color, size: 18),
        ],
      ),
    );
  }
}
