import 'package:flutter/material.dart';
import '../../models/member_model.dart';

class TrainerStretchingScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stretching')),
      body: const Center(child: Text('Stretching Screen Placeholder')),
    );
  }
}
