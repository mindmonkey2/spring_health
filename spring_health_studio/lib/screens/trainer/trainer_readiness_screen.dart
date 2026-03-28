import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'trainer_warmup_screen.dart';

class TrainerReadinessScreen extends StatefulWidget {
  final Map<String, dynamic> contextData;
  final String trainerId;

  const TrainerReadinessScreen({
    super.key,
    required this.contextData,
    required this.trainerId,
  });

  @override
  State<TrainerReadinessScreen> createState() => _TrainerReadinessScreenState();
}

class _TrainerReadinessScreenState extends State<TrainerReadinessScreen> {
  final List<String> _sorenessOptions = ['Shoulders', 'Chest', 'Back', 'Arms', 'Core', 'Legs', 'Knees', 'None'];
  final Set<String> _selectedSoreness = {};
  int _energyLevel = 3;
  bool _hasInjury = false;
  final TextEditingController _injuryNotesController = TextEditingController();
  List<String> _availableEquipment = [];
  final Set<String> _deselectedEquipment = {};

  @override
  void initState() {
    super.initState();
    final equipment = widget.contextData['gymEquipment'] as List<dynamic>? ?? [];
    _availableEquipment = equipment.map((e) => e.toString()).toList();
  }

  @override
  void dispose() {
    _injuryNotesController.dispose();
    super.dispose();
  }

  void _onSorenessSelected(String option, bool selected) {
    setState(() {
      if (option == 'None') {
        if (selected) {
          _selectedSoreness.clear();
          _selectedSoreness.add('None');
        } else {
          _selectedSoreness.remove('None');
        }
      } else {
        if (selected) {
          _selectedSoreness.remove('None');
          _selectedSoreness.add(option);
        } else {
          _selectedSoreness.remove(option);
        }
      }
    });
  }

  void _onEquipmentTap(String item) {
    setState(() {
      if (_deselectedEquipment.contains(item)) {
        _deselectedEquipment.remove(item);
      } else {
        _deselectedEquipment.add(item);
      }
    });
  }

  void _startWarmup() {
    // Navigate to TrainerWarmupScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TrainerWarmupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Session Readiness',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
            _buildBodyMetricsCard(),
            const SizedBox(height: 16),
            if (widget.contextData['flexibilityData'] != null) ...[
              _buildFlexibilityCard(),
              const SizedBox(height: 16),
            ],
            _buildTrainerInputForm(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _startWarmup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Start Warmup + Analyze',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotCard() {
    final double score = widget.contextData['readinessScore'] ?? 70.0;
    Color scoreColor = AppColors.success;
    if (score < 40) {
      scoreColor = AppColors.error;
    } else if (score < 70) {
      scoreColor = AppColors.warning;
    }

    final wearableData = widget.contextData['wearableData'] as Map<String, dynamic>?;
    final sleepMins = wearableData?['sleepMinutes'] ?? 0;
    final sleepStr = '${sleepMins ~/ 60}h ${sleepMins % 60}m';
    final hrv = wearableData?['hrv'] ?? '-';
    final rhr = wearableData?['restingHeartRate'] ?? '-';

    final lastSession = widget.contextData['lastSessionData'] as Map<String, dynamic>?;
    final lastRpe = lastSession?['rpe'] ?? '-';

    final alreadyCheckedIn = widget.contextData['alreadyCheckedIn'] == true;

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contextData['memberName'] ?? 'Member',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Age: ${widget.contextData['age'] ?? '-'}',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (alreadyCheckedIn)
                  const Icon(Icons.check_circle, color: AppColors.success, size: 28)
                else
                  const Icon(Icons.check_circle_outline, color: AppColors.textSecondary, size: 28),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.flag, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Goal: ${widget.contextData['goalsData']?['primaryGoal']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'NONE'}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Readiness Score: ${score.toStringAsFixed(0)}',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: AppColors.background,
              color: scoreColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('Sleep', sleepStr),
                _buildStatColumn('HRV', '$hrv'),
                _buildStatColumn('RHR', '$rhr'),
                _buildStatColumn('Last RPE', '$lastRpe'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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

  Widget _buildGoalProgressCard() {
    final goalsData = widget.contextData['goalsData'] as Map<String, dynamic>?;
    if (goalsData == null) return const SizedBox.shrink();

    final primaryGoal = goalsData['primaryGoal']?.toString().replaceAll('_', ' ') ?? 'None';
    final targetValue = goalsData['targetValue'] ?? 0.0;

    final latestMetrics = widget.contextData['latestMetrics'] as Map<String, dynamic>?;
    final currentWeight = latestMetrics?['weight'] ?? 0.0;
    final startWeight = goalsData['startValue'] ?? currentWeight;

    double progress = 0.0;
    if (startWeight != targetValue) {
      if (primaryGoal.contains('weight loss')) {
        progress = (startWeight - currentWeight) / (startWeight - targetValue);
      } else {
        progress = (currentWeight - startWeight) / (targetValue - startWeight);
      }
    }
    progress = progress.clamp(0.0, 1.0);

    final paceStatus = widget.contextData['paceStatus'] ?? 'not_started';
    IconData paceIcon = Icons.remove;
    Color paceColor = AppColors.textSecondary;
    String paceText = 'Not Started';

    if (paceStatus == 'on_track') {
      paceIcon = Icons.check;
      paceColor = AppColors.success;
      paceText = 'On Track';
    } else if (paceStatus == 'ahead') {
      paceIcon = Icons.arrow_upward;
      paceColor = AppColors.primary;
      paceText = 'Ahead of Pace';
    } else if (paceStatus == 'behind') {
      paceIcon = Icons.warning_amber;
      paceColor = AppColors.warning;
      paceText = 'Behind Pace';
    }

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currentWeight.toStringAsFixed(1)} kg -> ${targetValue.toStringAsFixed(1)} kg',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${widget.contextData['weeksRemaining'] ?? 0} weeks left',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(paceIcon, color: paceColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  paceText,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: paceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Target Rate: ${widget.contextData['weeklyRateNeeded']?.toStringAsFixed(2) ?? '0'} kg/wk',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            Text(
              'Daily Caloric Target: ${widget.contextData['caloricTarget']?.toStringAsFixed(0) ?? '0'} kcal',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    final latestMetrics = widget.contextData['latestMetrics'] as Map<String, dynamic>?;
    if (latestMetrics == null) return const SizedBox.shrink();

    final weight = latestMetrics['weight'] ?? 0.0;
    final bmi = latestMetrics['bmi'] ?? 0.0;
    final bodyFat = latestMetrics['bodyFatPercentage'];

    final metricsList = widget.contextData['metricsDataList'] as List<dynamic>? ?? [];
    IconData trendIcon = Icons.remove;
    Color trendColor = AppColors.textSecondary;
    if (metricsList.length > 1) {
      final oldWeight = metricsList.last['weight'] ?? weight;
      if (weight < oldWeight) {
        trendIcon = Icons.arrow_downward;
        trendColor = AppColors.success;
      } else if (weight > oldWeight) {
        trendIcon = Icons.arrow_upward;
        trendColor = AppColors.error; // Assuming weight gain is bad contextually, could adjust based on goal
      }
    }

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Metrics (Latest)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    Row(
                      children: [
                        Text('${weight.toStringAsFixed(1)} kg', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(width: 4),
                        Icon(trendIcon, color: trendColor, size: 16),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BMI', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    Text('${bmi.toStringAsFixed(1)}', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
                if (bodyFat != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Body Fat', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                      Text('${bodyFat.toStringAsFixed(1)}%', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16)),
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
    final flexData = widget.contextData['flexibilityData'] as Map<String, dynamic>;
    final score = flexData['overallScore'] ?? 0;
    final tightAreasRaw = flexData['tightAreas'] as List<dynamic>? ?? [];
    final tightAreas = tightAreasRaw.map((e) => e.toString()).toList();

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flexibility Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '$score/100',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'AjAX will add mobility work',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            if (tightAreas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: tightAreas.map((area) {
                  return Chip(
                    label: Text(area),
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    labelStyle: GoogleFonts.inter(color: AppColors.error),
                    side: const BorderSide(color: AppColors.error),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerInputForm() {
    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trainer Input',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Soreness
            Text('Soreness', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sorenessOptions.map((option) {
                final isSelected = _selectedSoreness.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (val) => _onSorenessSelected(option, val),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Energy Level
            Text('Energy Level (1-5)', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final level = index + 1;
                final isSelected = _energyLevel == level;
                return GestureDetector(
                  onTap: () => setState(() => _energyLevel = level),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : AppColors.background,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Injury
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Injury?', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
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
                controller: _injuryNotesController,
                decoration: InputDecoration(
                  hintText: 'Describe injury...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
            ],
            const SizedBox(height: 24),

            // Equipment
            if (_availableEquipment.isNotEmpty) ...[
              Text('Available Equipment (Tap to mark unavailable)', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableEquipment.map((item) {
                  final isDeselected = _deselectedEquipment.contains(item);
                  return GestureDetector(
                    onTap: () => _onEquipmentTap(item),
                    child: Chip(
                      label: Text(
                        item,
                        style: TextStyle(
                          decoration: isDeselected ? TextDecoration.lineThrough : null,
                          color: isDeselected ? AppColors.textSecondary : AppColors.textPrimary,
                        ),
                      ),
                      backgroundColor: isDeselected ? AppColors.background : AppColors.surface,
                      side: BorderSide(
                        color: isDeselected ? AppColors.divider : AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
