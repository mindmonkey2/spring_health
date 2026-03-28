import 'package:flutter/material.dart';

class TrainerScanScreen extends StatelessWidget {
  const TrainerScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: const Center(child: Text('Scanner functionality here')),
    );
  }
}
