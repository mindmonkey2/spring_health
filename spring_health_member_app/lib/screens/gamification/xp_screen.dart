import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/gamification_model.dart';
import '../../services/gamification_service.dart';
import 'personal_best_screen.dart';

class XpScreen extends StatelessWidget {
  final String memberId;
  final String memberName;

  const XpScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
      ),
      body: StreamBuilder<MemberGamification>(
        stream: GamificationService().stream(memberId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            );
          }

          final data = snapshot.data ??
          MemberGamification.empty(memberId);
          final level = data.currentLevel;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Hero XP Card
                _buildXpHeroCard(data, level),
                const SizedBox(height: 24),

                // ✅ Personal Best Banner
                _buildPersonalBestBanner(context),
                const SizedBox(height: 24),

                // ✅ Stats Row
                _buildStatsRow(data),
                const SizedBox(height: 24),

                // ✅ Level Roadmap
                _buildSectionTitle('LEVEL ROADMAP', Icons.map_rounded,
                                   AppColors.neonTeal),
                          const SizedBox(height: 12),
                          _buildLevelRoadmap(data),
                          const SizedBox(height: 24),

                          // ✅ Earned Badges
                          _buildSectionTitle(
                            'EARNED BADGES (${data.earnedBadges.length})',
                            Icons.military_tech_rounded,
                            AppColors.neonLime,
                          ),
                          const SizedBox(height: 12),
                          data.earnedBadges.isEmpty
                          ? _buildNoBadgesYet()
                          : _buildBadgesGrid(data.earnedBadges, earned: true),
                          const SizedBox(height: 24),

                          // ✅ Locked Badges
                          _buildSectionTitle(
                            'LOCKED BADGES (${data.unearnedBadges.length})',
                            Icons.lock_rounded,
                            AppColors.gray600,
                          ),
                          const SizedBox(height: 12),
                          _buildBadgesGrid(data.unearnedBadges, earned: false),
                          const SizedBox(height: 24),

                          // ✅ XP History
                          if (data.recentXpEvents.isNotEmpty) ...[
                            _buildSectionTitle('RECENT XP', Icons.history_rounded,
                                               AppColors.neonOrange),
                          const SizedBox(height: 12),
                          ...data.recentXpEvents
                          .take(10)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => _buildXpEventTile(e.value, e.key)),
                          ],

                          const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // HERO CARD
  // ─────────────────────────────────────────
  Widget _buildXpHeroCard(MemberGamification data, GymLevel level) {
    final progress = level.progressPercent(data.totalXp);
    final xpToNext = level.xpToNextLevel(data.totalXp);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            level.color.withValues(alpha: 0.25),
            level.color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: level.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Level badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: level.color.withValues(alpha: 0.15),
                  border: Border.all(color: level.color, width: 2.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(level.icon, color: level.color, size: 28),
                    Text(
                      'LV${level.level}',
                      style: TextStyle(
                        color: level.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      memberName,
                      style: AppTextStyles.heading3
                      .copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      level.title.toUpperCase(),
                      style: TextStyle(
                        color: level.color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${data.totalXp} XP total',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    level.level < 6
                    ? 'LV${level.level} → LV${level.level + 1}'
                  : 'MAX LEVEL',
                  style: AppTextStyles.caption
                  .copyWith(color: AppColors.gray400),
                  ),
                  Text(
                    level.level < 6
                    ? '$xpToNext XP to next level'
                  : '🏆 Legendary',
                  style: AppTextStyles.caption.copyWith(
                    color: level.color,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) =>
                  LinearProgressIndicator(
                    value: value,
                    backgroundColor:
                    AppColors.gray800,
                    valueColor: AlwaysStoppedAnimation(level.color),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${level.minXp} XP',
                    style: AppTextStyles.caption
                    .copyWith(color: AppColors.gray600, fontSize: 10),
                  ),
                  Text(
                    level.level < 6 ? '${level.maxXp} XP' : '∞',
                    style: AppTextStyles.caption
                    .copyWith(color: AppColors.gray600, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  // ─────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────
  Widget _buildStatsRow(MemberGamification data) {
    return Row(
      children: [
        _buildStatCard(
          '${data.currentStreak}',
          'Day Streak',
          Icons.local_fire_department_rounded,
          AppColors.neonOrange,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${data.totalCheckIns}',
          'Check-ins',
          Icons.qr_code_rounded,
          AppColors.neonTeal,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${data.totalWorkouts}',
          'Workouts',
          Icons.fitness_center_rounded,
          AppColors.neonLime,
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          '${data.earnedBadges.length}',
          'Badges',
          Icons.military_tech_rounded,
          Colors.amber,
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildStatCard(
    String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray400,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
    }

    // ─────────────────────────────────────────
    // LEVEL ROADMAP
    // ─────────────────────────────────────────
    Widget _buildLevelRoadmap(MemberGamification data) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: GymLevel.levels.asMap().entries.map((entry) {
            final lvl = entry.value;
            final isUnlocked = data.totalXp >= lvl.minXp;
            final isCurrent = data.currentLevel.level == lvl.level;
            final isLast = entry.key == GymLevel.levels.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    // Icon circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isUnlocked
                        ? lvl.color.withValues(alpha: 0.2)
                        : AppColors.backgroundBlack,
                        border: Border.all(
                          color: isUnlocked
                          ? lvl.color
                          : AppColors.gray800,
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Icon(
                        isUnlocked ? lvl.icon : Icons.lock_rounded,
                        color: isUnlocked
                        ? lvl.color
                        : AppColors.gray800,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Level ${lvl.level} — ${lvl.title}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isUnlocked
                                  ? lvl.color
                                  : AppColors.gray600,
                                  fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: lvl.color
                                      .withValues(alpha: 0.2),
                                      borderRadius:
                                      BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'CURRENT',
                                      style: TextStyle(
                                        color: lvl.color,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${lvl.minXp} XP',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnlocked && !isCurrent)
                      Icon(Icons.check_circle_rounded,
                           color: lvl.color, size: 20),
                  ],
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(left: 21),
                    child: Container(
                      width: 2,
                      height: 20,
                      color: AppColors.gray800,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ).animate().fadeIn(delay: 300.ms);
    }

    // ─────────────────────────────────────────
    // BADGES GRID
    // ─────────────────────────────────────────
    Widget _buildBadgesGrid(
      List<BadgeDefinition> badges, {required bool earned}) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.85,
        ),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return GestureDetector(
            onTap: () => _showBadgeDetail(context, badge, earned),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: earned
                  ? badge.color.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: earned
                      ? badge.color.withValues(alpha: 0.15)
                      : AppColors.backgroundBlack,
                      border: Border.all(
                        color: earned
                        ? badge.color
                        : AppColors.gray800,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      earned ? badge.icon : Icons.lock_rounded,
                      color: earned ? badge.color : AppColors.gray800,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    badge.title,
                    style: AppTextStyles.caption.copyWith(
                      color: earned ? AppColors.white : AppColors.gray600,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (earned && badge.xpReward > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '+${badge.xpReward} XP',
                      style: TextStyle(
                        color: badge.color,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: (index * 50).ms).scale(
              begin: const Offset(0.9, 0.9),
            ),
          );
        },
      );
      }

      Widget _buildNoBadgesYet() {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.military_tech_outlined,
                     size: 40, color: AppColors.gray600),
                     const SizedBox(height: 12),
                     Text(
                       'No badges earned yet',
                       style: AppTextStyles.bodyMedium
                       .copyWith(color: AppColors.gray400),
                     ),
                     Text(
                       'Check in and log workouts to earn badges!',
                       style: AppTextStyles.caption
                       .copyWith(color: AppColors.gray600),
                       textAlign: TextAlign.center,
                     ),
              ],
            ),
          ),
        );
      }

      // ─────────────────────────────────────────
      // XP EVENT TILE
      // ─────────────────────────────────────────
      Widget _buildXpEventTile(XpEvent event, int index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: AppColors.neonLime,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.reason,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (event.badgeEarned != null)
                      Text(
                        '🏅 Badge earned: ${event.badgeEarned}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '+${event.xpEarned} XP',
                style: TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.05, end: 0);
      }

      // ─────────────────────────────────────────
      // BADGE DETAIL BOTTOM SHEET
      // ─────────────────────────────────────────
      void _showBadgeDetail(
        BuildContext context, BadgeDefinition badge, bool earned) {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.cardSurface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: earned
                    ? badge.color.withValues(alpha: 0.15)
                    : AppColors.backgroundBlack,
                    border: Border.all(
                      color: earned ? badge.color : AppColors.gray800,
                      width: 2.5,
                    ),
                  ),
                  child: Icon(
                    earned ? badge.icon : Icons.lock_rounded,
                    color: earned ? badge.color : AppColors.gray600,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.title,
                  style: AppTextStyles.heading3.copyWith(
                    color: earned ? badge.color : AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description,
                  style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.gray400),
                  textAlign: TextAlign.center,
                ),
                if (badge.xpReward > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.neonLime.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.neonLime.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        earned
                        ? '✅ Earned +${badge.xpReward} XP'
                      : '🔒 Earn +${badge.xpReward} XP on unlock',
                      style: TextStyle(
                        color: AppColors.neonLime,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      earned ? badge.color : AppColors.cardSurface,
                      foregroundColor:
                        earned ? Colors.black : AppColors.gray400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(earned ? 'AWESOME!' : 'KEEP GOING'),
                  ),
                ),
              ],
            ),
          ),
        );
        }

        // ─────────────────────────────────────────
        // PERSONAL BEST BANNER
        // ─────────────────────────────────────────
        Widget _buildPersonalBestBanner(BuildContext context) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalBestScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.neonLime.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.neonLime.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.neonLime,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Bests 🏆',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your reps, beat your limits',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.neonLime,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.05, end: 0),
          );
        }

        // ─────────────────────────────────────────
        // HELPERS
        // ─────────────────────────────────────────
        Widget _buildSectionTitle(
          String title, IconData icon, Color color) {
          return Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 1,
                  color: color.withValues(alpha: 0.2),
                ),
              ),
            ],
          );
          }
}
