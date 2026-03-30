import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/member_model.dart';
import '../../theme/app_colors.dart';
import '../../services/trainer_ajax_service.dart';
import 'trainer_warmup_screen.dart';

class TrainerReadinessScreen extends StatefulWidget {
  final MemberModel member;
  final String trainerId;
  final Map<String, dynamic> sessionData;
  final Map<String, dynamic>? flexibilityData;

  const TrainerReadinessScreen({
    super.key,
    required this.member,
    required this.trainerId,
    required this.sessionData,
    this.flexibilityData,
  });

  @override
  State<TrainerReadinessScreen> createState() => _TrainerReadinessScreenState();
}

class _TrainerReadinessScreenState extends State<TrainerReadinessScreen> {
  final List<String> _sorenessOptions = [
    'Shoulders',
    'Chest',
    'Back',
    'Arms',
    'Core',
    'Legs',
    'Knees',
    'None'
  ];
  final Set<String> _selectedSoreness = {};
  int _energyLevel = 0;
  bool _hasInjury = false;
  final TextEditingController _injuryController = TextEditingController();

  List<String> _availableEquipment = [];
  final Set<String> _selectedEquipment = {};
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    final equipmentData = widget.sessionData['gymEquipment'] as Map<String, dynamic>?;
    if (equipmentData != null && equipmentData['equipment'] != null) {
      _availableEquipment = List<String>.from(equipmentData['equipment']);
      _selectedEquipment.addAll(_availableEquipment);
    }
  }

  @override
  void dispose() {
    _injuryController.dispose();
    super.dispose();
  }

  void _toggleSoreness(String option) {
    setState(() {
      if (option == 'None') {
        _selectedSoreness.clear();
        _selectedSoreness.add('None');
      } else {
        _selectedSoreness.remove('None');
        if (_selectedSoreness.contains(option)) {
          _selectedSoreness.remove(option);
        } else {
          _selectedSoreness.add(option);
        }
      }
    });
  }

  Future<void> _startWarmup() async {
    if (_energyLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set energy level.')),
      );
      return;
    }

    setState(() => _isStarting = true);

    try {
      final docRef = await FirebaseFirestore.instance.collection('trainingSessions').add({
        'trainerId': widget.trainerId,
        'memberId': widget.member.id,
        'memberAuthUid': widget.member.id,
        'memberName': widget.member.name,
        'memberAge': widget.sessionData['memberAge'] ?? 0,
        'branch': widget.member.branch,
        'date': Timestamp.now(),
        'isFirstSession': false,
        'status': 'analyzing',
        'readinessScore': widget.sessionData['readinessScore'],
        'trainerContext': {
          'soreness': _selectedSoreness.toList(),
          'energyLevel': _energyLevel,
          'hasInjury': _hasInjury,
          'injuryNote': _hasInjury ? _injuryController.text : null,
          'availableEquipment': _selectedEquipment.toList(),
        },
        'bodyMetricsContext': widget.sessionData['bodyMetricsData'],
        'goalContext': widget.sessionData['goalContext'],
        'flexibilityContext': widget.flexibilityData,
        'plans': {},
        'exercises': [],
        'activeExerciseIndex': 0,
        'warmupStartTime': Timestamp.now(),
      });

      // Call actual AjAX service
      await TrainerAjaxService.generateSessionPlans(
        sessionId: docRef.id,
        member: widget.member,
        memberAge: widget.sessionData['memberAge'] ?? 0,
        isFirstSession: false,
        trainerContext: {
          'soreness': _selectedSoreness.toList(),
          'energyLevel': _energyLevel,
          'hasInjury': _hasInjury,
          'injuryNote': _hasInjury ? _injuryController.text : null,
          'readinessScore': widget.sessionData['readinessScore'],
        },
        bodyMetricsContext: widget.sessionData['bodyMetricsData'] ?? {},
        goalContext: widget.sessionData['goalContext'],
        flexibilityContext: widget.flexibilityData,
        wearableData: widget.sessionData['wearableData'],
        lastSession: widget.sessionData['lastSessionData'],
        memberIntelligence: widget.sessionData['memberIntelligence'],
        availableEquipment: _selectedEquipment.toList(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerWarmupScreen(
            sessionId: docRef.id,
            member: widget.member,
            trainerId: widget.trainerId,
          ),
        ),
      );
    } catch (e) {
      setState(() => _isStarting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting session: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Session Prep: ${widget.member.name.split(' ').first}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMemberSnapshotCard(),
                const SizedBox(height: 12),
                if (widget.sessionData['goalContext'] != null) ...[
                  _buildGoalProgressCard(),
                  const SizedBox(height: 12),
                ],
                if (widget.sessionData['bodyMetricsData'] != null) ...[
                  _buildBodyMetricsCard(),
                  const SizedBox(height: 12),
                ],
                if (widget.flexibilityData != null) ...[
                  _buildFlexibilityCard(),
                  const SizedBox(height: 12),
                ],
                _buildTrainerInputForm(),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isStarting ? null : _startWarmup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isStarting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'START WARMUP + ANALYZE',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
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

  Widget _buildMemberSnapshotCard() {
    final score = widget.sessionData['readinessScore'] as int;
    final color = score < 40
        ? AppColors.error
        : score < 70
            ? AppColors.warning
            : AppColors.success;
    final age = widget.sessionData['memberAge'] ?? 0;
    final wearable = widget.sessionData['wearableData'] as Map<String, dynamic>? ?? {};
    final lastSession = widget.sessionData['lastSessionData'] as Map<String, dynamic>? ?? {};
    final goalCtx = widget.sessionData['goalContext'] as Map<String, dynamic>?;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.member.name}, $age',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (goalCtx != null)
                  Chip(
                    label: Text(
                      goalCtx['primaryGoal'] ?? 'Goal',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Readiness: $score/100',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: color.withValues(alpha: 0.2),
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sleep ${wearable['sleepHours'] ?? 'unknown'}h',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  'HRV ${wearable['hrv'] ?? 'unknown'}ms',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  'RHR ${wearable['restingHR'] ?? 'unknown'}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Last session: ${lastSession['exerciseName'] ?? 'none'} RPE ${lastSession['sessionRpe'] ?? '0'}/10',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success),
              ),
              child: const Text(
                'Attendance Marked',
                style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard() {
    final goalCtx = widget.sessionData['goalContext'] as Map<String, dynamic>;
    final weeksRemaining = goalCtx['weeksRemaining'] ?? 0;
    final currentVal = goalCtx['currentValue'] ?? 0;
    final targetVal = goalCtx['targetValue'] ?? 0;
    final currentPace = goalCtx['currentPace'] as String;
    // final rateNeeded = goalCtx['weeklyRateNeeded'] as num;
    final caloricTarget = widget.sessionData['caloricTarget'] as num?;

    double progress = 0.0;
    if (targetVal != currentVal) {
      progress = (currentVal / targetVal).clamp(0.0, 1.0);
    }

    String paceLabel = 'No data yet';
    Color paceColor = AppColors.textMuted;
    if (currentPace == 'on_track') {
      paceLabel = 'On Track';
      paceColor = AppColors.success;
    } else if (currentPace == 'ahead') {
      paceLabel = 'Ahead';
      paceColor = AppColors.primary;
    } else if (currentPace == 'behind') {
      paceLabel = 'Behind';
      paceColor = AppColors.warning;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal: ${goalCtx['primaryGoal']}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${currentVal.toStringAsFixed(1)} unit toward ${targetVal.toStringAsFixed(1)} unit',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$weeksRemaining weeks remaining',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: paceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: paceColor),
                  ),
                  child: Text(
                    paceLabel,
                    style: TextStyle(fontSize: 12, color: paceColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Weekly rate needed: ${(goalCtx["weeklyRateNeeded"] as num).toStringAsFixed(2)} unit/week',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              caloricTarget != null ? 'Daily caloric target: ${caloricTarget.toStringAsFixed(0)} kcal' : 'Caloric target: calculating...',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    final metrics = widget.sessionData['bodyMetricsData'] as Map<String, dynamic>;
    final weight = metrics['weightKg'] as num?;
    final bmi = metrics['bmi'] as num?;
    final bodyFat = metrics['bodyFatPercentage'] as num?;
    final entries = widget.sessionData['bodyMetricsEntries'] as List;

    String bmiCategory = 'Unknown';
    if (bmi != null) {
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
      } else {
        bmiCategory = 'Obese';
      }
    }

    String trendText = 'No trend data';
    if (entries.length >= 2) {
      final first = entries.first['weightKg'] as num? ?? 0;
      final last = entries.last['weightKg'] as num? ?? 0;
      final delta = first - last;
      final arrow = delta < 0 ? 'Down' : delta > 0 ? 'Up' : 'Stable';
      trendText = '$arrow ${delta.abs().toStringAsFixed(1)} kg in ${entries.length} check-ins';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 12),
            Text(
              'Weight: ${weight?.toStringAsFixed(1) ?? '?'} kg  BMI: ${bmi?.toStringAsFixed(1) ?? '?'} ($bmiCategory)',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Trend: $trendText',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Body fat: ${bodyFat?.toStringAsFixed(1) ?? 'not tracked'}%',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibilityCard() {
    final flex = widget.flexibilityData!;
    final score = flex['score'] ?? 0;
    final tightAreas = flex['tightAreas'] as List? ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flexibility',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Flexibility Score: $score/100',
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (tightAreas.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tightAreas.map<Widget>((area) {
                  return Chip(
                    label: Text(area.toString()),
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: AppColors.error, fontSize: 12),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            Text(
              'AjAX will add mobility work for tight areas.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerInputForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Before we start...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Soreness today?',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sorenessOptions.map((option) {
                final isSelected = _selectedSoreness.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) => _toggleSoreness(option),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Energy level?',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final val = index + 1;
                final isSelected = _energyLevel == val;
                return GestureDetector(
                  onTap: () => setState(() => _energyLevel = val),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      val.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Any injury today?',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                Switch(
                  value: _hasInjury,
                  onChanged: (val) => setState(() => _hasInjury = val),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
            if (_hasInjury) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _injuryController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Brief description (optional)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Equipment available today:',
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            if (_availableEquipment.isEmpty)
              Text(
                'No equipment list configured. Owner must set it up first.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableEquipment.map((item) {
                  final isSelected = _selectedEquipment.contains(item);
                  return FilterChip(
                    label: Text(item),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedEquipment.add(item);
                        } else {
                          _selectedEquipment.remove(item);
                        }
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.grey.shade600,
                      decoration: isSelected ? TextDecoration.none : TextDecoration.lineThrough,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}