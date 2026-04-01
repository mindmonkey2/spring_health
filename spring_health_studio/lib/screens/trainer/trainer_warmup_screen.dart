import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/session_model.dart';
import '../../theme/app_colors.dart';
import 'trainer_session_screen.dart';
import '../../services/trainer_ajax_service.dart';
import '../../services/session_service.dart';

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
  bool _aiTriggered = false;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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

  Future<void> _checkAndTriggerAi(SessionModel session) async {
    if (_aiTriggered) return;

    // Check if the session is currently in warmup status and hasn't transitioned yet
    if (session.status == 'warmup') {
      _aiTriggered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await TrainerAjaxService.analyzeAndGenerate(
            memberId: widget.member.id,
            memberAuthUid: widget.member.id,
            sessionId: widget.sessionId,
          );
        } catch (e) {
          debugPrint('Error triggering AI generation: $e');
        }
      });
    }
  }

  Future<void> _handleSessionTransition(SessionModel session) async {
    if (_navigating) return;

    final bool allWarmupsComplete = session.warmup.isNotEmpty &&
        session.warmup.every((w) => w['status'] == 'completed');

    if (allWarmupsComplete && session.status == 'warmup') {
      // Transition to planning to wait for AI, or if AI is done it will skip to planning/active
      await SessionService().updateStatus(widget.sessionId, 'planning');
      return;
    }

    if (session.status == 'active' || (session.status == 'planning' && allWarmupsComplete)) {
       // If AI finished planning and warmup is done, or somehow already active
      _navigating = true;

      if (session.status == 'planning') {
        await SessionService().updateStatus(widget.sessionId, 'active');
      }

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
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
      });
    }
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

          _checkAndTriggerAi(sessionModel);
          _handleSessionTransition(sessionModel);

          return _buildWarmupList(sessionModel);
        },
      ),
    );
  }

  Widget _buildWarmupList(SessionModel session) {
    if (session.warmup.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Waiting for warmup to be generated...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            ValueListenableBuilder<String>(
              valueListenable: _countdown,
              builder: (_, val, __) => Text(
                val,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.turquoise,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ValueListenableBuilder<String>(
              valueListenable: _countdown,
              builder: (_, val, __) => Text(
                val,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: AppColors.turquoise,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Warmup Protocol',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...session.warmup.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            final isComplete = item['status'] == 'completed';

            return Card(
              color: AppColors.surface,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isComplete ? AppColors.success : AppColors.border,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isComplete ? AppColors.success.withValues(alpha: 0.2) : AppColors.turquoise.withValues(alpha: 0.1),
                  child: Icon(
                    isComplete ? Icons.check : Icons.fitness_center,
                    color: isComplete ? AppColors.success : AppColors.turquoise,
                  ),
                ),
                title: Text(
                  item['name'] ?? 'Exercise',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isComplete ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text('${item['durationSeconds'] ?? 0}s • ${item['notes'] ?? ''}'),
                trailing: isComplete
                    ? const Icon(Icons.check_circle, color: AppColors.success)
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.turquoise,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _markWarmupComplete(idx),
                        child: const Text('DONE', style: TextStyle(color: AppColors.background)),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _markWarmupComplete(int index) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(widget.sessionId)
          .get();
      if (!snap.exists) return;

      final currentWarmup = List<Map<String, dynamic>>.from(snap.data()?['warmup'] ?? []);
      if (index >= 0 && index < currentWarmup.length) {
        currentWarmup[index]['status'] = 'completed';
        await FirebaseFirestore.instance
            .collection('sessions')
            .doc(widget.sessionId)
            .update({'warmup': currentWarmup});
      }
    } catch (e) {
      debugPrint('Error marking warmup complete: $e');
    }
  }
}
