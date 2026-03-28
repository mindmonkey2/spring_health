import 'package:flutter/material.dart';

class TrainerSessionScreen extends StatelessWidget {
  final String sessionId;

  const TrainerSessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Session')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 64.0, color: Colors.blueAccent),
            const SizedBox(height: 24.0),
            const Text('Session Started!', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            Text('Session ID: $sessionId', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32.0),
            const Text('Tracking UI coming soon.', style: TextStyle(fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
