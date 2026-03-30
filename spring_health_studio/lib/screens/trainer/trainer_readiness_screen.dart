import 'package:flutter/material.dart';
import '../../models/member_model.dart';

class TrainerReadinessScreen extends StatelessWidget {
  final MemberModel member;
  final String trainerId;
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic>? flexibilityData;

  const TrainerReadinessScreen({
    super.key,
    required this.member,
    required this.trainerId,
    required this.sessionData,
    this.flexibilityData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Readiness (Placeholder)')),
      body: const Center(
        child: Text('Placeholder for Trainer Readiness Screen'),
      ),
    );
  }
}
