import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:spring_health_studio/theme/app_colors.dart';
import 'package:spring_health_studio/screens/trainer/trainer_readiness_screen.dart';
import 'package:spring_health_studio/models/member_model.dart';
import 'package:spring_health_studio/models/user_model.dart';

class FlexibilityAssessmentScreen extends StatefulWidget {
  final String authUid;
  final String memberName;
  final MemberModel member;
  final UserModel user;
  final int age;

  const FlexibilityAssessmentScreen({
    super.key,
    required this.authUid,
    required this.memberName,
    required this.member,
    required this.user,
    required this.age,
  });

  @override
  State<FlexibilityAssessmentScreen> createState() =>
      _FlexibilityAssessmentScreenState();
}

class _FlexibilityAssessmentScreenState
    extends State<FlexibilityAssessmentScreen> {
  final List<String> _stretches = [
    'Sit & Reach',
    'Shoulder Cross-Body',
    'Hip Flexor Lunge',
    'Thoracic Rotation',
    'Ankle Dorsiflexion',
    'Overhead Squat',
    'Pigeon Pose'
  ];

  final Map<String, int> _scores = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSaving = false;

  // Local override as explicitly requested by issue
  static const Color neonLime = Color(0xFFC6F135);

  @override
  void initState() {
    super.initState();
    for (var stretch in _stretches) {
      _scores[stretch] = 0; // 0 means unrated
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveAssessment() async {
    // Basic validation to ensure all stretches are rated
    if (_scores.values.any((score) => score == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate all 7 stretches.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final db = FirebaseFirestore.instance;

      // Calculate overallScore and tightAreas
      int sum = 0;
      List<String> tightAreas = [];

      _scores.forEach((name, score) {
        sum += score;
        if (score == 1 || score == 2) {
          tightAreas.add(name);
        }
      });

      double overallScore = (sum / 35.0) * 100.0;

      // Prepare batch write
      final batch = db.batch();

      // Write to fitnessTests
      final newTestRef = db
          .collection('fitnessTests')
          .doc(widget.authUid)
          .collection('tests')
          .doc();

      batch.set(newTestRef, {
        'type': 'flexibility_assessment',
        'date': FieldValue.serverTimestamp(),
        'results': _scores,
        'overallScore': overallScore,
        'tightAreas': tightAreas,
        'trainerNotes': _notesController.text.trim(),
      });

      // Update memberIntelligence
      final miRef = db.collection('memberIntelligence').doc(widget.authUid);
      batch.set(
        miRef,
        {
          'latestFlexibilityScore': overallScore.round(),
          'tightAreas': tightAreas,
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TrainerReadinessScreen(
              authUid: widget.authUid,
              user: widget.user,
              member: widget.member,
              age: widget.age,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving assessment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _skipForNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerReadinessScreen(
          authUid: widget.authUid,
          user: widget.user,
          member: widget.member,
          age: widget.age,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Initial Flexibility Assessment'),
        actions: [
          TextButton(
            onPressed: _skipForNow,
            child: const Text(
              'SKIP FOR NOW',
              style: TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Perform each stretch with ${widget.memberName}. Rate their flexibility (1-5 stars).',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stretch Cards
                  ..._stretches.map((stretch) => _buildStretchCard(stretch)),

                  const SizedBox(height: 16),

                  // Trainer Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Trainer Notes (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Complete Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveAssessment,
                    child: Text(
                      'COMPLETE ASSESSMENT',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildStretchCard(String name) {
    final int currentScore = _scores[name] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final int starValue = index + 1;
                final bool isSelected = starValue <= currentScore;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _scores[name] = starValue;
                    });
                  },
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? neonLime : Colors.grey.shade400,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 - Very Tight',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '5 - Very Flexible',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
