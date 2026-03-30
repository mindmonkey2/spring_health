import 'package:flutter/material.dart';

class TrainerSessionScreen extends StatelessWidget {
  final String sessionId;
  final dynamic member;
  final String trainerId;

  const TrainerSessionScreen({
    super.key,
    required this.sessionId,
    required this.member,
    required this.trainerId,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Trainer Session Stub'),
      ),
    );
  }
}
