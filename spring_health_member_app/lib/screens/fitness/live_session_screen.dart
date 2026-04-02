import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../main_screen.dart';

class LiveSessionScreen extends StatelessWidget {
  final String sessionId;
  const LiveSessionScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .doc(sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading session',
                style: TextStyle(color: AppColors.error),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? '';

          switch (status) {
            case 'warmup':
              return _buildWarmupView(data);
            case 'planning':
              return _buildPlanningView();
            case 'active':
              return _buildActiveView(data);
            case 'stretching':
              return _StretchingView(data: data);
            case 'complete':
              return _buildCompleteView(context, data);
            case 'cancelled':
              return _buildCancelledView();
            default:
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neonLime),
              );
          }
        },
      ),
    );
  }

  Widget _buildWarmupView(Map<String, dynamic> data) {
    final warmupList = List<Map<String, dynamic>>.from(data['warmup'] ?? []);
    final currentWarmup = warmupList.firstWhere(
      (e) => e['status'] != 'complete',
      orElse: () => <String, dynamic>{},
    );

    final isDone = currentWarmup.isEmpty;
    final name = isDone ? 'Warmup done!' : (currentWarmup['name'] ?? 'Warmup');

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WARM UP',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neonLime,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: AppTextStyles.heading2.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Follow along with your trainer',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            ),
            const SizedBox(height: 48),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.neonLime,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 1.seconds,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.neonTeal,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AjAX is building your workout...',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your trainer is reviewing the plan',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveView(Map<String, dynamic> data) {
    final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
    final activeIndex = exercises.indexWhere((e) => e['status'] == 'active');

    if (activeIndex == -1) {
      return Center(
        child: Text(
          'Great work! Finishing up...',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
      );
    }

    final activeExercise = exercises[activeIndex];
    final name = activeExercise['name'] ?? 'Exercise';
    final sets = activeExercise['sets'] ?? 0;
    final reps = activeExercise['reps'] ?? 0;
    final weight = activeExercise['weightKg'] ?? 0;
    final completedSets = activeExercise['completedSets'] ?? 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.neonLime.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.heading2.copyWith(color: AppColors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$sets sets x $reps reps @ $weight kg',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.neonLime),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      sets as int,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: index < (completedSets as int)
                              ? AppColors.neonLime
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neonLime,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your trainer will mark each set complete',
                    style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Exercise ${activeIndex + 1} of ${exercises.length}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: exercises.map((e) {
                final status = e['status'] as String? ?? '';
                Color dotColor;
                if (status == 'complete') {
                  dotColor = AppColors.neonLime;
                } else if (status == 'active') {
                  dotColor = AppColors.neonLime.withValues(alpha: 0.5);
                } else {
                  dotColor = AppColors.gray800;
                }
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteView(BuildContext context, Map<String, dynamic> data) {
    final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
    final duration = data['sessionDurationMinutes'] ?? 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.neonLime,
              size: 80,
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),
            const SizedBox(height: 24),
            Text(
              'Session Complete! 💪',
              style: AppTextStyles.heading2.copyWith(color: AppColors.white),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Exercises', '${exercises.length}'),
                _buildStatColumn('Duration', '$duration min'),
                _buildStatColumn('XP Earned', '100 XP', color: AppColors.neonLime),
              ],
            ).animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(initialIndex: 2),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Open Diet Plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: color ?? AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
        ),
      ],
    );
  }

  Widget _buildCancelledView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bed_rounded,
            color: AppColors.gray400,
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            'Session cancelled',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Rest day. See you tomorrow!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

class _StretchingView extends StatefulWidget {
  final Map<String, dynamic> data;
  const _StretchingView({required this.data});

  @override
  State<_StretchingView> createState() => _StretchingViewState();
}

class _StretchingViewState extends State<_StretchingView> {
  late ValueNotifier<String> _timeLeft;

  Timer? _timer;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _timeLeft = ValueNotifier<String>('30s');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        _timeLeft.value = '${_secondsRemaining}s';
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timeLeft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stretchingList = List<Map<String, dynamic>>.from(widget.data['stretching'] ?? []);
    final currentStretch = stretchingList.firstWhere(
      (e) => e['status'] != 'complete',
      orElse: () => <String, dynamic>{},
    );

    if (currentStretch.isEmpty) {
      return Center(
        child: Text(
          'Stretching done! Finishing session...',
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
        ),
      );
    }

    final name = currentStretch['name'] ?? 'Stretch';
    final target = currentStretch['targetMuscle'] ?? '';

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.neonTeal.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'COOL DOWN',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neonTeal,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: AppTextStyles.heading2.copyWith(color: AppColors.white),
              textAlign: TextAlign.center,
            ),
            if (target.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.neonTeal.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  target,
                  style: AppTextStyles.caption.copyWith(color: AppColors.neonTeal),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Hold and breathe...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: _timeLeft,
              builder: (context, value, _) {
                return Text(
                  value,
                  style: AppTextStyles.heading1.copyWith(color: AppColors.neonTeal),
                );
              },
            ),
            const SizedBox(height: 48),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.neonTeal.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonTeal,
                  width: 2,
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.5, 1.5),
                  duration: 4.seconds,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    );
  }
}
