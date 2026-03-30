import 'package:flutter/material.dart';

class TrainerWarmupScreen extends StatelessWidget {
  final dynamic sessionId;
  final dynamic member;
  final dynamic trainerId;

  const TrainerWarmupScreen({
    super.key,
    this.sessionId,
    this.member,
    this.trainerId,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Trainer Warmup Stub'),
      ),
    );
  }
}
