import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import 'trainer_session_screen.dart';

class TrainerWarmupScreen extends StatefulWidget {
  final String sessionId;

  const TrainerWarmupScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<TrainerWarmupScreen> createState() => _TrainerWarmupScreenState();
}

class _TrainerWarmupScreenState extends State<TrainerWarmupScreen> {
  final ValueNotifier<String> _countdown = ValueNotifier('05:00');
  Timer? _timer;
  int _secondsRemaining = 300;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
        final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
        final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
        _countdown.value = '$minutes:$seconds';
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdown.dispose();
    super.dispose();
  }

  Future<void> _selectPlan(Map<String, dynamic> sessionData, String intensity, Map<String, dynamic> plan) async {
    final exercises = (plan['exercises'] as List).map((ex) {
      final map = Map<String, dynamic>.from(ex as Map);
      map['status'] = 'pending';
      map['completedSets'] = [];
      return map;
    }).toList();

    if (exercises.isNotEmpty) {
      exercises[0]['status'] = 'active';
    }

    await FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).update({
      'selectedIntensity': intensity,
      'exercises': exercises,
      'status': 'active',
      'sessionStartTime': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TrainerSessionScreen(sessionId: widget.sessionId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Warmup', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('trainingSessions').doc(widget.sessionId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessionDoc = snapshot.data!;
          final sessionData = sessionDoc.data() as Map<String, dynamic>? ?? {};
          final status = sessionData['status'] as String? ?? 'analyzing';
          final memberId = sessionData['memberId'] as String? ?? '';

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('members').doc(memberId).snapshots(),
            builder: (context, memberSnapshot) {
              final memberData = memberSnapshot.data?.data() as Map<String, dynamic>? ?? {};
              final memberName = memberData['name'] as String? ?? 'Member';

              if (status == 'analyzing' || status == 'pending') {
                return _buildWarmingUpState(memberName, sessionData);
              } else if (status == 'warmup') {
                return _buildPlansReadyState(sessionData);
              }

              return const Center(child: Text('Session in progress...'));
            }
          );
        },
      ),
    );
  }

  Widget _buildWarmingUpState(String memberName, Map<String, dynamic> sessionData) {
    final isFoundation = sessionData['isFoundationSession'] == true;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Warming up $memberName...',
            style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ValueListenableBuilder<String>(
            valueListenable: _countdown,
            builder: (context, value, child) {
              return Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('Analyzing metrics & generating plans...', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          if (isFoundation)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.success),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Foundation Session — First time! AjAX is building $memberName's baseline plan.",
                      style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlansReadyState(Map<String, dynamic> sessionData) {
    final goalInsight = sessionData['goalInsight'] as String? ?? '';
    final sessionFocus = sessionData['sessionFocus'] as String? ?? '';
    final plans = sessionData['plans'] as Map<String, dynamic>? ?? {};
    final readinessScore = (sessionData['readinessScore'] as num?)?.toDouble() ?? 70.0;

    String recommendedPlan = 'high';
    if (readinessScore <= 40) {
      recommendedPlan = 'low';
    } else if (readinessScore <= 70) {
      recommendedPlan = 'medium';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AjAX Ready',
                      style: GoogleFonts.poppins(color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check, color: AppColors.success, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.track_changes, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('AjAX GOAL INSIGHT', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(goalInsight, style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sessionFocus,
                      style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Intensity',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          if (plans.containsKey('low'))
            _buildPlanCard('low', plans['low'], AppColors.success, recommendedPlan == 'low', sessionData),
          const SizedBox(height: 12),
          if (plans.containsKey('medium'))
            _buildPlanCard('medium', plans['medium'], AppColors.warning, recommendedPlan == 'medium', sessionData),
          const SizedBox(height: 12),
          if (plans.containsKey('high'))
            _buildPlanCard('high', plans['high'], AppColors.error, recommendedPlan == 'high', sessionData),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String intensity, Map<String, dynamic> plan, Color color, bool isRecommended, Map<String, dynamic> sessionData) {
    final label = plan['label'] as String? ?? intensity.toUpperCase();
    final time = plan['estimatedMinutes'] as int? ?? 0;
    final kcal = plan['estimatedCalories'] as int? ?? 0;
    final reasoning = plan['reasoning'] as String? ?? '';
    final exercises = plan['exercises'] as List? ?? [];

    final top3Exercises = exercises.take(3).map((e) => e['name'] as String? ?? '').join(', ');
    final mobilityCount = exercises.where((e) => e['isMobilityWork'] == true).length;

    return Card(
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: isRecommended ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'AjAX RECOMMENDED',
                      style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
                Text(
                  '$time min | $kcal kcal',
                  style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(reasoning, style: GoogleFonts.inter(color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text('Exercises: $top3Exercises', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Mobility: $mobilityCount', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _selectPlan(sessionData, intensity, plan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('SELECT THIS PLAN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
