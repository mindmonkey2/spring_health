import 'package:flutter/material.dart';

class TrainerScanScreen extends StatelessWidget {
  final String? prefillMemberId;

  const TrainerScanScreen({super.key, this.prefillMemberId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Member')),
      body: Center(
        child: Text(prefillMemberId != null
            ? 'Scan Screen Stub - Pre-filled Member: $prefillMemberId'
            : 'Scan Screen Stub'),
      ),
    );
  }
}
