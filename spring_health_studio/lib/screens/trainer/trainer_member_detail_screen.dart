import 'package:flutter/material.dart';

class TrainerMemberDetailScreen extends StatelessWidget {
  final String memberId;

  const TrainerMemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Details')),
      body: Center(child: Text('Member Detail Stub: $memberId')),
    );
  }
}
