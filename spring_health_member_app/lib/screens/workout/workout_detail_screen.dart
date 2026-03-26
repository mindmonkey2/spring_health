import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/workout_model.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutLog workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: Text(
          workout.title,
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                DateFormat('dd MMM yyyy').format(workout.date),
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Hero Stats
            _buildHeroStats(),
            const SizedBox(height: 24),

            // ✅ Notes
            if ((workout.notes ?? '').isNotEmpty) ...[
              _buildSectionHeader(
                'NOTES',
                Icons.notes_rounded,
                AppColors.neonTeal,
              ),
              const SizedBox(height: 10),
              _buildNotesCard(),
              const SizedBox(height: 24),
            ],

            // ✅ Exercises
            _buildSectionHeader(
              'EXERCISES (${workout.exercises.length})',
              Icons.fitness_center_rounded,
              AppColors.neonLime,
            ),
            const SizedBox(height: 10),
            ...workout.exercises.asMap().entries.map(
              (entry) => _buildExerciseCard(entry.value, entry.key),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HERO STATS
  // ─────────────────────────────────────
  Widget _buildHeroStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.15),
            AppColors.neonTeal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM dd yyyy • hh:mm a').format(workout.date),
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat(
                '${workout.durationMinutes}m',
                'Duration',
                Icons.timer_rounded,
                AppColors.neonTeal,
              ),
              _buildStatDivider(),
              _buildStat(
                '${workout.exercises.length}',
                'Exercises',
                Icons.fitness_center_rounded,
                AppColors.neonLime,
              ),
              _buildStatDivider(),
              _buildStat(
                '${workout.totalSets}',
                'Sets',
                Icons.format_list_numbered_rounded,
                AppColors.turquoise,
              ),
              _buildStatDivider(),
              _buildStat(
                '${workout.totalVolume}kg',
                'Volume',
                Icons.monitor_weight_rounded,
                AppColors.neonOrange,
              ),
            ],
          ),
          if (workout.caloriesBurned > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '~${workout.caloriesBurned} calories burned',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.97, 0.97));
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withValues(alpha: 0.07),
  );

  // ─────────────────────────────────────
  // NOTES
  // ─────────────────────────────────────
  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, color: AppColors.neonTeal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              workout.notes ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray400,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  // ─────────────────────────────────────
  // EXERCISE CARD
  // ─────────────────────────────────────
  Widget _buildExerciseCard(WorkoutExercise exercise, int index) {
    final color = _getCategoryColor(exercise.category);
    final totalVolume = exercise.totalVolume;
    final bestSet = exercise.sets.isNotEmpty
        ? exercise.sets.reduce(
            (a, b) => (a.weight * a.reps) >= (b.weight * b.reps) ? a : b,
          )
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(exercise.category),
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.category,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Volume badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${totalVolume}kg',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${exercise.sets.length} sets',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Best set badge
          if (bestSet != null && bestSet.weight > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      'Best set: ${bestSet.weight}kg × ${bestSet.reps} reps',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Divider(color: Colors.white10, height: 1),

          // Sets table
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // Table header
                Row(
                  children: [
                    _buildTH('SET', 36),
                    _buildTH('WEIGHT', 90),
                    _buildTH('REPS', 70),
                    _buildTH('VOLUME', 80),
                  ],
                ),
                const SizedBox(height: 8),
                // Table rows
                ...exercise.sets.asMap().entries.map(
                  (entry) => _buildSetRow(entry.key, entry.value, color),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildTH(String label, double width) => SizedBox(
    width: width,
    child: Text(
      label,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.gray600,
        fontSize: 10,
        letterSpacing: 1,
      ),
    ),
  );

  Widget _buildSetRow(int index, ExerciseSet set, Color color) {
    final volume = (set.weight * set.reps).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: volume > 0
                    ? color.withValues(alpha: 0.15)
                    : AppColors.backgroundBlack,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: volume > 0 ? color : AppColors.gray600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              set.weight > 0 ? '${set.weight} kg' : '-',
              style: AppTextStyles.bodyMedium.copyWith(
                color: set.weight > 0 ? AppColors.white : AppColors.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              set.reps > 0 ? '${set.reps}' : '-',
              style: AppTextStyles.bodyMedium.copyWith(
                color: set.reps > 0 ? AppColors.white : AppColors.gray600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            volume > 0 ? '${volume}kg' : '-',
            style: TextStyle(
              color: volume > 0 ? color : AppColors.gray600,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
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
          child: Container(height: 1, color: color.withValues(alpha: 0.2)),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return AppColors.neonOrange;
      case 'back':
        return AppColors.neonTeal;
      case 'legs':
        return AppColors.neonLime;
      case 'shoulders':
        return AppColors.turquoise;
      case 'arms':
        return Colors.purpleAccent;
      case 'core':
        return Colors.amber;
      case 'cardio':
        return Colors.redAccent;
      default:
        return AppColors.gray400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Icons.accessibility_new_rounded;
      case 'back':
        return Icons.airline_seat_recline_normal_rounded;
      case 'legs':
        return Icons.directions_run_rounded;
      case 'shoulders':
        return Icons.fitness_center_rounded;
      case 'arms':
        return Icons.sports_gymnastics_rounded;
      case 'core':
        return Icons.rotate_90_degrees_cw_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }
}
