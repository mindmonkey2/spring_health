import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/session_model.dart';
import '../../theme/app_colors.dart';
import 'trainer_session_screen.dart';
import '../../services/trainer_ajax_service.dart';

class TrainerWarmupScreen extends StatefulWidget {
  final String sessionId;
  final MemberModel member;
  final String trainerId;

  const TrainerWarmupScreen({
    super.key,
    required this.sessionId,
    required this.member,
    required this.trainerId,
  });

  @override
  State<TrainerWarmupScreen> createState() => _TrainerWarmupScreenState();
}

class _TrainerWarmupScreenState extends State<TrainerWarmupScreen> {
  final ValueNotifier<String> _countdown = ValueNotifier('05:00');
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.member.uid == null || widget.member.uid!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Warning: Member has no auth UID. AI analysis might fail.')),
          );
        }
      }

      final snap = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .get();
      final currentStatus = (snap.data()?['status'] as String?) ?? '';
      if (currentStatus == 'warmup') {
        await TrainerAjaxService.analyzeAndGenerate(
          memberId: widget.member.id,
          memberAuthUid: widget.member.uid ?? '',
          sessionId: widget.sessionId,
        );
      }
    });
  }

  void _startCountdown() {
    int seconds = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      seconds--;
      if (seconds <= 0) {
        t.cancel();
        return;
      }
      final m = seconds ~/ 60;
      final s = seconds % 60;
      _countdown.value =
          '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session Warmup'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('Session not found'));
          }

          final sessionMap = snapshot.data!.data() as Map<String, dynamic>;
          final sessionModel = SessionModel.fromMap(sessionMap, widget.sessionId);
          final plans = (sessionMap['plans'] as Map?) ?? {};
          final readinessScore = (sessionMap['readinessScore'] as num?)?.toInt() ?? 60;
          final goalInsight = sessionMap['goalInsight'] as String?;
          final sessionFocus = sessionMap['sessionFocus'] as String?;
          final isFoundationSession = sessionMap['isFoundationSession'] as bool? ?? false;

          if (sessionModel.status == 'active') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (_) => TrainerSessionScreen(
                  sessionId: widget.sessionId,
                  member: widget.member,
                  trainerId: widget.trainerId,
                ),
              ));
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (sessionModel.status == 'warmup') {
            if (plans.isNotEmpty) {
               return _buildWarmupState(sessionModel, plans, goalInsight, sessionFocus, readinessScore);
            }
            return _buildAnalyzingState(isFoundationSession);
          } else if (sessionModel.status == 'planning') {
             return _buildWarmupState(sessionModel, plans, goalInsight, sessionFocus, readinessScore);
          }

          return const Center(child: Text('Invalid session state'));
        },
      ),
    );
  }

  Widget _buildAnalyzingState(bool isFoundationSession) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Warming up ${widget.member.name}...',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: _countdown,
              builder: (_, val, __) => Text(
                val,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: AppColors.turquoise,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AjAX is analyzing health data\nand generating 3 personalized plans...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            if (isFoundationSession)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.turquoise),
                ),
                color: AppColors.surface,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Foundation Session',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'First session for this member. AjAX is building their baseline plan. Go easy — form and mobility first.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarmupState(SessionModel sessionModel, Map plans, String? goalInsight, String? sessionFocus, int readinessScore) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(
            child: Chip(
              label: Text(
                'AjAX Ready',
                style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.success,
            ),
          ),
          const SizedBox(height: 16),
          if (goalInsight != null && goalInsight.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.turquoise),
              ),
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AJAX GOAL INSIGHT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.turquoiseDark,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      goalInsight,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (sessionFocus != null && sessionFocus.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(
                  sessionFocus,
                  style: const TextStyle(color: AppColors.turquoiseDark),
                ),
                backgroundColor: const Color(0x1A4ECDC4),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Select a plan to begin:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...['low', 'medium', 'high'].map((intensity) {
            final planData = plans[intensity];
            if (planData == null) return const SizedBox.shrink();
            return _buildPlanCard(intensity, Map<String, dynamic>.from(planData as Map), sessionModel, readinessScore);
          }),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String intensity, Map<String, dynamic> plan, SessionModel sessionModel, int readinessScore) {
    Color cardTint;
    if (intensity == 'low') {
      cardTint = const Color(0x1A607D8B);
    } else if (intensity == 'medium') {
      cardTint = const Color(0x1A4ECDC4);
    } else {
      cardTint = const Color(0x1A8B9FF7);
    }

    bool isRecommended = false;
    if (readinessScore < 40 && intensity == 'low') isRecommended = true;
    if (readinessScore >= 40 && readinessScore <= 70 && intensity == 'medium') isRecommended = true;
    if (readinessScore > 70 && intensity == 'high') isRecommended = true;

    final exercisesList = (plan['exercises'] as List?)?.cast<Map<dynamic, dynamic>>() ?? [];
    final first3 = exercisesList.take(3).map((e) => e['name']?.toString() ?? 'Exercise').join(', ');

    // Attempt to determine mobility count if it exists in the data structure
    // If not explicitly provided, we count exercises with category 'mobility'
    int mobilityCount = 0;
    if (plan.containsKey('mobilityCount')) {
      mobilityCount = (plan['mobilityCount'] as num).toInt();
    } else {
      mobilityCount = exercisesList.where((e) => e['category']?.toString().toLowerCase() == 'mobility').length;
    }

    return Card(
      color: cardTint,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _selectPlan(intensity, plan, sessionModel),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    plan['label']?.toString() ?? 'Plan',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  Text('${plan['estimatedMinutes'] ?? 0} min', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text('~${plan['estimatedCalories'] ?? 0} kcal'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan['reasoning']?.toString() ?? '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Exercises: $first3',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              if (mobilityCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Mobility work: $mobilityCount exercises',
                    style: const TextStyle(color: AppColors.turquoiseDark, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              if (isRecommended)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Chip(
                    label: Text('Recommended', style: TextStyle(color: AppColors.textOnPrimary, fontSize: 12)),
                    backgroundColor: AppColors.turquoise,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              const Divider(height: 24, color: AppColors.border),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x1A000000),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _selectPlan(intensity, plan, sessionModel),
                  child: const Text('SELECT THIS PLAN'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectPlan(String intensity, Map<String, dynamic> planData, SessionModel sessionModel) async {
    final rawExercises = (planData['exercises'] as List?)?.cast<Map<dynamic, dynamic>>() ?? [];

    final List<Map<String, dynamic>> exercises = rawExercises.asMap().entries.map((e) {
      final map = Map<String, dynamic>.from(e.value);
      map['status'] = e.key == 0 ? 'active' : 'pending';
      map['completedSets'] = [];
      map['order'] = e.key;
      return map;
    }).toList();

    await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).update({
      'selectedIntensity': intensity,
      'exercises': exercises,
      'status': 'active',
      'sessionStartTime': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerSessionScreen(
          sessionId: widget.sessionId,
          member: widget.member,
          trainerId: widget.trainerId,
        ),
      ),
    );
  }
}
