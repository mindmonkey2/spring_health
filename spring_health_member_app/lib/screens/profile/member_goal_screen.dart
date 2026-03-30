import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MemberGoalScreen extends StatefulWidget {
  final String memberAuthUid;
  final String createdBy;

  const MemberGoalScreen({
    super.key,
    required this.memberAuthUid,
    this.createdBy = 'member',
  });

  @override
  State<MemberGoalScreen> createState() => _MemberGoalScreenState();
}

class _MemberGoalScreenState extends State<MemberGoalScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Primary Goal
  String? _selectedGoal;

  // Step 2: Target Metrics
  final TextEditingController _currentWeightCtrl = TextEditingController();
  final TextEditingController _targetWeightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  String? _selectedLift = 'Bench Press';
  final TextEditingController _currentMaxCtrl = TextEditingController();
  final TextEditingController _targetMaxCtrl = TextEditingController();
  final TextEditingController _targetDistanceCtrl = TextEditingController();
  String _distanceUnit = 'km';

  @override
  void dispose() {
    _pageController.dispose();
    _currentWeightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _heightCtrl.dispose();
    _currentMaxCtrl.dispose();
    _targetMaxCtrl.dispose();
    _targetDistanceCtrl.dispose();
    super.dispose();
  }

  // Step 3: Deadline + Sessions
  int? _selectedWeeks;
  DateTime? _customDeadline;
  int _sessionsPerWeek = 3;

  final List<Map<String, dynamic>> _goalTypes = [
    {'id': 'weight_loss', 'label': 'Weight Loss', 'icon': Icons.monitor_weight_outlined},
    {'id': 'muscle_gain', 'label': 'Muscle Gain', 'icon': Icons.fitness_center},
    {'id': 'strength', 'label': 'Strength', 'icon': Icons.bolt},
    {'id': 'endurance', 'label': 'Endurance', 'icon': Icons.directions_run},
    {'id': 'flexibility', 'label': 'Flexibility', 'icon': Icons.self_improvement},
    {'id': 'general_fitness', 'label': 'General Fitness', 'icon': Icons.favorite_outline},
  ];

  final List<String> _lifts = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Overhead Press',
    'Pull-ups'
  ];

  void _nextStep() {
    if (_currentStep == 0 && _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a goal')),
      );
      return;
    }

    if (_currentStep == 1) {
      if ((_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') &&
          (_currentWeightCtrl.text.isEmpty || _targetWeightCtrl.text.isEmpty || _heightCtrl.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }
      if (_selectedGoal == 'strength' &&
          (_currentMaxCtrl.text.isEmpty || _targetMaxCtrl.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }
      if (_selectedGoal == 'endurance' && _targetDistanceCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }
    }

    if (_currentStep == 2 && _selectedWeeks == null && _customDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _selectCustomDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonLime,
              onPrimary: AppColors.backgroundBlack,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.surfaceDark),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _customDeadline = picked;
        _selectedWeeks = null;
      });
    }
  }

  Future<void> _saveGoal() async {
    try {
      double startValue = 0;
      double targetValue = 0;
      String unit = '';
      String goalType = _selectedGoal ?? '';

      if (goalType == 'weight_loss' || goalType == 'muscle_gain') {
        startValue = double.tryParse(_currentWeightCtrl.text) ?? 0;
        targetValue = double.tryParse(_targetWeightCtrl.text) ?? 0;
        unit = 'kg';
      } else if (goalType == 'strength') {
        startValue = double.tryParse(_currentMaxCtrl.text) ?? 0;
        targetValue = double.tryParse(_targetMaxCtrl.text) ?? 0;
        unit = 'kg';
      } else if (goalType == 'endurance') {
        startValue = 0; // Assume 0 as starting for distance target
        targetValue = double.tryParse(_targetDistanceCtrl.text) ?? 0;
        unit = _distanceUnit;
      } else {
        startValue = 0;
        targetValue = 100; // Arbitrary 100% completion
        unit = '%';
      }

      int totalWeeks = 0;
      DateTime deadline;
      if (_selectedWeeks != null) {
        totalWeeks = _selectedWeeks!;
        deadline = DateTime.now().add(Duration(days: totalWeeks * 7));
      } else if (_customDeadline != null) {
        deadline = _customDeadline!;
        totalWeeks = deadline.difference(DateTime.now()).inDays ~/ 7;
        if (totalWeeks < 1) totalWeeks = 1;
      } else {
        totalWeeks = 12;
        deadline = DateTime.now().add(const Duration(days: 12 * 7));
      }

      List<Map<String, dynamic>> milestones = [];
      for (int i = 1; i <= 4; i++) {
        int weekNumber = ((totalWeeks / 4) * i).round();
        double targetVal = startValue + (targetValue - startValue) * 0.25 * i;
        milestones.add({
          'weekNumber': weekNumber,
          'targetValue': targetVal,
          'achieved': false,
          'achievedAt': null,
        });
      }

      final docData = {
        'goalType': goalType,
        'startValue': startValue,
        'currentValue': startValue,
        'targetValue': targetValue,
        'unit': unit,
        'deadline': Timestamp.fromDate(deadline),
        'sessionsPerWeek': _sessionsPerWeek,
        'createdBy': widget.createdBy,
        'updatedAt': Timestamp.now(),
        'startDate': Timestamp.now(),
        'milestones': milestones,
        'isActive': true,
      };

      if (goalType == 'weight_loss' || goalType == 'muscle_gain') {
        docData['heightCm'] = double.tryParse(_heightCtrl.text) ?? 0.0;
      } else if (goalType == 'strength') {
        docData['lift'] = _selectedLift ?? '';
      }

      await FirebaseFirestore.instance
          .collection('memberGoals')
          .doc(widget.memberAuthUid)
          .set(docData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal set! AjAX will chase this with you every session.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving goal: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _prevStep,
        ),
        title: Text('Goal Setup', style: AppTextStyles.heading3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.neonLime : AppColors.gray800,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What is your main goal?', style: AppTextStyles.heading2),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _goalTypes.length,
              itemBuilder: (context, index) {
                final goal = _goalTypes[index];
                final isSelected = _selectedGoal == goal['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGoal = goal['id'];
                    });
                    Future.delayed(const Duration(milliseconds: 300), _nextStep);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.neonLime.withValues(alpha: 0.12) : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.neonLime : AppColors.gray800,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          goal['icon'] as IconData,
                          size: 40,
                          color: isSelected ? AppColors.neonLime : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          goal['label'] as String,
                          style: TextStyle(
                            color: isSelected ? AppColors.neonLime : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
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

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Metrics', style: AppTextStyles.heading2),
          const SizedBox(height: 32),
          if (_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') ...[
            _buildTextField('Current weight (kg)', _currentWeightCtrl),
            const SizedBox(height: 16),
            _buildTextField('Target weight (kg)', _targetWeightCtrl),
            const SizedBox(height: 16),
            _buildTextField('Your height (cm)', _heightCtrl),
          ] else if (_selectedGoal == 'strength') ...[
            Text('Which lift?', style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gray800),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLift,
                  isExpanded: true,
                  dropdownColor: AppColors.surfaceDark,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.neonLime),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedLift = newValue!;
                    });
                  },
                  items: _lifts.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField('Current max (kg)', _currentMaxCtrl),
            const SizedBox(height: 16),
            _buildTextField('Target max (kg)', _targetMaxCtrl),
          ] else if (_selectedGoal == 'endurance') ...[
            _buildTextField('Target distance', _targetDistanceCtrl),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildUnitChip('km'),
                const SizedBox(width: 12),
                _buildUnitChip('miles'),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No specific metric needed. AjAX will track your sessions and progress.',
                      style: const TextStyle(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonLime),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
      ),
    );
  }

  Widget _buildUnitChip(String unit) {
    final isSelected = _distanceUnit == unit;
    return GestureDetector(
      onTap: () {
        setState(() {
          _distanceUnit = unit;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonLime : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonLime : AppColors.gray800,
          ),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? AppColors.backgroundBlack : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    final options = [4, 8, 12, 24]; // 24 = 6 months
    final optionLabels = ['4 weeks', '8 weeks', '12 weeks', '6 months'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achieve by:', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...List.generate(options.length, (index) {
                final weeks = options[index];
                final isSelected = _selectedWeeks == weeks && _customDeadline == null;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedWeeks = weeks;
                      _customDeadline = null;
                    });
                  },
                  child: Chip(
                    label: Text(
                      optionLabels[index],
                      style: TextStyle(
                        color: isSelected ? AppColors.backgroundBlack : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: isSelected ? AppColors.neonLime : AppColors.surfaceDark,
                    side: BorderSide(
                      color: isSelected ? AppColors.neonLime : AppColors.gray800,
                    ),
                  ),
                );
              }),
              GestureDetector(
                onTap: _selectCustomDate,
                child: Chip(
                  label: Text(
                    _customDeadline != null
                        ? DateFormat('MMM d, yyyy').format(_customDeadline!)
                        : 'Custom date',
                    style: TextStyle(
                      color: _customDeadline != null ? AppColors.backgroundBlack : AppColors.textPrimary,
                      fontWeight: _customDeadline != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: _customDeadline != null ? AppColors.neonLime : AppColors.surfaceDark,
                  side: BorderSide(
                    color: _customDeadline != null ? AppColors.neonLime : AppColors.gray800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text('Sessions per week:', style: AppTextStyles.heading2),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [2, 3, 4, 5, 6].map((int count) {
              final isSelected = _sessionsPerWeek == count;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _sessionsPerWeek = count;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.neonLime : AppColors.surfaceDark,
                    border: Border.all(
                      color: isSelected ? AppColors.neonLime : AppColors.gray800,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: isSelected ? AppColors.backgroundBlack : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    String goalName = _goalTypes.firstWhere((g) => g['id'] == _selectedGoal)['label'];

    double start = 0;
    double target = 0;
    String unit = '';

    if (_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') {
      start = double.tryParse(_currentWeightCtrl.text) ?? 0;
      target = double.tryParse(_targetWeightCtrl.text) ?? 0;
      unit = 'kg';
    } else if (_selectedGoal == 'strength') {
      start = double.tryParse(_currentMaxCtrl.text) ?? 0;
      target = double.tryParse(_targetMaxCtrl.text) ?? 0;
      unit = 'kg';
    } else if (_selectedGoal == 'endurance') {
      target = double.tryParse(_targetDistanceCtrl.text) ?? 0;
      unit = _distanceUnit;
    }

    int weeks = 12;
    DateTime deadline = DateTime.now().add(const Duration(days: 12 * 7));
    if (_selectedWeeks != null) {
      weeks = _selectedWeeks!;
      deadline = DateTime.now().add(Duration(days: weeks * 7));
    } else if (_customDeadline != null) {
      deadline = _customDeadline!;
      weeks = deadline.difference(DateTime.now()).inDays ~/ 7;
      if (weeks < 1) weeks = 1;
    }

    String rateStr = '';
    if (weeks > 0 && (_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain' || _selectedGoal == 'strength')) {
      double diff = (target - start).abs();
      double rate = diff / weeks;
      String action = target > start ? 'Gain' : 'Lose';
      if (_selectedGoal == 'strength') action = 'Increase';
      rateStr = '$action ${rate.toStringAsFixed(1)} $unit per week';
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review + Confirm', style: AppTextStyles.heading2),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.neonTeal, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Goal', goalName),
                const Divider(color: AppColors.gray800, height: 32),
                if (_selectedGoal != 'flexibility' && _selectedGoal != 'general_fitness') ...[
                  if (_selectedGoal == 'strength') _buildSummaryRow('Lift', _selectedLift ?? ''),
                  _buildSummaryRow('Target', '$start to $target $unit'),
                  const Divider(color: AppColors.gray800, height: 32),
                ],
                _buildSummaryRow('Deadline', '${DateFormat('MMM d, yyyy').format(deadline)} ($weeks weeks)'),
                const Divider(color: AppColors.gray800, height: 32),
                _buildSummaryRow('Sessions', '$_sessionsPerWeek per week'),
                if (rateStr.isNotEmpty) ...[
                  const Divider(color: AppColors.gray800, height: 32),
                  _buildSummaryRow('Pace', rateStr),
                ]
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: AppColors.backgroundBlack,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'SET MY GOAL',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.gray800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Next', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
