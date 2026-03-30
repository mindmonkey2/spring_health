import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class GoalSetSheet extends StatefulWidget {
  final String authUid;
  final String primaryGoal;
  final String createdBy;

  const GoalSetSheet({
    super.key,
    required this.authUid,
    required this.primaryGoal,
    required this.createdBy,
  });

  @override
  State<GoalSetSheet> createState() => _GoalSetSheetState();
}

class _GoalSetSheetState extends State<GoalSetSheet> {
  final _currentController = TextEditingController();
  final _targetController = TextEditingController();
  final _heightController = TextEditingController();

  String _selectedLift = 'Bench Press';
  final List<String> _lifts = ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Pull-ups'];

  String _distanceUnit = 'km';

  DateTime? _deadline;
  int _weeksRemaining = 0;
  String _selectedPreset = '';

  int _sessionsPerWeek = 4;

  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _targetController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateWeeks() {
    if (_deadline == null) {
      _weeksRemaining = 0;
      return;
    }
    final now = DateTime.now();
    final diff = _deadline!.difference(now).inDays;
    _weeksRemaining = (diff / 7).ceil();
    if (_weeksRemaining < 1) _weeksRemaining = 1;
  }

  void _setDeadlinePreset(String preset, int weeks) {
    setState(() {
      _selectedPreset = preset;
      _deadline = DateTime.now().add(Duration(days: weeks * 7));
      _calculateWeeks();
    });
  }

  Future<void> _selectCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedPreset = 'custom';
        _deadline = picked;
        _calculateWeeks();
      });
    }
  }

  String get _goalDisplayName {
    switch (widget.primaryGoal) {
      case 'weight_loss': return 'Weight Loss';
      case 'muscle_gain': return 'Muscle Gain';
      case 'strength': return 'Strength';
      case 'endurance': return 'Endurance';
      case 'flexibility': return 'Flexibility';
      case 'general_fitness': return 'General Fitness';
      default: return widget.primaryGoal;
    }
  }

  String get _unit {
    if (widget.primaryGoal == 'weight_loss' || widget.primaryGoal == 'muscle_gain' || widget.primaryGoal == 'strength') {
      return 'kg';
    }
    if (widget.primaryGoal == 'endurance') {
      return _distanceUnit;
    }
    return '';
  }

  double get _currentValue => double.tryParse(_currentController.text) ?? 0.0;
  double get _targetValue => double.tryParse(_targetController.text) ?? 0.0;

  bool get _needsInput {
    return widget.primaryGoal != 'flexibility' && widget.primaryGoal != 'general_fitness';
  }

  Future<void> _saveGoal() async {
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    if (_needsInput && (_currentValue <= 0 || _targetValue <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid current and target values')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> milestones = [];
      if (_needsInput && _weeksRemaining > 0) {
        for (int i = 1; i <= 4; i++) {
          final double diff = _targetValue - _currentValue;
          final double val = _currentValue + (diff * 0.25 * i);
          milestones.add({
            'week': (_weeksRemaining / 4 * i).round(),
            'target': double.parse(val.toStringAsFixed(1)),
          });
        }
      }

      final Map<String, dynamic> data = {
        'primaryGoal': widget.primaryGoal,
        'goalDisplayName': _goalDisplayName,
        'deadline': Timestamp.fromDate(_deadline!),
        'weeksRemaining': _weeksRemaining,
        'sessionsPerWeek': _sessionsPerWeek,
        'createdBy': widget.createdBy,
        'updatedAt': Timestamp.now(),
        'currentPace': 'Not Started',
      };

      if (_needsInput) {
        data['startValue'] = _currentValue;
        data['currentValue'] = _currentValue;
        data['targetValue'] = _targetValue;
        data['unit'] = _unit;
        data['milestones'] = milestones;

        if (widget.primaryGoal == 'weight_loss' || widget.primaryGoal == 'muscle_gain') {
          data['heightCm'] = double.tryParse(_heightController.text) ?? 0.0;
        } else if (widget.primaryGoal == 'strength') {
          data['lift'] = _selectedLift;
        }
      }

      await FirebaseFirestore.instance
          .collection('memberGoals')
          .doc(widget.authUid)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal set! AjAX will track every session toward it.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildStep2() {
    if (!_needsInput) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No specific target needed — AjAX will track your overall progress.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.primaryGoal == 'weight_loss' || widget.primaryGoal == 'muscle_gain') ...[
          _buildTextField('Current weight (kg)', _currentController),
          const SizedBox(height: 16),
          _buildTextField('Target weight (kg)', _targetController),
          const SizedBox(height: 16),
          _buildTextField('Height (cm)', _heightController),
        ] else if (widget.primaryGoal == 'strength') ...[
          Text('Which lift?', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLift,
                isExpanded: true,
                dropdownColor: Colors.white,
                items: _lifts.map((lift) {
                  return DropdownMenuItem(value: lift, child: Text(lift, style: GoogleFonts.inter(fontSize: 14)));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLift = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Current max (kg)', _currentController),
          const SizedBox(height: 16),
          _buildTextField('Target max (kg)', _targetController),
        ] else if (widget.primaryGoal == 'endurance') ...[
          _buildTextField('Target distance', _targetController),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'km', label: Text('km')),
              ButtonSegment(value: 'miles', label: Text('miles')),
            ],
            selected: {_distanceUnit},
            onSelectionChanged: (set) {
              setState(() => _distanceUnit = set.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField('Current distance (optional)', _currentController),
        ],
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('When do you want to achieve this?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildPresetChip('4 Weeks', 4),
            _buildPresetChip('8 Weeks', 8),
            _buildPresetChip('12 Weeks', 12),
            _buildPresetChip('6 Months', 26),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _selectCustomDate,
          child: Text(
            _selectedPreset == 'custom' && _deadline != null
                ? 'Custom: ${DateFormat('dd MMM yyyy').format(_deadline!)}'
                : 'Choose custom date',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 24),
        Text('How many sessions per week?', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [2, 3, 4, 5, 6].map((n) {
            final isSelected = _sessionsPerWeek == n;
            return GestureDetector(
              onTap: () => setState(() => _sessionsPerWeek = n),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  n.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, int weeks) {
    final isSelected = _selectedPreset == label;
    return GestureDetector(
      onTap: () => _setDeadlinePreset(label, weeks),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStep4() {
    String rateText = '';
    if (_needsInput && _weeksRemaining > 0) {
      final diff = _targetValue - _currentValue;
      if (diff != 0) {
        final rate = (diff / _weeksRemaining).abs();
        final action = diff > 0 ? 'Gain' : 'Lose';
        rateText = '$action ${rate.toStringAsFixed(1)} $_unit per week';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Goal', _goalDisplayName),
          if (_needsInput) ...[
            _buildSummaryRow('Current', '$_currentValue $_unit'),
            _buildSummaryRow('Target', '$_targetValue $_unit'),
          ],
          _buildSummaryRow(
            'Deadline',
            _deadline != null ? DateFormat('dd MMM yyyy').format(_deadline!) : 'Not set',
          ),
          _buildSummaryRow('Weeks to goal', '$_weeksRemaining weeks'),
          _buildSummaryRow('Sessions/week', '$_sessionsPerWeek'),
          if (rateText.isNotEmpty) _buildSummaryRow('Weekly rate', rateText),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set Target',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildStep2(),
            const SizedBox(height: 32),
            _buildStep3(),
            const SizedBox(height: 32),
            Text('Review and Confirm', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildStep4(),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'SET MY GOAL',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
