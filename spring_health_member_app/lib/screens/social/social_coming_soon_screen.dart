import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SocialComingSoonScreen extends StatelessWidget {
  const SocialComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.neonLime,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'SPRING SOCIAL',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // ── Animated bolt icon ────────────────────────────────
              Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundBlack,
                      border: Border.all(
                        color: AppColors.neonLime.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonLime.withValues(alpha: 0.35),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: AppColors.neonLime,
                      size: 48,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.06, 1.06),
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 32),

              // ── Headline ──────────────────────────────────────────
              Text(
                'COMING SOON',
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.white,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 8),

              Text(
                'Spring Social is in the lab. 🧪',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),

              Text(
                'Soon you\'ll flex more than muscles —\nyou\'ll flex progress.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 40),

              // ── Sneak peek card ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.neonLime.withValues(alpha: 0.12),
                      AppColors.neonOrange.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.neonLime.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SNEAK PEEK',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neonLime,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _featureRow(
                      icon: Icons.flash_on_rounded,
                      color: AppColors.neonLime,
                      title: 'Flex Zone',
                      subtitle:
                          'Data-driven workout posts that show real stats',
                    ),
                    const SizedBox(height: 14),
                    _featureRow(
                      icon: Icons.people_rounded,
                      color: AppColors.neonTeal,
                      title: 'Spotter Finder',
                      subtitle: 'Find gym buddies at Spring Health near you',
                    ),
                    const SizedBox(height: 14),
                    _featureRow(
                      icon: Icons.military_tech_rounded,
                      color: AppColors.neonOrange,
                      title: 'War Room',
                      subtitle:
                          'Squad challenges, streaks & friendly rivalries',
                    ),
                    const SizedBox(height: 14),
                    _featureRow(
                      icon: Icons.leaderboard_rounded,
                      color: Colors.purpleAccent,
                      title: 'Social Leaderboard',
                      subtitle: 'Compete with friends, not just the gym',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 32),

              // ── Built for Spring Health badge ─────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      color: AppColors.neonLime,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Built exclusively for Spring Health members',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _featureRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
