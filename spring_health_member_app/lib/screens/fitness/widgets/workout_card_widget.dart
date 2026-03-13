import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/fitness_stats_model.dart';

class WorkoutCardWidget extends StatelessWidget {
  final WorkoutSession workout;

  const WorkoutCardWidget({
    super.key,
    required this.workout,
  });

  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run_rounded;
      case 'strength training':
        return Icons.fitness_center_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      case 'hiit':
        return Icons.local_fire_department_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Color _getWorkoutColor(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return AppColors.neonTeal;
      case 'strength training':
        return AppColors.neonLime;
      case 'yoga':
        return Colors.purple;
      case 'hiit':
        return AppColors.neonOrange;
      default:
        return AppColors.neonLime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getWorkoutColor(workout.type);
    final icon = _getWorkoutIcon(workout.type);
    final timeAgo = timeago.format(workout.startTime, locale: 'en_short');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                if (workout.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    workout.notes!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout.duration} min',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_outlined,
                    size: 14,
                    color: AppColors.neonOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${workout.caloriesBurned}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
