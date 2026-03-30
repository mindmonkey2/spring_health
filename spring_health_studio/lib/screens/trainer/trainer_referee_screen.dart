import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TrainerRefereeScreen extends StatelessWidget {
  const TrainerRefereeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referee Duels'),
        backgroundColor: AppColors.warningDark,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Active duels to referee will appear here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
