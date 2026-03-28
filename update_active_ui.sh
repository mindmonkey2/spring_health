cat << 'INNER_EOF' > merge.patch
<<<<<<< SEARCH
          if (status == 'warmup') {
            return _buildWarmupState();
          } else if (status == 'active') {
            return Center(child: Text('Active state coming soon', style: AppTextStyles.bodyLarge)); // Placeholder
          } else if (status == 'complete') {
            return Center(child: Text('Complete state coming soon', style: AppTextStyles.bodyLarge)); // Placeholder
          }

          return Center(child: Text('Unknown state', style: AppTextStyles.bodyLarge));
        },
      ),
    );
  }

  Widget _buildWarmupState() {
=======
          if (status == 'warmup') {
            return _buildWarmupState();
          } else if (status == 'active') {
            return _buildActiveState(data);
          } else if (status == 'complete') {
            return Center(child: Text('Complete state coming soon', style: AppTextStyles.bodyLarge)); // Placeholder
          }

          return Center(child: Text('Unknown state', style: AppTextStyles.bodyLarge));
        },
      ),
    );
  }

  Widget _buildActiveState(Map<String, dynamic> data) {
    final goalInsight = data['goalInsight'] as String? ?? 'Keep pushing towards your goals!';
    final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);
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
    final completedSets = List<Map<String, dynamic>>.from(currentExercise['completedSets'] ?? []);

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

  void _showLogSetBottomSheet(BuildContext context, int activeIndex, List<Map<String, dynamic>> exercises) {
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
INNER_EOF
patch spring_health_member_app/lib/screens/workout/member_session_screen.dart merge.patch
