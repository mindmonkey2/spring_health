import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/member_model.dart';
import '../../models/health_profile_model.dart';
import '../../models/member_goal_model.dart';
import '../../models/gym_equipment_model.dart';
import '../../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainerReadinessScreen extends StatefulWidget {
  final String authUid;
  final UserModel user;
  final MemberModel member;
  final int age;
  final Map<String, dynamic>? memberIntelligence;

  const TrainerReadinessScreen({
    super.key,
    required this.authUid,
    required this.user,
    required this.member,
    required this.age,
    this.memberIntelligence,
  });

  @override
  State<TrainerReadinessScreen> createState() => _TrainerReadinessScreenState();
}

class _TrainerReadinessScreenState extends State<TrainerReadinessScreen> {
  bool _isLoading = true;
  String? _error;
  bool _isSaving = false;

  HealthProfileModel? _healthProfile;
  Map<String, dynamic>? _wearableSnapshot;
  List<Map<String, dynamic>> _bodyMetricsLogs = [];
  MemberGoalModel? _memberGoal;
  GymEquipmentModel? _gymEquipment;
  Map<String, dynamic>? _memberIntelligence;

  // Form State
  final List<String> _selectedSoreness = [];
  final List<String> _sorenessOptions = ['Shoulders', 'Chest', 'Back', 'Arms', 'Core', 'Legs', 'Knees', 'None'];
  int _energyLevel = 3;
  bool _hasInjury = false;
  final TextEditingController _injuryNotesController = TextEditingController();
  final List<String> _availableEquipment = [];

  @override
  void dispose() {
    _injuryNotesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchContextData();
  }

  Future<void> _fetchContextData() async {
    try {
      final db = FirebaseFirestore.instance;
      final authUid = widget.authUid;
      final branch = widget.member.branch;

      // 1. healthProfiles
      final healthFuture = db.collection('healthProfiles').doc(authUid).get();
      // 2. wearableSnapshots (yesterday, since cron might sync it or it's just the latest document. We'll fetch latest)
      final wearableFuture = db.collection('wearableSnapshots').doc(authUid).get();
      // 3. bodyMetricsLogs (last 4)
      final metricsFuture = db.collection('bodyMetricsLogs')
          .where('authUid', isEqualTo: authUid)
          .orderBy('date', descending: true)
          .limit(4)
          .get();
      // 5. memberGoals
      final goalsFuture = db.collection('memberGoals').doc(authUid).get();
      // 6. gymEquipment
      final equipmentFuture = db.collection('gymEquipment').doc(branch).get();
      // 7. memberIntelligence (if not provided)
      Future<DocumentSnapshot>? intelligenceFuture;
      if (widget.memberIntelligence == null) {
        intelligenceFuture = db.collection('memberIntelligence').doc(authUid).get();
      }

      final results = await Future.wait([
        healthFuture,
        wearableFuture,
        metricsFuture,
        goalsFuture,
        equipmentFuture,
        if (intelligenceFuture != null) intelligenceFuture,
      ]);

      if (mounted) {
        setState(() {
          final healthDoc = results[0] as DocumentSnapshot;
          if (healthDoc.exists) {
            _healthProfile = HealthProfileModel.fromMap(healthDoc.data() as Map<String, dynamic>, healthDoc.id);
          }

          final wearableDoc = results[1] as DocumentSnapshot;
          if (wearableDoc.exists) {
            _wearableSnapshot = wearableDoc.data() as Map<String, dynamic>?;
          }

          final metricsDocs = results[2] as QuerySnapshot;
          _bodyMetricsLogs = metricsDocs.docs.map((d) => d.data() as Map<String, dynamic>).toList();

          final goalsDoc = results[3] as DocumentSnapshot;
          if (goalsDoc.exists) {
            _memberGoal = MemberGoalModel.fromMap(goalsDoc.data() as Map<String, dynamic>, goalsDoc.id);
          }

          final equipmentDoc = results[4] as DocumentSnapshot;
          if (equipmentDoc.exists) {
            _gymEquipment = GymEquipmentModel.fromMap(equipmentDoc.data() as Map<String, dynamic>, equipmentDoc.id);
            _availableEquipment.addAll(_gymEquipment!.equipment);
          }

          if (intelligenceFuture != null) {
            final intelligenceDoc = results[5] as DocumentSnapshot;
            if (intelligenceDoc.exists) {
              _memberIntelligence = intelligenceDoc.data() as Map<String, dynamic>?;
            }
          } else {
            _memberIntelligence = widget.memberIntelligence;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load readiness data: $e';
          _isLoading = false;
        });
      }
    }
  }

  int _calculateReadinessScore() {
    int score = 70;

    if (_wearableSnapshot != null) {
      final sleepHours = _wearableSnapshot!['sleepHours'] as num?;
      if (sleepHours != null && sleepHours >= 7) {
        score += 10;
      }

      final hrv = _wearableSnapshot!['hrv'] as num?;
      if (hrv != null && hrv >= 50) {
        score += 10;
      }

      final rhr = _wearableSnapshot!['rhr'] as num?;
      if (rhr != null && rhr <= 65) {
        score += 5;
      }
    }

    if (_healthProfile != null) {
      final weight = _healthProfile!.weightKg;
      final height = _healthProfile!.heightCm;
      if (weight != null && height != null && weight > 0 && height > 0) {
        final heightM = height / 100;
        final bmi = weight / (heightM * heightM);
        if (bmi > 30) {
          score -= 5;
        }
      }
    }

    if (_memberIntelligence != null) {
      final lastRpe = _memberIntelligence!['lastSessionRPE'] as num?;
      if (lastRpe != null) {
        if (lastRpe <= 6) {
          score += 10;
        } else if (lastRpe >= 9) {
          score -= 20;
        }
      }
    }

    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Readiness')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.member.name} Readiness'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSnapshotCard(),
            const SizedBox(height: 16),
            _buildGoalProgressCard(),
            const SizedBox(height: 16),
            _buildMetricsCard(),
            const SizedBox(height: 16),
            _buildFlexibilityCard(),
            const SizedBox(height: 16),
            _buildTrainerForm(),
            const SizedBox(height: 32),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerForm() {
    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trainer Assessment',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Energy Level
            Text('Energy Level', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = _energyLevel == level;
                return GestureDetector(
                  onTap: () => setState(() => _energyLevel = level),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: isSelected ? AppColors.primary : AppColors.background,
                    child: Text(
                      level.toString(),
                      style: GoogleFonts.poppins(
                        color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Soreness
            Text('Muscle Soreness', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sorenessOptions.map((option) {
                final isSelected = _selectedSoreness.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (option == 'None') {
                        if (selected) {
                          _selectedSoreness.clear();
                          _selectedSoreness.add('None');
                        } else {
                          _selectedSoreness.remove('None');
                        }
                      } else {
                        _selectedSoreness.remove('None');
                        if (selected) {
                          _selectedSoreness.add(option);
                        } else {
                          _selectedSoreness.remove(option);
                        }
                      }
                    });
                  },
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.warning.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.warning,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.warning : AppColors.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Injury
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Injury/Pain?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                Switch(
                  value: _hasInjury,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _hasInjury = val),
                ),
              ],
            ),
            if (_hasInjury) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _injuryNotesController,
                decoration: InputDecoration(
                  hintText: 'Describe injury or modification needs',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 16),

            // Equipment Selection
            Text('Available Equipment', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Deselect any equipment currently unavailable/broken', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            if (_gymEquipment != null && _gymEquipment!.equipment.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gymEquipment!.equipment.map((eq) {
                  final isAvailable = _availableEquipment.contains(eq);
                  return FilterChip(
                    label: Text(eq),
                    selected: isAvailable,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _availableEquipment.add(eq);
                        } else {
                          _availableEquipment.remove(eq);
                        }
                      });
                    },
                    backgroundColor: AppColors.background,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isAvailable ? AppColors.primary : AppColors.textMuted,
                      decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  );
                }).toList(),
              )
            else
              Text('No equipment found for branch.', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _isSaving ? null : _startSession,
      child: _isSaving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: AppColors.textOnPrimary, strokeWidth: 2),
            )
          : Text(
              'START WARMUP & ANALYZE',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
    );
  }

  Future<void> _startSession() async {
    setState(() => _isSaving = true);
    try {
      final db = FirebaseFirestore.instance;
      final sessionRef = db.collection('trainingSessions').doc();

      await sessionRef.set({
        'sessionId': sessionRef.id,
        'trainerId': widget.user.uid,
        'memberId': widget.member.id,
        'memberAuthUid': widget.authUid,
        'status': 'warmup',
        'readinessScore': _calculateReadinessScore(),
        'date': FieldValue.serverTimestamp(),
        'preSessionAssessment': {
          'energyLevel': _energyLevel,
          'soreness': _selectedSoreness,
          'hasInjury': _hasInjury,
          'injuryNotes': _injuryNotesController.text.trim(),
          'availableEquipment': _availableEquipment,
        },
        'exercises': [],
        'plans': {},
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session started! Navigate to Warmup (Task 8)')),
      );
      Navigator.pop(context); // Temporarily pop since Task 8 isn't built yet
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start session: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildMetricsCard() {
    if (_bodyMetricsLogs.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = _bodyMetricsLogs.first;
    final double weight = latest['weight'] is num ? (latest['weight'] as num).toDouble() : 0.0;

    double bmi = 0.0;
    if (_healthProfile != null) {
      final height = _healthProfile!.heightCm;
      if (height != null && height > 0) {
        final heightM = height / 100;
        bmi = weight / (heightM * heightM);
      }
    }

    // Determine 4-week trend
    String trend = 'No trend data';
    IconData trendIcon = Icons.trending_flat;
    Color trendColor = AppColors.textSecondary;

    if (_bodyMetricsLogs.length > 1) {
      // Find oldest log within last 4 weeks (already ordered desc)
      final oldest = _bodyMetricsLogs.last;
      final oldestWeight = oldest['weight'] is num ? (oldest['weight'] as num).toDouble() : 0.0;

      if (oldestWeight > 0) {
        final diff = weight - oldestWeight;
        if (diff > 0) {
          trend = '+${diff.toStringAsFixed(1)} kg (4w)';
          trendIcon = Icons.trending_up;
          trendColor = AppColors.warning;
        } else if (diff < 0) {
          trend = '${diff.toStringAsFixed(1)} kg (4w)';
          trendIcon = Icons.trending_down;
          trendColor = AppColors.success;
        } else {
          trend = 'No change (4w)';
        }
      }
    }

    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Metrics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Weight', '${weight.toStringAsFixed(1)} kg', Icons.scale),
                _buildStatItem('BMI', bmi > 0 ? bmi.toStringAsFixed(1) : '-', Icons.accessibility_new),
                Column(
                  children: [
                    Icon(trendIcon, color: trendColor, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      trend,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                    Text(
                      'Trend',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibilityCard() {
    if (_memberIntelligence == null || _memberIntelligence!['latestFlexibilityScore'] == null) {
      return const SizedBox.shrink();
    }

    final score = _memberIntelligence!['latestFlexibilityScore'] as num;
    final List<dynamic> tightAreasRaw = _memberIntelligence!['tightAreas'] ?? [];
    final List<String> tightAreas = tightAreasRaw.map((e) => e.toString()).toList();

    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flexibility Profile',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Overall Score:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${score.round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: score >= 70 ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
            if (tightAreas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tight Areas:',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tightAreas.map((area) {
                  return Chip(
                    label: Text(area),
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.error, fontSize: 12),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotCard() {
    final int score = _calculateReadinessScore();
    Color scoreColor = AppColors.success;
    if (score < 50) {
      scoreColor = AppColors.error;
    } else if (score < 70) {
      scoreColor = AppColors.warning;
    }

    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.member.name,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${widget.age} yrs • ${_memberGoal?.primaryGoal ?? "No Goal Set"}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 2),
                  ),
                  child: Text(
                    score.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Sleep', '${_wearableSnapshot?['sleepHours'] ?? '-'}h', Icons.bedtime),
                _buildStatItem('HRV', '${_wearableSnapshot?['hrv'] ?? '-'}', Icons.favorite),
                _buildStatItem('RHR', '${_wearableSnapshot?['rhr'] ?? '-'}', Icons.monitor_heart),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  int _calculateDailyCaloricTarget() {
    if (_healthProfile == null) return 0;

    final weight = _healthProfile!.weightKg;
    final height = _healthProfile!.heightCm;
    if (weight == null || height == null || weight == 0 || height == 0) return 0;

    // Mifflin-St Jeor BMR: (10*w + 6.25*h - 5*a + 5/161)
    double bmr = (10 * weight) + (6.25 * height) - (5 * widget.age);
    if (widget.member.gender.toLowerCase() == 'male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    // TDEE multiplier based on weeklySessionTarget (default 3 if not set)
    int weeklySessions = 3;
    if (_memberGoal != null && _memberGoal!.targetMetric.containsKey('weeklySessionTarget')) {
      weeklySessions = _memberGoal!.targetMetric['weeklySessionTarget'] as int? ?? 3;
    }

    double multiplier;
    if (weeklySessions <= 2) {
      multiplier = 1.2;
    } else if (weeklySessions <= 4) {
      multiplier = 1.375;
    } else if (weeklySessions <= 6) {
      multiplier = 1.55;
    } else {
      multiplier = 1.725;
    }

    double tdee = bmr * multiplier;

    // Apply offset based on goal
    if (_memberGoal != null) {
      final goal = _memberGoal!.primaryGoal.toLowerCase();
      if (goal.contains('weight loss') || goal.contains('fat loss')) {
        tdee -= 500;
      } else if (goal.contains('muscle gain') || goal.contains('bulk')) {
        tdee += 300;
      }
    }

    return tdee.round();
  }

  Widget _buildGoalProgressCard() {
    if (_memberGoal == null) {
      return const SizedBox.shrink();
    }

    final targetDate = _memberGoal!.deadline;
    final joinDate = widget.member.joiningDate;

    final totalWeeks = targetDate.difference(joinDate).inDays / 7;
    final weeksPassed = DateTime.now().difference(joinDate).inDays / 7;
    final progress = totalWeeks > 0 ? (weeksPassed / totalWeeks).clamp(0.0, 1.0) : 0.0;
    final weeksRemaining = totalWeeks > 0 ? (totalWeeks - weeksPassed).clamp(0.0, 999.0).ceil() : 0;
    final caloricTarget = _calculateDailyCaloricTarget();

    return Card(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Progress',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$weeksRemaining weeks left',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (caloricTarget > 0)
                  Text(
                    '$caloricTarget kcal/day',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
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
