import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/member_model.dart';
import 'trainer_readiness_screen.dart';

class FlexibilityAssessmentScreen extends StatefulWidget {
  final MemberModel member;
  final String trainerId;
  final Map<String, dynamic> pendingSessionData;

  const FlexibilityAssessmentScreen({
    super.key,
    required this.member,
    required this.trainerId,
    required this.pendingSessionData,
  });

  @override
  State<FlexibilityAssessmentScreen> createState() =>
      _FlexibilityAssessmentScreenState();
}

class _FlexibilityAssessmentScreenState
    extends State<FlexibilityAssessmentScreen> {
  final _notesController = TextEditingController();
  final Map<String, int> _scores = {};
  bool _isLoading = false;

  final List<Map<String, String>> _tests = [
    {
      'id': 'sitAndReach',
      'name': 'Sit and Reach',
      'instruction': 'Seated, legs straight. Reach toward toes.',
    },
    {
      'id': 'shoulderMobility',
      'name': 'Shoulder Cross-Body Reach',
      'instruction': 'Cross one arm across chest. How far past shoulder?',
    },
    {
      'id': 'hipFlexor',
      'name': 'Hip Flexor Lunge Hold',
      'instruction': 'Low lunge. Does hip drop fully to floor?',
    },
    {
      'id': 'thoracicRotation',
      'name': 'Thoracic Rotation',
      'instruction': 'Seated, arms crossed on chest. Rotate left and right.',
    },
    {
      'id': 'ankleMobility',
      'name': 'Ankle Dorsiflexion',
      'instruction': 'Knee-to-wall test. Heel stays flat on floor?',
    },
    {
      'id': 'overheadSquat',
      'name': 'Overhead Squat Hold',
      'instruction': 'Arms overhead, squat to parallel. Form intact?',
    },
    {
      'id': 'pigeonPose',
      'name': 'Pigeon Pose',
      'instruction': 'Hip external rotation. Can they hold flat for 10 seconds?',
    },
  ];

  void _skipForNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TrainerReadinessScreen(
          sessionId: widget.pendingSessionData['sessionId'] as String,
          member: widget.member,
          trainerId: widget.trainerId,
          sessionData: widget.pendingSessionData,
          flexibilityData: null,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_scores.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please rate all 7 tests.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      int sum = 0;
      List<String> tightAreas = [];
      Map<String, int> results = {};

      for (var test in _tests) {
        final score = _scores[test['id']]!;
        sum += score;
        results[test['id']!] = score;

        if (score <= 2) {
          tightAreas.add(test['name']!);
        }
      }

      int overallScore = ((sum / 35.0) * 100).round();
      final notes = _notesController.text.trim();

      final db = FirebaseFirestore.instance;
      final autoId = db.collection('fitnessTests').doc().id;
      final timestamp = Timestamp.now();

      await db
          .collection('fitnessTests')
          .doc(widget.member.id)
          .collection('tests')
          .doc(autoId)
          .set({
        'type': 'flexibility_assessment',
        'date': timestamp,
        'assessedByTrainerId': widget.trainerId,
        'results': results,
        'overallScore': overallScore,
        'tightAreas': tightAreas,
        'notes': notes,
      });

      await db.collection('memberIntelligence').doc(widget.member.id).set({
        'latestFlexibilityScore': overallScore,
        'tightAreas': tightAreas,
        'updatedAt': timestamp,
      }, SetOptions(merge: true));

      final flexibilityData = {
        'assessmentDate': timestamp,
        'sitAndReach': results['sitAndReach'],
        'shoulderMobility': results['shoulderMobility'],
        'hipFlexor': results['hipFlexor'],
        'thoracicRotation': results['thoracicRotation'],
        'ankleMobility': results['ankleMobility'],
        'overheadSquat': results['overheadSquat'],
        'pigeonPose': results['pigeonPose'],
        'overallScore': overallScore,
        'tightAreas': tightAreas,
      };

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerReadinessScreen(
            sessionId: widget.pendingSessionData['sessionId'] as String,
            member: widget.member,
            trainerId: widget.trainerId,
            sessionData: widget.pendingSessionData,
            flexibilityData: flexibilityData,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving assessment: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildRatingButtons(String testId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final score = index + 1;
        final isSelected = _scores[testId] == score;
        final primaryColor = Theme.of(context).colorScheme.primary;

        return InkWell(
          onTap: () {
            setState(() {
              _scores[testId] = score;
            });
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? primaryColor : Colors.transparent,
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                score.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Initial Flexibility Assessment'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Rate ${widget.member.name} honestly on each test.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _tests.length,
                    itemBuilder: (context, index) {
                      final test = _tests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  test['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(test['instruction']!),
                              ),
                              const SizedBox(height: 16),
                              _buildRatingButtons(test['id']!),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Very Tight',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Very Flexible',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Trainer notes (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'COMPLETE ASSESSMENT',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
