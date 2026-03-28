import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../models/member_model.dart';
import '../../models/member_goal_model.dart';

class MemberGoalScreen extends StatefulWidget {
  final MemberModel member;

  const MemberGoalScreen({super.key, required this.member});

  @override
  State<MemberGoalScreen> createState() => _MemberGoalScreenState();
}

class _MemberGoalScreenState extends State<MemberGoalScreen> {
  int _currentStep = 0;

  // Step 1: Goal
  final List<String> _primaryGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Strength',
    'Endurance',
    'Flexibility',
    'General Fitness'
  ];
  String? _selectedGoal;

  // Step 2: Target
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final TextEditingController _currentMaxController = TextEditingController();
  final TextEditingController _targetMaxController = TextEditingController();
  String _selectedLift = 'Bench Press';
  final List<String> _lifts = ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press'];

  final TextEditingController _distanceController = TextEditingController();

  // Step 3: Deadline
  final List<String> _deadlines = ['4 weeks', '8 weeks', '12 weeks', '6 months'];
  String? _selectedDeadline;
  int _weeklySessions = 3;

  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _currentMaxController.dispose();
    _targetMaxController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal')),
      );
      return;
    }
    if (_currentStep == 1) {
      if (_selectedGoal == 'Weight Loss' || _selectedGoal == 'Muscle Gain') {
        if (_weightController.text.isEmpty || _heightController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter height and target weight')),
          );
          return;
        }
      } else if (_selectedGoal == 'Strength') {
        if (_currentMaxController.text.isEmpty || _targetMaxController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter current and target max')),
          );
          return;
        }
      } else if (_selectedGoal == 'Endurance') {
        if (_distanceController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a target distance')),
          );
          return;
        }
      }
    }
    if (_currentStep == 2 && _selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      _saveGoal();
    }
  }

  // void _prevStep() {
  //   if (_currentStep > 0) {
  //     setState(() => _currentStep--);
  //   } else {
  //     Navigator.pop(context);
  //   }
  // }

  Future<void> _saveGoal() async {
    setState(() => _isSaving = true);
    try {
      final targetMetric = <String, dynamic>{};
      double? heightCm;

      if (_selectedGoal == 'Weight Loss' || _selectedGoal == 'Muscle Gain') {
        targetMetric['targetWeight'] = double.parse(_weightController.text);
        heightCm = double.parse(_heightController.text);
      } else if (_selectedGoal == 'Strength') {
        targetMetric['lift'] = _selectedLift;
        targetMetric['currentMax'] = double.parse(_currentMaxController.text);
        targetMetric['targetMax'] = double.parse(_targetMaxController.text);
      } else if (_selectedGoal == 'Endurance') {
        targetMetric['targetDistance'] = double.parse(_distanceController.text);
      }

      int weeks = 4;
      if (_selectedDeadline == '8 weeks') weeks = 8;
      if (_selectedDeadline == '12 weeks') weeks = 12;
      if (_selectedDeadline == '6 months') weeks = 24;

      final deadline = DateTime.now().add(Duration(days: weeks * 7));

      final List<Map<String, dynamic>> milestones = [];
      if (_selectedGoal == 'Weight Loss' || _selectedGoal == 'Muscle Gain') {
        milestones.addAll([
          {'title': '25% to Target Weight', 'completed': false},
          {'title': '50% to Target Weight', 'completed': false},
          {'title': '75% to Target Weight', 'completed': false},
          {'title': 'Goal Reached!', 'completed': false},
        ]);
      } else if (_selectedGoal == 'Strength') {
        milestones.addAll([
          {'title': '25% Increase in $_selectedLift', 'completed': false},
          {'title': '50% Increase in $_selectedLift', 'completed': false},
          {'title': '75% Increase in $_selectedLift', 'completed': false},
          {'title': 'Hit Target Max in $_selectedLift', 'completed': false},
        ]);
      } else if (_selectedGoal == 'Endurance') {
        milestones.addAll([
          {'title': '25% of Target Distance', 'completed': false},
          {'title': '50% of Target Distance', 'completed': false},
          {'title': '75% of Target Distance', 'completed': false},
          {'title': 'Hit Target Distance', 'completed': false},
        ]);
      } else {
        milestones.addAll([
          {'title': 'Consistent for ${weeks ~/ 4} weeks', 'completed': false},
          {'title': 'Consistent for ${weeks ~/ 2} weeks', 'completed': false},
          {'title': 'Consistent for ${(weeks * 3) ~/ 4} weeks', 'completed': false},
          {'title': 'Goal Reached!', 'completed': false},
        ]);
      }

      final authUid = widget.member.id; // user_id is the auth UID

      final model = MemberGoalModel(
        id: authUid,
        primaryGoal: _selectedGoal!,
        targetMetric: targetMetric,
        heightCm: heightCm,
        deadline: deadline,
        milestones: milestones,
        currentPace: 'On track',
        createdBy: 'Trainer',
      );

      await FirebaseFirestore.instance
          .collection('memberGoals')
          .doc(authUid)
          .set(model.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Goal saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving goal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Set Goal: ${widget.member.name}',
          style: GoogleFonts.poppins(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentStep == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentStep == index ? AppColors.success : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepWidget(),
              ),
            ),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentStep == 3 ? 'CONFIRM & SAVE' : 'CONTINUE',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      default: return const SizedBox();
    }
  }

  Widget _buildStep2() {
    return Padding(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Define Target', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Set specific, measurable targets.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          if (_selectedGoal == 'Weight Loss' || _selectedGoal == 'Muscle Gain') ...[
            _buildTextField('Target Weight (kg)', _weightController, TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField('Height (cm)', _heightController, TextInputType.number),
          ] else if (_selectedGoal == 'Strength') ...[
            Text('Select Lift', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLift,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.success),
                  items: _lifts.map((lift) => DropdownMenuItem(value: lift, child: Text(lift))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedLift = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField('Current Max (kg)', _currentMaxController, TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Target Max (kg)', _targetMaxController, TextInputType.number)),
              ],
            ),
          ] else if (_selectedGoal == 'Endurance') ...[
            _buildTextField('Target Distance (km)', _distanceController, TextInputType.number),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text('No specific metrics needed for this goal.', style: GoogleFonts.inter(color: AppColors.textSecondary)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Padding(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Timeline & Effort', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('When should they achieve this?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          Text('Deadline', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _deadlines.map((deadline) {
              final isSelected = _selectedDeadline == deadline;
              return ChoiceChip(
                label: Text(deadline, style: GoogleFonts.inter(color: isSelected ? Colors.white : AppColors.textPrimary)),
                selected: isSelected,
                selectedColor: AppColors.success,
                backgroundColor: Colors.white,
                onSelected: (val) => setState(() => _selectedDeadline = deadline),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Text('Weekly Sessions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2', style: GoogleFonts.inter(fontSize: 14)),
              Expanded(
                child: Slider(
                  value: _weeklySessions.toDouble(),
                  min: 2,
                  max: 6,
                  divisions: 4,
                  activeColor: AppColors.success,
                  inactiveColor: AppColors.divider,
                  label: _weeklySessions.toString(),
                  onChanged: (val) => setState(() => _weeklySessions = val.toInt()),
                ),
              ),
              Text('6', style: GoogleFonts.inter(fontSize: 14)),
            ],
          ),
          Center(child: Text('$_weeklySessions sessions / week', style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    String rateText = 'Stay consistent and follow the plan.';
    if (_selectedGoal == 'Weight Loss' || _selectedGoal == 'Muscle Gain') {
      rateText = 'Requires strict nutrition tracking and consistency.';
    } else if (_selectedGoal == 'Strength') {
      rateText = 'Requires progressive overload and adequate recovery.';
    } else if (_selectedGoal == 'Endurance') {
      rateText = 'Requires gradual distance increases each week.';
    }

    return Padding(
      key: const ValueKey('step4'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Plan', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Verify details before setting milestones.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Primary Goal', _selectedGoal!),
                const Divider(color: AppColors.divider, height: 24),
                if (_selectedGoal == 'Weight Loss' || _selectedGoal == 'Muscle Gain') ...[
                  _buildSummaryRow('Target Weight', '${_weightController.text} kg'),
                  const SizedBox(height: 8),
                ] else if (_selectedGoal == 'Strength') ...[
                  _buildSummaryRow('Target Lift', _selectedLift),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Target Max', '${_targetMaxController.text} kg'),
                  const SizedBox(height: 8),
                ] else if (_selectedGoal == 'Endurance') ...[
                  _buildSummaryRow('Distance', '${_distanceController.text} km'),
                  const SizedBox(height: 8),
                ],
                _buildSummaryRow('Deadline', _selectedDeadline ?? 'Not set'),
                const SizedBox(height: 8),
                _buildSummaryRow('Weekly Effort', '$_weeklySessions sessions/week'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Weekly rate needed: $rateText',
                  style: GoogleFonts.inter(color: AppColors.success, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppColors.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.success),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Primary Focus', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Select the main goal for this member.', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _primaryGoals.length,
              itemBuilder: (context, index) {
                final goal = _primaryGoals[index];
                final isSelected = _selectedGoal == goal;

                IconData icon;
                switch (goal) {
                  case 'Weight Loss': icon = Icons.monitor_weight_outlined; break;
                  case 'Muscle Gain': icon = Icons.fitness_center; break;
                  case 'Strength': icon = Icons.sports_gymnastics; break;
                  case 'Endurance': icon = Icons.directions_run; break;
                  case 'Flexibility': icon = Icons.self_improvement; break;
                  default: icon = Icons.favorite_outline; break;
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedGoal = goal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.success.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.success : AppColors.divider,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(color: AppColors.success.withValues(alpha: 0.1), blurRadius: 12, spreadRadius: 2)
                      ] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 40, color: isSelected ? AppColors.success : AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          goal,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: isSelected ? AppColors.success : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
