import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/fitness_stats_model.dart';

class WeeklyChartWidget extends StatelessWidget {
  final List<FitnessStats> weeklyData;

  const WeeklyChartWidget({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final maxSteps = weeklyData.map((e) => e.steps).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKLY ACTIVITY',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'STEPS',
                  style: TextStyle(
                    color: AppColors.neonLime,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weeklyData.map((stats) {
                final heightPercentage = stats.steps / maxSteps;
                final dayName = DateFormat('E').format(stats.date);
                final isToday = DateFormat('yMd').format(stats.date) ==
                DateFormat('yMd').format(DateTime.now());

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Steps count
                        Text(
                          '${(stats.steps / 1000).toStringAsFixed(1)}k',
                          style: AppTextStyles.caption.copyWith(
                            color: isToday
                            ? AppColors.neonLime
                            : AppColors.gray400,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Bar
                        Container(
                          height: 100 * heightPercentage,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: isToday
                              ? [
                                AppColors.neonLime,
                                AppColors.neonLime.withValues(alpha: 0.6),
                              ]
                              : [
                                AppColors.neonTeal.withValues(alpha: 0.5),
                                AppColors.neonTeal.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Day label
                        Text(
                          dayName,
                          style: AppTextStyles.caption.copyWith(
                            color: isToday
                            ? AppColors.neonLime
                            : AppColors.gray600,
                            fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
