import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../models/member_model.dart';
import 'trainer_stretching_screen.dart';

class TrainerSessionScreen extends StatefulWidget {
  final String sessionId;
  final MemberModel member;
  final String trainerId;

  const TrainerSessionScreen({
    super.key,
    required this.sessionId,
    required this.member,
    required this.trainerId,
  });

  @override
  State<TrainerSessionScreen> createState() => _TrainerSessionScreenState();
}

class _TrainerSessionScreenState extends State<TrainerSessionScreen> {
  final ValueNotifier<String> _sessionTimer = ValueNotifier('00:00');
  Timer? _timer;
  int _elapsed = 0;

  final Map<int, TextEditingController> _repsControllers = {};
  final Map<int, TextEditingController> _weightControllers = {};
  bool _hasNavigatedToStretching = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _elapsed++;
      final m = _elapsed ~/ 60;
      final s = _elapsed % 60;
      _sessionTimer.value =
          '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    });
  }

  TextEditingController _getRepsController(int index) =>
      _repsControllers.putIfAbsent(index, () => TextEditingController());

  TextEditingController _getWeightController(int index) =>
      _weightControllers.putIfAbsent(index, () => TextEditingController());

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTimer.dispose();
    for (var c in _repsControllers.values) {
      c.dispose();
    }
    for (var c in _weightControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _logSet(
      int exerciseIndex, Map<String, dynamic> exercise) async {
    final repsCtrl = _getRepsController(exerciseIndex);
    final weightCtrl = _getWeightController(exerciseIndex);

    final reps = int.tryParse(repsCtrl.text) ?? 0;
    final weight = double.tryParse(weightCtrl.text) ?? 0.0;

    if (reps <= 0) return;

    try {
      final docRef = FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId);

      await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final exercises =
            List<Map<String, dynamic>>.from(data['exercises'] ?? []);

        if (exerciseIndex >= exercises.length) return;

        final exToUpdate = exercises[exerciseIndex];
        final completedSets = List<Map<String, dynamic>>.from(
            exToUpdate['completedSets'] ?? []);

        completedSets.add({'reps': reps, 'weightKg': weight});
        exToUpdate['completedSets'] = completedSets;
        exercises[exerciseIndex] = exToUpdate;

        transaction.update(docRef, {'exercises': exercises});
      });

      repsCtrl.clear();
      weightCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log set: $e')));
      }
    }
  }

  Future<void> _markComplete(int exerciseIndex,
      Map<String, dynamic> exercise, int totalExercises) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId);

      await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final exercises =
            List<Map<String, dynamic>>.from(data['exercises'] ?? []);

        if (exerciseIndex >= exercises.length) return;

        exercises[exerciseIndex]['status'] = 'complete';

        if (exerciseIndex + 1 < exercises.length) {
          exercises[exerciseIndex + 1]['status'] = 'active';
        }

        transaction.update(docRef, {
          'exercises': exercises,
          'activeExerciseIndex': exerciseIndex + 1,
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to mark complete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.turquoise, AppColors.turquoiseDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('sessions')
              .doc(widget.sessionId)
              .snapshots(),
          builder: (context, snapshot) {
            final focus = snapshot.hasData && snapshot.data!.exists
                ? (snapshot.data!.data()
                        as Map<String, dynamic>)['sessionFocus']
                    as String? ??
                    ''
                : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.member.name} - Live Session',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                if (focus.isNotEmpty)
                  Text(
                    focus,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14),
                  ),
              ],
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: _sessionTimer,
                builder: (context, value, child) {
                  return Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.turquoise));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Session not found'));
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>;
          final exercises =
              List<Map<String, dynamic>>.from(data['exercises'] ?? []);
          final allComplete = exercises.isNotEmpty &&
              exercises.every((ex) => ex['status'] == 'complete');

          if (allComplete && !_hasNavigatedToStretching) {
            _hasNavigatedToStretching = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final allMuscles = exercises
                  .expand((ex) => List<String>.from(ex['targetMuscles'] ?? []))
                  .toSet().toList();

              await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({
                'musclesWorked': allMuscles,
                'status': 'stretching'
              }, SetOptions(merge: true));

              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => TrainerStretchingScreen(
                  sessionId: widget.sessionId,
                  member: widget.member,
                  trainerId: widget.trainerId,
                  musclesWorked: allMuscles,
                )),
              );
            });
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final ex = exercises[index];
              final status =
                  ex['status'] as String? ?? 'pending';
              final isMobility = ex['isMobilityWork'] == true;
              final sets = ex['sets'] ?? 0;
              final reps = ex['reps'] ?? 0;
              final weightKg = ex['weightKg'] ?? 0;
              final completedSets =
                  List<Map<String, dynamic>>.from(
                      ex['completedSets'] ?? []);

              Widget leadingDot;
              if (status == 'complete') {
                leadingDot = const Icon(Icons.check_circle,
                    color: AppColors.success);
              } else if (status == 'active') {
                leadingDot = Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.turquoise,
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(
                        onPlay: (controller) =>
                            controller.repeat())
                    .scale(duration: 800.ms)
                    .then()
                    .scale(
                        end: const Offset(0.8, 0.8),
                        duration: 800.ms);
              } else {
                leadingDot = Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.grey, width: 2),
                  ),
                );
              }

              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          leadingDot,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex['name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Target: ${sets}x$reps @ $weightKg kg',
                                  style: const TextStyle(
                                      color: AppColors
                                          .textSecondary,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (isMobility)
                            const Chip(
                              label: Text('Mobility',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10)),
                              backgroundColor:
                                  AppColors.turquoise,
                              padding: EdgeInsets.zero,
                              visualDensity:
                                  VisualDensity.compact,
                            ),
                        ],
                      ),
                      if (completedSets.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: completedSets
                                .map((s) => Chip(
                                      label: Text(
                                          '${s['reps']} reps @ ${s['weightKg']} kg',
                                          style:
                                              const TextStyle(
                                                  fontSize:
                                                      11)),
                                      backgroundColor:
                                          AppColors.background,
                                      visualDensity:
                                          VisualDensity
                                              .compact,
                                    ))
                                .toList(),
                          ),
                        ),
                      if (status == 'active')
                        AnimatedSize(
                          duration:
                              const Duration(milliseconds: 300),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _getRepsController(
                                                index),
                                        keyboardType:
                                            TextInputType
                                                .number,
                                        decoration:
                                            const InputDecoration(
                                          labelText: 'Reps',
                                          border:
                                              OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            _getWeightController(
                                                index),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                                decimal: true),
                                        decoration:
                                            const InputDecoration(
                                          labelText:
                                              'Weight (kg)',
                                          border:
                                              OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          _logSet(index, ex),
                                      style: OutlinedButton
                                          .styleFrom(
                                        foregroundColor:
                                            AppColors.turquoise,
                                        side: const BorderSide(
                                            color: AppColors
                                                .turquoise),
                                      ),
                                      child: const Text(
                                          'Log Set'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _markComplete(
                                              index,
                                              ex,
                                              exercises
                                                  .length),
                                      style: ElevatedButton
                                          .styleFrom(
                                        backgroundColor:
                                            AppColors.success,
                                        foregroundColor:
                                            Colors.white,
                                      ),
                                      child: const Text(
                                          'Mark Complete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
