import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MemberSessionScreen extends StatefulWidget {
  final String sessionId;
  final String memberName; // Needed for complete state

  const MemberSessionScreen({
    super.key,
    required this.sessionId,
    required this.memberName,
  });

  @override
  State<MemberSessionScreen> createState() => _MemberSessionScreenState();
}

class _MemberSessionScreenState extends State<MemberSessionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text('Live Session', style: AppTextStyles.heading2),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trainingSessions')
            .doc(widget.sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Session not found',
                style: AppTextStyles.bodyLarge,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'warmup';

          if (status == 'warmup') {
            return _buildWarmupState();
          } else if (status == 'active') {
            return _buildActiveState(data);
          } else if (status == 'complete') {
            return _buildCompleteState(data);
          }

          return Center(child: Text('Unknown state', style: AppTextStyles.bodyLarge));
        },
      ),
    );
  }

  Widget _buildCompleteState(Map<String, dynamic> data) {
    final duration = data['totalDurationMinutes'] ?? 0;
    final exercisesCount = (data['exercises'] as List?)?.length ?? 0;
    final rpe = data['sessionRpe'] ?? '-';
    final postWorkout = data['postWorkoutMeal'] ?? 'Protein Shake + Banana';
    final dinner = data['dinnerSuggestion'] ?? 'Grilled Chicken Salad';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Completion Card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonLime.withValues(alpha: 0.2),
                  AppColors.neonTeal.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Icon(Icons.celebration, color: AppColors.neonLime, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Great session, ${widget.memberName.split(' ').first}!',
                  style: AppTextStyles.heading1.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol('Duration', '${duration}m'),
                    _buildStatCol('Exercises', '$exercisesCount'),
                    _buildStatCol('Intensity', 'RPE $rpe'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Nutrition Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recovery Nutrition', style: AppTextStyles.heading2),
                const SizedBox(height: 16),
                _buildNutritionRow(Icons.restaurant, 'Post-Workout', postWorkout, AppColors.neonLime),
                const Divider(color: AppColors.gray800, height: 24),
                _buildNutritionRow(Icons.nightlight_round, 'Tonight\'s Dinner', dinner, AppColors.neonTeal),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),

          // Action Buttons
          ElevatedButton(
            onPressed: () {
              // Note: Routing logic depends on exact app structure
              // e.g., Navigator.push to AiCoachScreen diet tab
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Full Meal Plan...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('VIEW FULL MEAL PLAN', style: TextStyle(fontWeight: FontWeight.bold)),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // e.g., Navigator.push to WorkoutHistoryScreen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Workout History...')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.gray400),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('VIEW WORKOUT SUMMARY', style: TextStyle(fontWeight: FontWeight.bold)),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.heading2.copyWith(color: AppColors.neonLime)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.gray400)),
      ],
    );
  }

  Widget _buildNutritionRow(IconData icon, String title, String desc, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.gray400)),
              const SizedBox(height: 4),
              Text(desc, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState(Map<String, dynamic> data) {
    final goalInsight = data['goalInsight'] as String? ?? 'Keep pushing towards your goals!';
    final exercises = List<dynamic>.from(data['exercises'] ?? []);
    int activeIndex = -1;
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i]['status'] == 'active') {
        activeIndex = i;
        break;
      }
    }

    if (activeIndex == -1) {
       for (int i = 0; i < exercises.length; i++) {
         if (exercises[i]['status'] == 'pending') {
           activeIndex = i;
           break;
         }
       }
    }

    if (activeIndex == -1 && exercises.isNotEmpty) {
      activeIndex = exercises.length - 1; // Show last if all complete but session still active
    }

    if (exercises.isEmpty || activeIndex == -1) {
      return Center(child: Text('Waiting for exercises...', style: AppTextStyles.bodyLarge));
    }

    final currentExercise = exercises[activeIndex];
    final isMobilityWork = currentExercise['isMobilityWork'] == true;
    final completedSets = List<dynamic>.from(currentExercise['completedSets'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Card
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.neonTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neonTeal),
          ),
          child: Row(
            children: [
              const Icon(Icons.track_changes, color: AppColors.neonTeal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  goalInsight,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neonTeal),
                ),
              ),
            ],
          ),
        ),

        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${activeIndex + 1} of ${exercises.length}',
                style: AppTextStyles.caption.copyWith(color: AppColors.neonLime),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LinearProgressIndicator(
            value: exercises.isEmpty ? 0 : (activeIndex + 1) / exercises.length,
            backgroundColor: AppColors.surfaceDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonLime),
          ),
        ),
        const SizedBox(height: 24),

        // Current Exercise
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentExercise['name'] ?? 'Unknown Exercise',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.neonLime,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Target: ${currentExercise['sets'] ?? 0} × ${currentExercise['reps'] ?? 0} @ ${currentExercise['weightKg'] ?? 0}kg',
                  style: AppTextStyles.bodyLarge,
                ),
                if (isMobilityWork) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.accessibility_new, color: AppColors.neonOrange, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mobility: ${currentExercise['notes'] ?? 'Focus on form'}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.neonOrange),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Text('Completed Sets', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: completedSets.map((setInfo) {
                    return Chip(
                      label: Text('${setInfo['reps']} × ${setInfo['weightKg']}kg'),
                      backgroundColor: AppColors.neonLime.withValues(alpha: 0.2),
                      labelStyle: const TextStyle(color: AppColors.neonLime),
                      side: const BorderSide(color: AppColors.neonLime),
                    );
                  }).toList(),
                ),
                if (completedSets.isEmpty)
                   Padding(
                     padding: const EdgeInsets.only(top: 8.0),
                     child: Text('No sets logged yet.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400)),
                   )
              ],
            ),
          ),
        ),

        // Log Set Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => _showLogSetBottomSheet(context, activeIndex, exercises),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'LOG MY SET',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogSetBottomSheet(BuildContext context, int activeIndex, List<dynamic> exercises) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Log Set', style: AppTextStyles.heading2),
              const SizedBox(height: 20),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Reps completed',
                  labelStyle: const TextStyle(color: AppColors.gray400),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.gray400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.neonLime),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Weight used (kg)',
                  labelStyle: const TextStyle(color: AppColors.gray400),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.gray400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.neonLime),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final reps = int.tryParse(repsController.text) ?? 0;
                  final weight = double.tryParse(weightController.text) ?? 0.0;

                  if (reps > 0) {
                     final currentExercise = exercises[activeIndex];
                     final completedSets = List<Map<String, dynamic>>.from(currentExercise['completedSets'] ?? []);
                     completedSets.add({
                       'reps': reps,
                       'weightKg': weight,
                     });
                     currentExercise['completedSets'] = completedSets;
                     exercises[activeIndex] = currentExercise;

                     await FirebaseFirestore.instance
                         .collection('trainingSessions')
                         .doc(widget.sessionId)
                         .update({'exercises': exercises});

                     if (context.mounted) {
                       Navigator.pop(context);
                     }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWarmupState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_run,
            size: 80,
            color: AppColors.neonLime,
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 1500.ms, color: AppColors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 32),
          const CircularProgressIndicator(
            color: AppColors.neonLime,
          ),
          const SizedBox(height: 24),
          Text(
            'Warming up!',
            style: AppTextStyles.heading2.copyWith(color: AppColors.neonLime),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Your trainer is building your plan. Get ready!',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
