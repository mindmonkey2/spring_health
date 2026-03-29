import 'package:flutter/material.dart';

class TrainerReadinessScreen extends StatelessWidget {
  final String memberName;
  final String memberAuthUid;
  final String trainerId;
  final String sessionId;
  final Map<String, dynamic>? wearableData;
  final Map<String, dynamic>? lastSession;
  final Map<String, dynamic>? memberIntelligence;
  final Map<String, dynamic>? bodyMetricsContext;
  final Map<String, dynamic>? goalContext;
  final int readinessScore;
  final int memberAge;
  final String memberId;
  final List<String> availableEquipment;
  final Map<String, dynamic>? flexibilityContext;

  const TrainerReadinessScreen({
    super.key,
    required this.memberName,
    required this.memberAuthUid,
    required this.trainerId,
    required this.sessionId,
    this.wearableData,
    this.lastSession,
    this.memberIntelligence,
    this.bodyMetricsContext,
    this.goalContext,
    required this.readinessScore,
    required this.memberAge,
    required this.memberId,
    required this.availableEquipment,
    this.flexibilityContext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Readiness')),
      body: const Center(child: Text('Placeholder')),
    );
  }
}
