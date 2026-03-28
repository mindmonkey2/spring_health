import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../models/member_goal_model.dart';
import '../../services/member_goal_service.dart';

class TrainerSetGoalScreen extends StatefulWidget {
  final String memberAuthUid;
  final String memberName;

  const TrainerSetGoalScreen({
    super.key,
    required this.memberAuthUid,
    required this.memberName,
  });

  @override
  State<TrainerSetGoalScreen> createState() => _TrainerSetGoalScreenState();
}

class _TrainerSetGoalScreenState extends State<TrainerSetGoalScreen> {
  final _goalService = MemberGoalService();
  final _pageController = PageController();
  int _currentStep = 0;

  // State Step 1
  String? _selectedGoal;

  // State Step 2
  final _currentWeightCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  final _currentMaxCtrl = TextEditingController();
  final _targetMaxCtrl = TextEditingController();
  String _selectedLift = 'Bench Press';
  final _lifts = ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Pull-ups'];

  final _targetDistanceCtrl = TextEditingController();
  String _selectedUnit = 'km';

  // State Step 3
  int _deadlineWeeks = 4;
  int _sessionsPerWeek = 3;

  bool _isSaving = false;

  void _nextStep() {
    if (_currentStep == 0 && _selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a primary focus')),
      );
      return;
    }

    if (_currentStep == 1) {
      if ((_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') &&
          (_currentWeightCtrl.text.isEmpty || _targetWeightCtrl.text.isEmpty || _heightCtrl.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all metrics')),
        );
        return;
      }
      if (_selectedGoal == 'strength' && (_currentMaxCtrl.text.isEmpty || _targetMaxCtrl.text.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter current and target max')),
        );
        return;
      }
      if (_selectedGoal == 'endurance' && _targetDistanceCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a target distance')),
        );
        return;
      }
    }

    if (_currentStep == 0 && (_selectedGoal == 'flexibility' || _selectedGoal == 'general_fitness')) {
      _pageController.animateToPage(2, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep = 2);
      return;
    }

    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep++);
  }

  void _prevStep() {
    if (_currentStep == 2 && (_selectedGoal == 'flexibility' || _selectedGoal == 'general_fitness')) {
      _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep = 0);
      return;
    }

    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep--);
  }

  Future<void> _saveGoal() async {
    setState(() => _isSaving = true);

    try {
      double? currentVal;
      double? targetVal;
      double? heightVal;
      String? metric;
      String? unit;
      String? lift;

      if (_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') {
        currentVal = double.tryParse(_currentWeightCtrl.text);
        targetVal = double.tryParse(_targetWeightCtrl.text);
        heightVal = double.tryParse(_heightCtrl.text);
        metric = 'weight';
        unit = 'kg';
      } else if (_selectedGoal == 'strength') {
        currentVal = double.tryParse(_currentMaxCtrl.text);
        targetVal = double.tryParse(_targetMaxCtrl.text);
        lift = _selectedLift;
        metric = 'max_lift';
        unit = 'kg';
      } else if (_selectedGoal == 'endurance') {
        targetVal = double.tryParse(_targetDistanceCtrl.text);
        metric = 'distance';
        unit = _selectedUnit;
      }

      final now = DateTime.now();
      final deadline = now.add(Duration(days: _deadlineWeeks * 7));

      List<double> milestones = [];
      if (currentVal != null && targetVal != null) {
        final step = (targetVal - currentVal) / 4;
        for (int i = 1; i <= 4; i++) {
          milestones.add(currentVal + (step * i));
        }
      }

      final goal = MemberGoalModel(
        id: '', // Firestore auto ID not needed for doc since we use authUid
        authUid: widget.memberAuthUid,
        goalType: _selectedGoal!,
        targetMetric: metric,
        targetUnit: unit,
        liftType: lift,
        currentValue: currentVal,
        targetValue: targetVal,
        heightCm: heightVal,
        deadline: deadline,
        sessionsPerWeek: _sessionsPerWeek,
        milestones: milestones,
        createdBy: 'trainer',
        createdAt: now,
      );

      await _goalService.setGoal(goal);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Trainer Goal assigned successfully.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'SET GOAL: ${widget.memberName.toUpperCase()}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
          onPressed: () {
            if (_currentStep > 0) {
              _prevStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
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

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Primary Focus',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the main goal for this member.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.9,
            children: [
              _buildGoalCard('Weight Loss', 'weight_loss', Icons.trending_down_rounded),
              _buildGoalCard('Muscle Gain', 'muscle_gain', Icons.fitness_center_rounded),
              _buildGoalCard('Strength', 'strength', Icons.monitor_weight_rounded),
              _buildGoalCard('Endurance', 'endurance', Icons.directions_run_rounded),
              _buildGoalCard('Flexibility', 'flexibility', Icons.accessibility_new_rounded),
              _buildGoalCard('General Fitness', 'general_fitness', Icons.favorite_rounded),
            ],
          ),
          const SizedBox(height: 32),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String id, IconData icon) {
    final isSelected = _selectedGoal == id;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedGoal = id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    if (_selectedGoal == 'flexibility' || _selectedGoal == 'general_fitness') {
      return const SizedBox.shrink(); // Handled by skip logic
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Target Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define measurable targets for the plan.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          if (_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') ...[
            _buildTextField('Current weight (kg)', _currentWeightCtrl),
            const SizedBox(height: 16),
            _buildTextField('Target weight (kg)', _targetWeightCtrl),
            const SizedBox(height: 16),
            _buildTextField('Height (cm)', _heightCtrl),
          ] else if (_selectedGoal == 'strength') ...[
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
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  items: _lifts.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (v) => setState(() => _selectedLift = v!),
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
            )
          ],
          const SizedBox(height: 32),
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
        labelStyle: const TextStyle(color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
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
    );
  }

  Widget _buildUnitChip(String unit) {
    final isSelected = _selectedUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _selectedUnit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          unit,
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline & Commitment',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'When should the member achieve this?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),
          Text('Achieve this by:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDeadlineChip('4 weeks', 4),
              _buildDeadlineChip('8 weeks', 8),
              _buildDeadlineChip('12 weeks', 12),
              _buildDeadlineChip('6 months', 26),
            ],
          ),
          const SizedBox(height: 32),
          Text('Sessions per week:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryDark)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [2, 3, 4, 5, 6].map((n) => _buildSessionButton(n)).toList(),
          ),
          const SizedBox(height: 48),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildDeadlineChip(String label, int weeks) {
    final isSelected = _deadlineWeeks == weeks;
    return GestureDetector(
      onTap: () => setState(() => _deadlineWeeks = weeks),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionButton(int count) {
    final isSelected = _sessionsPerWeek == count;
    return GestureDetector(
      onTap: () => setState(() => _sessionsPerWeek = count),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.2) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          count.toString(),
          style: TextStyle(
            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            fontSize: 20,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStep4() {
    String summaryTarget = 'General Improvement';
    String weeklyRate = '';

    if (_selectedGoal == 'weight_loss' || _selectedGoal == 'muscle_gain') {
      final current = double.tryParse(_currentWeightCtrl.text) ?? 0;
      final target = double.tryParse(_targetWeightCtrl.text) ?? 0;
      final diff = (target - current).abs();
      summaryTarget = '${target}kg';
      weeklyRate = '(${(diff / _deadlineWeeks).toStringAsFixed(2)}kg per week)';
    } else if (_selectedGoal == 'strength') {
      summaryTarget = '${_targetMaxCtrl.text}kg $_selectedLift';
    } else if (_selectedGoal == 'endurance') {
      summaryTarget = '${_targetDistanceCtrl.text}$_selectedUnit';
    }

    String goalTitle = _selectedGoal!.replaceAll('_', ' ').toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Confirm',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Goal', goalTitle),
                if (_selectedGoal != 'flexibility' && _selectedGoal != 'general_fitness') ...[
                  const Divider(color: AppColors.divider, height: 32),
                  _buildSummaryRow('Target', summaryTarget),
                  if (weeklyRate.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        weeklyRate,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.turquoise,
                            ),
                      ),
                    ),
                ],
                const Divider(color: AppColors.divider, height: 32),
                _buildSummaryRow('Deadline', 'In $_deadlineWeeks weeks'),
                const Divider(color: AppColors.divider, height: 32),
                _buildSummaryRow('Commitment', '$_sessionsPerWeek sessions / wk'),
              ],
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ASSIGN GOAL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.primary),
          ),
        ),
        child: const Text('CONTINUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}
