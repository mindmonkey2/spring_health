// lib/screens/trainer/trainer_feedback_screen.dart
import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../services/trainer_feedback_service.dart';
import '../../core/theme/app_colors.dart';

const List<String> _kWorkoutTypes = [
  'Strength Training',
'Cardio',
'HIIT',
'Yoga / Flexibility',
'Body Composition',
'General',
];

class TrainerFeedbackScreen extends StatefulWidget {
  final String trainerId;
  final String trainerName;
  final MemberModel member;

  const TrainerFeedbackScreen({
    super.key,
    required this.trainerId,
    required this.trainerName,
    required this.member,
  });

  @override
  State<TrainerFeedbackScreen> createState() =>
  _TrainerFeedbackScreenState();
}

class _TrainerFeedbackScreenState
extends State<TrainerFeedbackScreen> {
  final TrainerFeedbackService _service = TrainerFeedbackService();
  final TextEditingController _messageController =
  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _selectedWorkoutType = 'General';
  int _rating = 4;
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await _service.submitFeedback(
        trainerId: widget.trainerId,
        memberId: widget.member.id,
        memberName: widget.member.name,
        memberPhone: widget.member.phone,
        workoutType: _selectedWorkoutType,
        message: _messageController.text.trim(),
        rating: _rating,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted!'),
            backgroundColor: AppColors.neonTeal,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Workout Feedback',
                       style: TextStyle(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                         fontSize: 16)),
                      Text('to ${widget.trainerName}',
                           style: const TextStyle(
                             color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('Workout Type'),
              const SizedBox(height: 10),
              _buildWorkoutTypeSelector(),
              const SizedBox(height: 24),
              _buildSectionLabel('Rating'),
              const SizedBox(height: 10),
              _buildRatingRow(),
              const SizedBox(height: 24),
              _buildSectionLabel('Message'),
              const SizedBox(height: 10),
              _buildMessageField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5),
    );
  }

  Widget _buildWorkoutTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kWorkoutTypes.map((type) {
        final isSelected = _selectedWorkoutType == type;
        return InkWell(
          onTap: () => setState(() => _selectedWorkoutType = type),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                ? AppColors.neonTeal.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                  ? AppColors.neonTeal
                  : Colors.white24,
                ),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: isSelected ? AppColors.neonTeal : Colors.white54,
                  fontSize: 13,
                  fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.normal,
                ),
              ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = star),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              star <= _rating ? Icons.star : Icons.star_border,
              color: star <= _rating
              ? AppColors.neonLime
              : Colors.white38,
              size: 32,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      style: const TextStyle(color: Colors.white),
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
        'Describe the workout session, what went well, what to improve...',
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: AppColors.neonTeal),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please add a message';
        }
        if (v.trim().length < 10) {
          return 'Message must be at least 10 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonTeal,
          foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.neonTeal.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
              elevation: 0,
        ),
        child: _submitting
        ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.black, strokeWidth: 2))
        : const Text(
          'Submit Feedback',
          style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
