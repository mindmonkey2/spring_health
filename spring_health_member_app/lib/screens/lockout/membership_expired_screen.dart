import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/app_config.dart';
import '../../models/member_model.dart';
import '../../services/firebase_auth_service.dart';
import '../auth/login_screen.dart';

class MembershipExpiredScreen extends StatelessWidget {
  final MemberModel member;

  const MembershipExpiredScreen({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ✅ Top bar with logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SPRING HEALTH',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _handleLogout(context),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: AppColors.gray400,
                      size: 18,
                    ),
                    label: Text(
                      'Logout',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ✅ Expired Icon with pulsing glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.1),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock_clock_rounded,
                  size: 60,
                  color: AppColors.error,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.08, 1.08),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),

              const SizedBox(height: 32),

              // ✅ Expired title
              Text(
                'MEMBERSHIP EXPIRED',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.error,
                  fontSize: 24,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              Text(
                'Your membership has expired.\nPlease renew to continue accessing\nSpring Health facilities.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 32),

              // ✅ Expiry details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Member',
                      member.name,
                      Icons.person_rounded,
                      AppColors.white,
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildDetailRow(
                      'Plan',
                      member.membershipPlan,
                      Icons.fitness_center_rounded,
                      AppColors.white,
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildDetailRow(
                      'Expired On',
                      DateFormat('dd MMM yyyy')
                      .format(member.membershipEndDate),
                      Icons.event_rounded,
                      AppColors.error,
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildDetailRow(
                      'Branch',
                      member.branch.toUpperCase(),
                      Icons.location_on_rounded,
                      AppColors.white,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // ✅ Contact reception CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showRenewalInfo(context),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'RENEW MEMBERSHIP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 12),

              // ✅ Secondary - contact us
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showContactInfo(context),
                  icon: Icon(
                    Icons.headset_mic_rounded,
                    color: AppColors.neonTeal,
                    size: 18,
                  ),
                  label: Text(
                    'CONTACT RECEPTION',
                    style: TextStyle(
                      color: AppColors.neonTeal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.neonTeal.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label, String value, IconData icon, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray400),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    }

    void _showRenewalInfo(BuildContext context) {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cardSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              Icon(Icons.refresh_rounded,
                   color: AppColors.neonLime, size: 48),
                   const SizedBox(height: 16),

                   Text(
                     'HOW TO RENEW',
                     style: AppTextStyles.heading3.copyWith(
                       color: AppColors.neonLime,
                       letterSpacing: 2,
                     ),
                   ),
                   const SizedBox(height: 24),

                   _buildStepRow('1', 'Visit Spring Health reception',
                                 Icons.store_rounded),
                        const SizedBox(height: 16),
                        _buildStepRow('2', 'Choose your membership plan',
                                      Icons.fitness_center_rounded),
                        const SizedBox(height: 16),
                        _buildStepRow('3', 'Make payment (Cash / UPI / Card)',
                        Icons.payments_rounded),
                        const SizedBox(height: 16),
                        _buildStepRow('4', 'Your app will unlock automatically',
                                      Icons.lock_open_rounded),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonLime,
                              foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                            ),
                            child: const Text(
                              'GOT IT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
            ],
          ),
        ),
      );
    }

    Widget _buildStepRow(String step, String text, IconData icon) {
      return Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonLime.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                step,
                style: TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Icon(icon, color: AppColors.gray400, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      );
    }

    void _showContactInfo(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppColors.neonTeal.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              Icon(Icons.headset_mic_rounded,
                   color: AppColors.neonTeal, size: 24),
                   const SizedBox(width: 10),
                   Text('Contact Us',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.neonTeal)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContactRow(
                Icons.location_on_rounded, 'Hanamkonda / Warangal'),
                const SizedBox(height: 12),
                _buildContactRow(
                  Icons.access_time_rounded, 'Mon–Sat: 6AM – 10PM'),
                  const SizedBox(height: 12),
                  _buildContactRow(
                    Icons.phone_rounded, AppConfig.supportPhone),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonTeal,
                foregroundColor: Colors.black,
              ),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      );
    }

    Widget _buildContactRow(IconData icon, String text) {
      return Row(
        children: [
          Icon(icon, color: AppColors.neonTeal, size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        ],
      );
    }

    Future<void> _handleLogout(BuildContext context) async {
      await FirebaseAuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
}
