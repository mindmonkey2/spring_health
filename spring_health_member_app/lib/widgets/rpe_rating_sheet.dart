import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/rpe_service.dart';

class RpeRatingSheet extends StatefulWidget {
  final String sessionId;
  final List<String> muscleGroups;
  const RpeRatingSheet({
    super.key,
    required this.sessionId,
    required this.muscleGroups,
  });

  @override
  State<RpeRatingSheet> createState() => _RpeRatingSheetState();
}

class _RpeRatingSheetState extends State<RpeRatingSheet> {
  bool _submitting = false;

  static const List<Map<String, dynamic>> _rpeOptions = [
    {'value': 1, 'label': 'Very Easy',   'color': Color(0xFF4CAF50)},
    {'value': 2, 'label': 'Easy',        'color': Color(0xFF8BC34A)},
    {'value': 3, 'label': 'Moderate',    'color': Color(0xFFC6F135)},  // neonLime
    {'value': 4, 'label': 'Hard',        'color': Color(0xFFFF9800)},
    {'value': 5, 'label': 'Exhausting',  'color': Color(0xFFFF5252)},
  ];

  Future<void> _submitRpe(int rpe, String label) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await RpeService.instance.submitRpe(
        rpe: rpe,
        label: label,
        sessionId: widget.sessionId,
        muscleGroups: widget.muscleGroups,
      );
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How was that session?',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rate the difficulty so AjAX can adjust your next plan.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_submitting)
            const CircularProgressIndicator(color: AppColors.neonLime)
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _rpeOptions.map((option) {
                return _buildRpeButton(
                  value: option['value'] as int,
                  label: option['label'] as String,
                  color: option['color'] as Color,
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          if (!_submitting)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Skip',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRpeButton({
    required int value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _submitRpe(value, label),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.85),
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
