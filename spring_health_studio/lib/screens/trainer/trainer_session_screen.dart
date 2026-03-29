import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class TrainerSessionScreen extends StatefulWidget {
  final String sessionId;

  const TrainerSessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<TrainerSessionScreen> createState() => _TrainerSessionScreenState();
}

class _TrainerSessionScreenState extends State<TrainerSessionScreen> {
  final ValueNotifier<String> _sessionTimer = ValueNotifier<String>('00:00');
  Timer? _timer;
  Timestamp? _startTime;

  @override
  void initState() {
    super.initState();
    _fetchStartTime();
  }

  Future<void> _fetchStartTime() async {
    final doc = await FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      _startTime = data['sessionStartTime'] as Timestamp?;
      if (_startTime != null) {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime == null) return;
      final now = DateTime.now();
      final start = _startTime!.toDate();
      final diff = now.difference(start);
      final minutes = diff.inMinutes.toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      _sessionTimer.value = '$minutes:$seconds';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).snapshots(),
          builder: (context, snapshot) {
            String title = 'Live Session';
            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              final memberName = data['memberName'] ?? 'Member';
              title = '$memberName · Live Session';
            }
            return Text(title, style: const TextStyle(fontWeight: FontWeight.bold));
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ValueListenableBuilder<String>(
                valueListenable: _sessionTimer,
                builder: (context, value, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Session not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final sessionFocus = data['sessionFocus'] as String? ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (sessionFocus.isNotEmpty)
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.track_changes, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Focus: $sessionFocus',
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: (data['exercises'] as List?)?.length ?? 0,
                  itemBuilder: (context, index) {
                    final exercises = List<dynamic>.from(data['exercises']);
                    final exercise = exercises[index] as Map<String, dynamic>;
                    return _buildExerciseItem(context, index, exercise, exercises);
                  },
                ),
              ),
              if ((data['exercises'] as List?)?.every((e) => e['status'] == 'complete') ?? false)
                _buildEndSessionCard(data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, int index, Map<String, dynamic> exercise, List<dynamic> exercises) {
    final status = exercise['status'] as String? ?? 'pending';
    final isMobilityWork = exercise['isMobilityWork'] == true;
    final completedSets = List<dynamic>.from(exercise['completedSets'] ?? []);

    Widget statusIcon;
    if (status == 'pending') {
      statusIcon = const Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 24);
    } else if (status == 'active') {
      statusIcon = const Icon(Icons.circle, color: AppColors.primary, size: 24)
          .animate(onPlay: (controller) => controller.repeat())
          .scale(duration: 800.ms)
          .then()
          .scale(end: const Offset(0.8, 0.8), duration: 800.ms);
    } else {
      statusIcon = const Icon(Icons.check_circle, color: AppColors.success, size: 24);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                statusIcon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Target: ${exercise['sets'] ?? 0} × ${exercise['reps'] ?? 0} @ ${exercise['weightKg'] ?? 0}kg',
                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                if (isMobilityWork)
                   const Icon(Icons.accessibility_new, color: AppColors.turquoise, size: 20),
              ],
            ),
            if (completedSets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: completedSets.map((setInfo) {
                  return Chip(
                    label: Text('${setInfo['reps']} × ${setInfo['weightKg']}kg'),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ],
            if (status == 'active') ...[
              const Divider(height: 24),
              _buildActiveExerciseControls(context, index, exercise, exercises),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveExerciseControls(BuildContext context, int index, Map<String, dynamic> exercise, List<dynamic> exercises) {
    final repsController = TextEditingController();
    final weightController = TextEditingController();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () async {
                final reps = int.tryParse(repsController.text) ?? 0;
                final weight = double.tryParse(weightController.text) ?? 0.0;
                if (reps > 0) {
                  final completedSets = List<Map<String, dynamic>>.from(exercise['completedSets'] ?? []);
                  completedSets.add({'reps': reps, 'weightKg': weight});
                  exercise['completedSets'] = completedSets;
                  exercises[index] = exercise;
                  await FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).update({'exercises': exercises});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('+ Log Set'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              exercise['status'] = 'complete';
              exercises[index] = exercise;

              if (index + 1 < exercises.length) {
                exercises[index + 1]['status'] = 'active';
              }

              await FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).update({'exercises': exercises});
            },
            icon: const Icon(Icons.check, color: AppColors.success),
            label: const Text('Mark Complete', style: TextStyle(color: AppColors.success)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.success),
            ),
          ),
        ),
      ],
    );
  }

  final TextEditingController _trainerNotesController = TextEditingController();
  final TextEditingController _ajaxNoteController = TextEditingController();
  double _sessionRpe = 5.0;

  Widget _buildEndSessionCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'End Session',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _trainerNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Trainer notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Overall Session RPE (1-10)', style: TextStyle(fontWeight: FontWeight.w500)),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Slider(
                      value: _sessionRpe,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _sessionRpe.round().toString(),
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setState(() => _sessionRpe = val);
                        this.setState(() {}); // Update parent state as well
                      },
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 (Easy)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        Text('10 (Max)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                );
              }
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _ajaxNoteController,
              decoration: const InputDecoration(
                labelText: 'AjAX memory note (optional)',
                hintText: 'Single sentence observation for AI',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.psychology, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _endSession(data),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('END SESSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _endSession(Map<String, dynamic> sessionData) async {
    final now = Timestamp.now();
    final startTime = sessionData['sessionStartTime'] as Timestamp?;
    final memberId = sessionData['memberAuthUid'] as String?;
    final sessionId = widget.sessionId;

    if (startTime == null || memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing session data.')),
      );
      return;
    }

    final int totalDurationMinutes = now.toDate().difference(startTime.toDate()).inMinutes;

    final batch = FirebaseFirestore.instance.batch();

    // 1. Update trainingSessions doc
    final sessionRef = FirebaseFirestore.instance.collection('trainingSessions').doc(sessionId);
    batch.update(sessionRef, {
      'status': 'complete',
      'sessionEndTime': now,
      'totalDurationMinutes': totalDurationMinutes,
      'trainerNotes': _trainerNotesController.text,
      'sessionRpe': _sessionRpe,
      'nutritionSentAt': now,
    });

    // 2. Write to workouts collection
    final workoutsRef = FirebaseFirestore.instance.collection('workouts').doc();
    batch.set(workoutsRef, {
      'memberId': memberId,
      'exercises': sessionData['exercises'],
      'duration': totalDurationMinutes,
      'date': now,
      'source': 'trainer_session',
      'sessionId': sessionId,
      'trainerId': sessionData['trainerId'],
    });

    // 3. Update memberGoals (simplified implementation relying on existing fields)
    final goalsSnapshot = await FirebaseFirestore.instance
        .collection('memberGoals')
        .where('memberId', isEqualTo: memberId)
        .where('status', isEqualTo: 'active')
        .get();

    if (goalsSnapshot.docs.isNotEmpty) {
      final goalRef = goalsSnapshot.docs.first.reference;
      batch.update(goalRef, {
        'lastPaceCheck': now,
      });
    }

    // 4. Update memberIntelligence
    final miRef = FirebaseFirestore.instance.collection('memberIntelligence').doc(memberId);
    final miDoc = await miRef.get();

    Map<String, dynamic> miUpdates = {
      'totalSessionsLogged': FieldValue.increment(1),
      'lastSessionDate': now,
    };

    if (miDoc.exists) {
      final currentMiData = miDoc.data()!;
      final double prevAvgRpe = (currentMiData['avgSessionRpe'] as num?)?.toDouble() ?? 0.0;
      final int totalSessions = (currentMiData['totalSessionsLogged'] as num?)?.toInt() ?? 0;
      final newAvgRpe = ((prevAvgRpe * totalSessions) + _sessionRpe) / (totalSessions + 1);
      miUpdates['avgSessionRpe'] = newAvgRpe;

      if (_ajaxNoteController.text.isNotEmpty) {
        final newObservation = '[${DateTime.now().toIso8601String().split('T')[0]}]: ${_ajaxNoteController.text}';
        List<dynamic> observations = List<dynamic>.from(currentMiData['trainerObservations'] ?? []);
        observations.add(newObservation);
        if (observations.length > 10) {
          observations.removeAt(0);
        }
        miUpdates['trainerObservations'] = observations;
      }
    } else {
       miUpdates['avgSessionRpe'] = _sessionRpe;
       if (_ajaxNoteController.text.isNotEmpty) {
           final newObservation = '[${DateTime.now().toIso8601String().split('T')[0]}]: ${_ajaxNoteController.text}';
           miUpdates['trainerObservations'] = [newObservation];
       }
    }

    batch.set(miRef, miUpdates, SetOptions(merge: true));

    // 5. Write to notifications
    final notificationRef = FirebaseFirestore.instance
        .collection('notifications')
        .doc(memberId)
        .collection('items')
        .doc();
    batch.set(notificationRef, {
      'type': 'weigh_in_reminder',
      'title': '⚖️ Weigh-in Day!',
      'body': 'Log your weight before eating. Helps AjAX calibrate your plan.',
      'scheduledFor': sessionData['nextWeighInDate'] ?? now,
      'delivered': false,
    });

    try {
      await batch.commit();
      if (!mounted) return;
      if (context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst); // Returns to Dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session complete! Data saved to AjAX.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to end session: $e')),
        );
      }
    }
  }
}
