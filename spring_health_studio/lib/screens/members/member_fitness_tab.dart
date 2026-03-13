// lib/screens/members/member_fitness_tab.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/workout_summary_model.dart';
import '../../services/member_fitness_service.dart';

class MemberFitnessTab extends StatefulWidget {
  const MemberFitnessTab({super.key, required this.memberId});

  final String memberId;

  @override
  State<MemberFitnessTab> createState() => _MemberFitnessTabState();
}

class _MemberFitnessTabState extends State<MemberFitnessTab> {
  static const Color _green  = Color(0xFF10B981);
  static const Color _teal   = Color(0xFF14B8A6);
  //static const Color _yellow = Color(0xFFFCD34D);

  final _svc = MemberFitnessService();

  late Future<List<WorkoutSummaryModel>> _workoutsFuture;
  late Future<Map<String, dynamic>?> _gamFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _svc.getWorkouts(widget.memberId);
    _gamFuture = _svc.getGamificationProfile(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _green,
      onRefresh: () async {
        setState(() {
          _workoutsFuture = _svc.getWorkouts(widget.memberId);
          _gamFuture = _svc.getGamificationProfile(widget.memberId);
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGamificationCard(),
          const SizedBox(height: 20),
          _buildWorkoutsSection(),
        ],
      ),
    );
  }

  // ── Gamification Card ──────────────────────────────────────────

  Widget _buildGamificationCard() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _gamFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingCard(label: 'Loading gamification…');
        }

        final g = snap.data;
        if (g == null) {
          return _buildEmptyCard(
            Icons.emoji_events_rounded,
            'No gamification data yet',
            'This member hasn\'t earned any XP yet.',
          );
        }

        final xp      = (g['totalXp']       as num?)?.toInt() ?? 0;
        final streak  = (g['currentStreak'] as num?)?.toInt() ?? 0;
        final longest = (g['longestStreak'] as num?)?.toInt() ?? 0;
        final workouts = (g['totalWorkouts'] as num?)?.toInt() ?? 0;
        final checkIns = (g['totalCheckIns'] as num?)?.toInt() ?? 0;
        final volume   = (g['totalVolumeKg'] as num?)?.toInt() ?? 0;
        final badges   =
        ((g['earnedBadgeIds'] as List?) ?? const []).length;
        final level    = _levelTitle(xp);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_green, _teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _green.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                                      color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Gamification Profile',
                                 style: TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                   color: Colors.white)),
                                   Text(level,
                                        style: TextStyle(
                                          color:
                                          Colors.white.withValues(alpha: 0.85),
                                          fontSize: 13)),
                    ],
                  ),
                ]),

                const SizedBox(height: 20),

                // XP big number
                Text('$xp XP',
                     style: const TextStyle(
                       fontSize: 36,
                       fontWeight: FontWeight.bold,
                       color: Colors.white,
                       letterSpacing: 1)),

                       const SizedBox(height: 16),
                       Container(
                         height: 1,
                         color: Colors.white.withValues(alpha: 0.3),
                       ),
                       const SizedBox(height: 16),

                       // Stat row
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceAround,
                         children: [
                           _gamStat('🔥', '$streak', 'Streak'),
                           _vDivider(),
                           _gamStat('🏆', '$longest', 'Best'),
                           _vDivider(),
                           _gamStat('💪', '$workouts', 'Workouts'),
                           _vDivider(),
                           _gamStat('✅', '$checkIns', 'Check-ins'),
                           _vDivider(),
                           _gamStat('🏅', '$badges', 'Badges'),
                         ],
                       ),

                       if (volume > 0) ...[
                         const SizedBox(height: 14),
                         Container(
                           padding: const EdgeInsets.symmetric(
                             horizontal: 14, vertical: 8),
                             decoration: BoxDecoration(
                               color: Colors.white.withValues(alpha: 0.2),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Row(children: [
                               const Icon(Icons.fitness_center_rounded,
                                          color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Text('Total Volume Lifted: $volume kg',
                                               style: const TextStyle(
                                                 color: Colors.white,
                                                 fontWeight: FontWeight.w600)),
                             ]),
                         ),
                       ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _gamStat(String emoji, String value, String label) {
    return Column(children: [
      Text(emoji, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 4),
      Text(value,
           style: const TextStyle(
             fontSize: 18,
             fontWeight: FontWeight.bold,
             color: Colors.white)),
             const SizedBox(height: 2),
             Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8))),
    ]);
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 44,
    color: Colors.white.withValues(alpha: 0.3),
  );

  // ── Workouts Section ───────────────────────────────────────────

  Widget _buildWorkoutsSection() {
    return FutureBuilder<List<WorkoutSummaryModel>>(
      future: _workoutsFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _LoadingCard(label: 'Loading workouts…');
        }

        final workouts = snap.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_green, _teal]),
                        borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.fitness_center_rounded,
                                      color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Recent Workouts',
                             style: TextStyle(
                               fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                if (workouts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${workouts.length} sessions',
                                  style: const TextStyle(
                                    color: _green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            if (workouts.isEmpty)
              _buildEmptyCard(
                Icons.directions_run_rounded,
                'No workouts logged yet',
                'Workouts will appear here once the member starts logging sessions.',
              )
              else
                ...workouts.map((w) => _WorkoutTile(workout: w)),
          ],
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _buildEmptyCard(
    IconData icon, String title, String subtitle) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(title,
                   style: const TextStyle(
                     fontWeight: FontWeight.bold, fontSize: 15)),
                     const SizedBox(height: 6),
                     Text(subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13)),
            ],
          ),
        ),
    );
    }

    String _levelTitle(int xp) {
      if (xp >= 5000) return '⚡ Legend';
      if (xp >= 3000) return '🏆 Champion';
      if (xp >= 2000) return '💪 Elite';
      if (xp >= 1000) return '🔥 Advanced';
      if (xp >= 500)  return '⭐ Intermediate';
      if (xp >= 100)  return '🌱 Beginner';
      return '🆕 Newcomer';
    }
}

// ── Workout Tile ────────────────────────────────────────────────────

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.workout});

  final WorkoutSummaryModel workout;

  static const Color _green = Color(0xFF10B981);
  static const Color _teal  = Color(0xFF14B8A6);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_green, _teal]),
                            borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.white,
                          size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          workout.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                  ),
                  if (workout.xpEarned > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD34D).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFCD34D),
                            width: 1.2),
                        ),
                        child: Text('+${workout.xpEarned} XP',
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                    ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMM yyyy  •  hh:mm a')
                .format(workout.date),
                style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 12),
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat(Icons.timer_rounded, '${workout.durationMinutes}m',
                        'Duration'),
                  _stat(Icons.local_fire_department_rounded,
                        '${workout.caloriesBurned}', 'Cals'),
                  _stat(Icons.repeat_rounded,
                        '${workout.totalSets}s × ${workout.totalReps}r',
                        'Sets×Reps'),
                  if (workout.volumeKg > 0)
                    _stat(Icons.monitor_weight_rounded,
                          '${workout.volumeKg}kg', 'Volume'),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _stat(IconData icon, String value, String label) {
    return Column(children: [
      Icon(icon, size: 18, color: _green),
      const SizedBox(height: 3),
      Text(value,
           style: const TextStyle(
             fontWeight: FontWeight.bold, fontSize: 13)),
             Text(label,
                  style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade600)),
    ]);
  }
}

// ── Supporting widgets ──────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 14),
              Text(label,
                   style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
    );
  }
}
