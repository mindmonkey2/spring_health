import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/member_model.dart';

class MembershipExpiryBanner extends StatelessWidget {
  final MemberModel member;
  final VoidCallback? onRenewTap;

  const MembershipExpiryBanner({
    super.key,
    required this.member,
    this.onRenewTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = member.daysRemaining;

    // Only render for expiring soon — expired goes to lock-out screen
    if (!member.isExpiringSoon) return const SizedBox.shrink();

    // Choose severity colour
    final Color accent =
    days <= 1 ? Colors.redAccent : AppColors.neonOrange;
    final bool isCritical = days <= 1;

    final String title = days <= 1
    ? 'Expires Today!'
    : 'Expiring in $days Day${days == 1 ? '' : 's'}';

    final String subtitle =
    'Renew before ${DateFormat('dd MMM').format(member.expiryDate)} '
    'to avoid losing access.';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Icon — pulsing shimmer on critical day
          isCritical
          ? Icon(Icons.warning_amber_rounded, color: accent, size: 26)
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1600.ms,
            color: accent.withValues(alpha: 0.5),
          )
          : Icon(Icons.schedule_rounded, color: accent, size: 24),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Renew CTA
          GestureDetector(
            onTap: onRenewTap ?? () => _showRenewalSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.45)),
              ),
              child: Text(
                'Renew',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 300.ms)
    .slideY(begin: -0.12, end: 0, curve: Curves.easeOut);
  }

  void _showRenewalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(Icons.refresh_rounded,
                 color: AppColors.neonLime, size: 44),
                 const SizedBox(height: 12),
                 const Text(
                   'HOW TO RENEW',
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 18,
                     fontWeight: FontWeight.w800,
                     letterSpacing: 2,
                   ),
                 ),
                 const SizedBox(height: 24),
                 _step('1', 'Visit Spring Health reception',
                       Icons.store_rounded),
                      const SizedBox(height: 14),
                      _step('2', 'Choose your membership plan',
                            Icons.fitness_center_rounded),
                      const SizedBox(height: 14),
                      _step('3', 'Make payment — Cash · UPI · Card',
                            Icons.payments_rounded),
                      const SizedBox(height: 14),
                      _step('4', 'Your app unlocks automatically',
                            Icons.lock_open_rounded),
                      const SizedBox(height: 28),
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
                              fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _step(String step, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.neonLime.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.neonLime.withValues(alpha: 0.35)),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.neonLime,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }
}
