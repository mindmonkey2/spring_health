import 'package:flutter/material.dart';

class TrainerReadinessScreen extends StatelessWidget {
  final String authUid;

  const TrainerReadinessScreen({super.key, required this.authUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Readiness')),
      body: const Center(child: Text('Readiness Screen Placeholder')),
    );
  }
}
