import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import 'trainer_readiness_screen.dart';

class FlexibilityAssessmentScreen extends StatefulWidget {
  final String memberName;
  final String memberAuthUid;
  final String trainerId;
  final String sessionId;
  final Map<String, dynamic>? wearableData;
  final Map<String, dynamic>? lastSession;
  final Map<String, dynamic>? memberIntelligence;
  final Map<String, dynamic>? bodyMetricsContext;
  final Map<String, dynamic>? goalContext;
  final int readinessScore;
  final int memberAge;
  final String memberId;
  final List<String> availableEquipment;

  const FlexibilityAssessmentScreen({
    super.key,
    required this.memberName,
    required this.memberAuthUid,
    required this.trainerId,
    required this.sessionId,
    required this.wearableData,
    required this.lastSession,
    required this.memberIntelligence,
    required this.bodyMetricsContext,
    required this.goalContext,
    required this.readinessScore,
    required this.memberAge,
    required this.memberId,
    required this.availableEquipment,
  });

  @override
  State<FlexibilityAssessmentScreen> createState() => _FlexibilityAssessmentScreenState();
}

class _FlexibilityAssessmentScreenState extends State<FlexibilityAssessmentScreen> {
  final Map<int, int> _scores = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _stretches = [
    {
      'name': 'Sit and Reach',
      'instruction': 'Seated on floor, legs straight. Reach forward toward toes.',
      'id': 'sitAndReach',
    },
    {
      'name': 'Shoulder Cross-Body Reach',
      'instruction': 'Cross one arm across chest. How far does it reach past the shoulder?',
      'id': 'shoulderMobility',
    },
    {
      'name': 'Hip Flexor Lunge Hold',
      'instruction': 'Low lunge position. Does the hip drop fully and comfortably?',
      'id': 'hipFlexor',
    },
    {
      'name': 'Thoracic Rotation',
      'instruction': 'Seated, arms crossed on chest. Rotate left and right. Range of motion?',
      'id': 'thoracicRotation',
    },
    {
      'name': 'Ankle Dorsiflexion',
      'instruction': 'Knee-to-wall test. Can the knee touch the wall with heel flat on floor?',
      'id': 'ankleMobility',
    },
    {
      'name': 'Overhead Squat Hold',
      'instruction': 'Arms overhead, squat to parallel. Can they maintain upright torso and form?',
      'id': 'overheadSquat',
    },
    {
      'name': 'Pigeon Pose',
      'instruction': 'Hip external rotation. Can they hold flat for 10 seconds comfortably?',
      'id': 'pigeonPose',
    },
  ];

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Very Tight';
      case 2:
        return 'Tight';
      case 3:
        return 'Moderate';
      case 4:
        return 'Flexible';
      case 5:
        return 'Very Flexible';
      default:
        return '';
    }
  }

  void _skipForNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerReadinessScreen(
          memberName: widget.memberName,
          memberAuthUid: widget.memberAuthUid,
          trainerId: widget.trainerId,
          sessionId: widget.sessionId,
          wearableData: widget.wearableData,
          lastSession: widget.lastSession,
          memberIntelligence: widget.memberIntelligence,
          bodyMetricsContext: widget.bodyMetricsContext,
          goalContext: widget.goalContext,
          readinessScore: widget.readinessScore,
          memberAge: widget.memberAge,
          memberId: widget.memberId,
          availableEquipment: widget.availableEquipment,
          flexibilityContext: null,
        ),
      ),
    );
  }

  Future<void> _completeAssessment() async {
    if (_scores.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate all 7 stretches before completing.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      int sum = 0;
      List<String> tightAreas = [];
      Map<String, int> results = {};

      for (int i = 0; i < 7; i++) {
        final score = _scores[i]!;
        sum += score;
        results[_stretches[i]['id']!] = score;
        if (score <= 2) {
          tightAreas.add(_stretches[i]['name']!);
        }
      }

      final int overallScore = ((sum / 35.0) * 100).round();
      final now = Timestamp.now();

      final firestore = FirebaseFirestore.instance;

      final batch = firestore.batch();

      final testRef = firestore
          .collection('fitnessTests')
          .doc(widget.memberAuthUid)
          .collection('tests')
          .doc();

      batch.set(testRef, {
        'type': 'flexibility_assessment',
        'date': now,
        'assessedByTrainerId': widget.trainerId,
        'results': results,
        'overallScore': overallScore,
        'tightAreas': tightAreas,
        'notes': _notesController.text.trim(),
      });

      final intelligenceRef = firestore
          .collection('memberIntelligence')
          .doc(widget.memberAuthUid);

      batch.set(intelligenceRef, {
        'latestFlexibilityScore': overallScore,
        'tightAreas': tightAreas,
        'updatedAt': now,
      }, SetOptions(merge: true));

      await batch.commit();

      final Map<String, dynamic> flexibilityContext = {
        'assessmentDate': now,
        'overallScore': overallScore,
        'tightAreas': tightAreas,
        ...results,
      };

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerReadinessScreen(
            memberName: widget.memberName,
            memberAuthUid: widget.memberAuthUid,
            trainerId: widget.trainerId,
            sessionId: widget.sessionId,
            wearableData: widget.wearableData,
            lastSession: widget.lastSession,
            memberIntelligence: widget.memberIntelligence,
            bodyMetricsContext: widget.bodyMetricsContext,
            goalContext: widget.goalContext,
            readinessScore: widget.readinessScore,
            memberAge: widget.memberAge,
            memberId: widget.memberId,
            availableEquipment: widget.availableEquipment,
            flexibilityContext: flexibilityContext,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Explicit instructions requested "neonLime" background for selected items, overriding any normal theme if needed.
    const Color neonLime = Color(0xFF32CD32);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Initial Flexibility Assessment'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            floating: true,
            actions: [
              TextButton(
                onPressed: _skipForNow,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Perform each stretch with ${widget.memberName}. Rate their range of motion honestly.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _stretches.length,
                    itemBuilder: (context, index) {
                      final stretch = _stretches[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        color: AppColors.cardBackground,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.turquoise,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stretch['name']!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          stretch['instruction']!,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(5, (ratingIndex) {
                                  final rating = ratingIndex + 1;
                                  final isSelected = _scores[index] == rating;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _scores[index] = rating;
                                      });
                                    },
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width - 64) / 5,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isSelected ? neonLime : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? neonLime : AppColors.border,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$rating',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : AppColors.textPrimary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            _getRatingLabel(rating),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isSelected ? Colors.white : AppColors.textSecondary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Additional notes (optional)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter notes here...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _completeAssessment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'COMPLETE ASSESSMENT',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
