import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Assuming member app colors (Neon Dark)
class AppColors {
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color cardSurface = Color(0xFF1E1E1E);
  static const Color neonLime = Color(0xFFD9F99D);
  static const Color neonTeal = Color(0xFF2DD4BF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
}

class MemberSessionScreen extends StatefulWidget {
  final String sessionId;

  const MemberSessionScreen({super.key, required this.sessionId});

  @override
  State<MemberSessionScreen> createState() => _MemberSessionScreenState();
}

class _MemberSessionScreenState extends State<MemberSessionScreen> {
  final ValueNotifier<String> _sessionTimer = ValueNotifier('00:00');
  Timer? _timer;
  DateTime? _startTime;

  @override
  void dispose() {
    _timer?.cancel();
    _sessionTimer.dispose();
    super.dispose();
  }

  void _startTimer(Timestamp startTimestamp) {
    if (_timer != null) return;
    _startTime = startTimestamp.toDate();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = DateTime.now().difference(_startTime!);
      final m = diff.inMinutes;
      final s = diff.inSeconds % 60;
      _sessionTimer.value =
          '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Live Session', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: ValueListenableBuilder<String>(
                valueListenable: _sessionTimer,
                builder: (context, val, child) {
                  return Text(
                    val,
                    style: const TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trainingSessions')
            .doc(widget.sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Session not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] as String? ?? 'warmup';

          if (data['sessionStartTime'] != null && status != 'complete') {
            _startTimer(data['sessionStartTime'] as Timestamp);
          } else if (status == 'complete') {
            _timer?.cancel();
          }

          if (status == 'warmup' || status == 'analyzing') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your trainer is building your plan.',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Get warmed up and ready!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: AppColors.neonLime),
                ],
              ),
            );
          }

          if (status == 'active') {
            final goalInsight = data['goalInsight'] as String?;
            final exercises = List<Map<String, dynamic>>.from(data['exercises'] ?? []);

            return Column(
              children: [
                if (goalInsight != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      color: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.neonTeal),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AjAX Goal Insight',
                              style: TextStyle(
                                color: AppColors.neonTeal,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              goalInsight,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      final exStatus = ex['status'] as String? ?? 'pending';
                      final isMobility = ex['isMobilityWork'] == true;
                      final sets = ex['sets'] ?? 0;
                      final reps = ex['reps'] ?? 0;
                      final weightKg = ex['weightKg'] ?? 0;
                      final completedSets = List<Map<String, dynamic>>.from(ex['completedSets'] ?? []);

                      Widget leadingDot;
                      if (exStatus == 'complete') {
                        leadingDot = const Icon(Icons.check_circle, color: AppColors.neonLime);
                      } else if (exStatus == 'active') {
                        leadingDot = Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.neonTeal,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat())
                          .scale(duration: 800.ms)
                          .then().scale(end: const Offset(0.8, 0.8), duration: 800.ms);
                      } else {
                        leadingDot = Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                        );
                      }

                      return Card(
                        color: AppColors.cardSurface,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: exStatus == 'active' ? AppColors.neonTeal : Colors.transparent,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  leadingDot,
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ex['name'] ?? '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Target: ${sets}x$reps @ $weightKg kg',
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isMobility)
                                    Chip(
                                      label: const Text(
                                        'Mobility',
                                        style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                      backgroundColor: AppColors.neonTeal,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                              if (completedSets.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: completedSets.map((s) => Chip(
                                      label: Text(
                                        '${s['reps']} reps @ ${s['weightKg']} kg',
                                        style: const TextStyle(fontSize: 11, color: Colors.white),
                                      ),
                                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                                      visualDensity: VisualDensity.compact,
                                      side: BorderSide.none,
                                    )).toList(),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (status == 'complete') {
            return const Center(
              child: Text(
                'Session Complete!',
                style: TextStyle(color: AppColors.neonLime, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
