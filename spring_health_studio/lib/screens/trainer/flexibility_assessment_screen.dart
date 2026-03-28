import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spring_health_studio/theme/app_colors.dart';
import 'package:spring_health_studio/screens/trainer/trainer_readiness_screen.dart';

class FlexibilityAssessmentScreen extends StatefulWidget {
  final String memberAuthUid;
  final String memberName;
  final String trainerId;
  final Map<String, dynamic>? contextData;

  const FlexibilityAssessmentScreen({
    super.key,
    required this.memberAuthUid,
    required this.memberName,
    required this.trainerId,
    this.contextData,
  });

  @override
  State<FlexibilityAssessmentScreen> createState() => _FlexibilityAssessmentScreenState();
}

class _FlexibilityAssessmentScreenState extends State<FlexibilityAssessmentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _notesController = TextEditingController();

  final List<Map<String, dynamic>> _stretches = [
    {
      'name': 'Sit & Reach',
      'subtitle': 'Seated on floor, legs straight. Reach toward toes.',
      'score': null,
    },
    {
      'name': 'Shoulder Cross-Body Reach',
      'subtitle': 'Cross one arm across chest. How far past shoulder?',
      'score': null,
    },
    {
      'name': 'Hip Flexor Lunge Hold',
      'subtitle': 'Low lunge — does hip drop fully to floor comfortably?',
      'score': null,
    },
    {
      'name': 'Thoracic Rotation',
      'subtitle': 'Seated, arms crossed on chest. Rotate left and right.',
      'score': null,
    },
    {
      'name': 'Ankle Dorsiflexion',
      'subtitle': 'Knee-to-wall test — does knee touch wall with heel flat?',
      'score': null,
    },
    {
      'name': 'Overhead Squat Hold',
      'subtitle': 'Arms overhead, squat to parallel. Can they maintain form?',
      'score': null,
    },
    {
      'name': 'Pigeon Pose',
      'subtitle': 'Hip external rotation — can they hold flat for 10 seconds?',
      'score': null,
    },
  ];

  bool _isSubmitting = false;

  void _skipAssessment() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          final data = widget.contextData ?? {
            'memberAuthUid': widget.memberAuthUid,
            'memberName': widget.memberName,
          };
          data['flexibilityData'] = null;
          return TrainerReadinessScreen(
            contextData: data,
            trainerId: widget.trainerId,
          );
        },
      ),
    );
  }

  Future<void> _submitAssessment() async {
    // Validation
    for (int i = 0; i < _stretches.length; i++) {
      if (_stretches[i]['score'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please rate all 7 stretches before submitting.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      int sum = 0;
      Map<String, int> resultsMap = {};
      List<String> tightAreas = [];

      for (var stretch in _stretches) {
        int score = stretch['score'] as int;
        sum += score;
        String name = stretch['name'] as String;
        resultsMap[name] = score;

        if (score == 1 || score == 2) {
          tightAreas.add(name);
        }
      }

      double overallScore = (sum / 35.0) * 100.0;

      Map<String, dynamic> flexibilityData = {
        'overallScore': overallScore,
        'tightAreas': tightAreas,
        'results': resultsMap,
        'notes': _notesController.text.trim(),
      };

      // 1. Write to fitnessTests
      await _firestore
          .collection('fitnessTests')
          .doc(widget.memberAuthUid)
          .collection('tests')
          .add({
        'type': 'flexibility_assessment',
        'date': FieldValue.serverTimestamp(),
        'assessedByTrainerId': widget.trainerId,
        'results': resultsMap,
        'overallScore': overallScore,
        'tightAreas': tightAreas,
        'notes': _notesController.text.trim(),
      });

      // 2. Update memberIntelligence
      await _firestore
          .collection('memberIntelligence')
          .doc(widget.memberAuthUid)
          .set({
        'latestFlexibilityScore': overallScore,
        'tightAreas': tightAreas,
        'lastAssessmentDate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              final data = widget.contextData ?? {
                'memberAuthUid': widget.memberAuthUid,
                'memberName': widget.memberName,
              };
              data['flexibilityData'] = flexibilityData;
              return TrainerReadinessScreen(
                contextData: data,
                trainerId: widget.trainerId,
              );
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving assessment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildStretchCard(int index) {
    final stretch = _stretches[index];
    final int? currentScore = stretch['score'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stretch['name'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stretch['subtitle'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (starIndex) {
                final int ratingValue = starIndex + 1;
                final bool isSelected = currentScore != null && currentScore >= ratingValue;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _stretches[index]['score'] = ratingValue;
                    });
                  },
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? AppColors.turquoiseDark : AppColors.textMuted,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Very Tight',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Very Flexible',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Initial Flexibility Assessment',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _skipAssessment,
            child: Text(
              'Skip for now',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perform each stretch with ${widget.memberName}. Rate their flexibility honestly.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    _stretches.length,
                    (index) => _buildStretchCard(index),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Trainer Notes (Optional)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Add any specific observations...',
                      hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Padding for the bottom button
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAssessment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'COMPLETE ASSESSMENT',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
