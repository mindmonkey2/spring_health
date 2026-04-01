import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/trainer_ajax_service.dart';
import '../../theme/app_colors.dart';

class TrainerStretchingScreen extends StatefulWidget {
  final String sessionId;
  final MemberModel member;
  final String trainerId;
  final List<String> musclesWorked;

  const TrainerStretchingScreen({
    super.key,
    required this.sessionId,
    required this.member,
    required this.trainerId,
    required this.musclesWorked,
  });

  @override
  State<TrainerStretchingScreen> createState() => _TrainerStretchingScreenState();
}

class _TrainerStretchingScreenState extends State<TrainerStretchingScreen> {
  bool _isLoading = true;
  bool _isEndingSession = false;
  List<Map<String, dynamic>> _stretches = [];
  int _currentStretchIndex = 0;
  final ValueNotifier<String> _countdown = ValueNotifier('00:00');
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadStretching();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdown.dispose();
    super.dispose();
  }

  Future<void> _loadStretching() async {
    final stretches = await TrainerAjaxService.generateStretching(widget.musclesWorked);

    // Also write to session so other devices stay synced
    await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({
      'stretching': stretches,
    }, SetOptions(merge: true));

    if (!mounted) return;
    setState(() {
      _stretches = stretches;
      _isLoading = false;
    });

    if (stretches.isNotEmpty) {
      _startStretchTimer(stretches[0]['durationSeconds'] as int);
    }
  }

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startStretchTimer(int seconds) {
    _timer?.cancel();
    int remaining = seconds;
    _countdown.value = _format(remaining);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      _countdown.value = _format(remaining);
      if (remaining <= 0) {
        t.cancel();
      }
    });
  }

  Future<void> _markStretchComplete(int index) async {
    setState(() {
      _stretches[index]['status'] = 'complete';
    });

    // Write to Firestore: update stretching list
    await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionId).set({
      'stretching': _stretches,
    }, SetOptions(merge: true));

    final next = index + 1;
    if (next < _stretches.length) {
      setState(() {
        _currentStretchIndex = next;
      });
      _startStretchTimer(_stretches[next]['durationSeconds'] as int);
    } else {
      _timer?.cancel();
      setState(() {
        _currentStretchIndex = _stretches.length;
      });
    }
  }

  Future<void> _endSession() async {
    setState(() => _isEndingSession = true);
    await TrainerAjaxService.finalizeSession(widget.sessionId);
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session complete! Diet plan sent to member.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cool Down & Stretch', style: TextStyle(color: AppColors.textPrimary)),
            Text(widget.member.name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Building stretch plan...', style: TextStyle(color: AppColors.textPrimary)),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_currentStretchIndex < _stretches.length) ...[
                    Text(
                      'Stretch ${_currentStretchIndex + 1} of ${_stretches.length}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildCurrentStretchCard(),
                  ] else ...[
                    const Spacer(),
                    const Center(
                      child: Text(
                        'All stretches done! 🎯',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isEndingSession ? null : _endSession,
                      child: _isEndingSession
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('End Session & Send Diet Plan', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Text('Completed Stretches', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _stretches.length,
                      itemBuilder: (context, index) {
                        final stretch = _stretches[index];
                        if (stretch['status'] != 'complete') return const SizedBox.shrink();
                        return Card(
                          color: AppColors.surface,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: AppColors.success),
                            title: Text(stretch['exerciseName'] as String, style: const TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text('Muscle: ${stretch['targetMuscle']}', style: const TextStyle(color: AppColors.textSecondary)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentStretchCard() {
    final current = _stretches[_currentStretchIndex];
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.turquoise, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Chip(
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              label: Text(current['targetMuscle'] as String, style: const TextStyle(color: AppColors.primary)),
            ),
            const SizedBox(height: 16),
            Text(
              current['exerciseName'] as String,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<String>(
              valueListenable: _countdown,
              builder: (context, value, child) {
                return Text(
                  value,
                  style: const TextStyle(color: AppColors.turquoise, fontSize: 48, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _markStretchComplete(_currentStretchIndex),
              child: const Text('Mark Complete', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
