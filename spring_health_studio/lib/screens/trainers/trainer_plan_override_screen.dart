import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';

class TrainerPlanOverrideScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const TrainerPlanOverrideScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<TrainerPlanOverrideScreen> createState() => _TrainerPlanOverrideScreenState();
}

class _TrainerPlanOverrideScreenState extends State<TrainerPlanOverrideScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  String? _weeklyFocus;

  final _formKey = GlobalKey<FormState>();
  final _trainerNoteController = TextEditingController();
  final _exerciseController = TextEditingController();

  List<String> _restrictedExercises = [];
  List<Map<String, dynamic>> _modifiedExercises = [];

  // Form fields for new modified exercise
  int _modDay = 1;
  final _modNameController = TextEditingController();
  final _modSetsController = TextEditingController();
  final _modRepsController = TextEditingController();
  final _modReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _trainerNoteController.dispose();
    _exerciseController.dispose();
    _modNameController.dispose();
    _modSetsController.dispose();
    _modRepsController.dispose();
    _modReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    try {
      final doc = await _firestore
          .collection('aiPlans')
          .doc(widget.memberId)
          .collection('current')
          .doc('plan')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _weeklyFocus = data['weeklyFocus'] as String?;

        final overrideData = data['trainerOverride'] as Map<String, dynamic>?;
        if (overrideData != null) {
          _trainerNoteController.text = overrideData['trainerNote'] as String? ?? '';
          _restrictedExercises = List<String>.from(overrideData['restrictedExercises'] ?? []);
          _modifiedExercises = List<Map<String, dynamic>>.from(overrideData['modifiedExercises'] ?? []);
        }
      }
    } catch (e) {
      debugPrint('Error loading AI Plan: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading AI Plan: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveOverride() async {
    if (!_formKey.currentState!.validate()) return;

    // trainerNote is required, double check
    if (_trainerNoteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trainer note is required.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final overrideMap = {
        'trainerNote': _trainerNoteController.text.trim(),
        'restrictedExercises': _restrictedExercises,
        'modifiedExercises': _modifiedExercises,
        'overrideApprovedAt': Timestamp.now(),
        'trainerName': 'Trainer', // Assuming generic trainer name for studio, normally from Auth/User
      };

      await _firestore
          .collection('aiPlans')
          .doc(widget.memberId)
          .collection('current')
          .doc('plan')
          .update({'trainerOverride': overrideMap});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Override saved successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving override: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving override: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _clearOverride() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Override?'),
        content: const Text('Are you sure you want to remove all trainer overrides for this plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      await _firestore
          .collection('aiPlans')
          .doc(widget.memberId)
          .collection('current')
          .doc('plan')
          .update({'trainerOverride': FieldValue.delete()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Override cleared.'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error clearing override: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing override: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addRestrictedExercise() {
    final text = _exerciseController.text.trim();
    if (text.isNotEmpty && !_restrictedExercises.contains(text)) {
      setState(() {
        _restrictedExercises.add(text);
        _exerciseController.clear();
      });
    }
  }

  void _addModifiedExercise() {
    final name = _modNameController.text.trim();
    final setsStr = _modSetsController.text.trim();
    final reps = _modRepsController.text.trim();
    final reason = _modReasonController.text.trim();

    if (name.isEmpty || setsStr.isEmpty || reps.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields for modification.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final sets = int.tryParse(setsStr);
    if (sets == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sets must be a valid number.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      _modifiedExercises.add({
        'day': _modDay,
        'exerciseName': name,
        'overrideSets': sets,
        'overrideReps': reps,
        'reason': reason,
      });
      _modNameController.clear();
      _modSetsController.clear();
      _modRepsController.clear();
      _modReasonController.clear();
      _modDay = 1;
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Override Plan: ${widget.memberName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Override',
            onPressed: _isLoading ? null : _clearOverride,
          ),
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save Override',
            onPressed: _isLoading ? null : _saveOverride,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Plan Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.smart_toy_rounded, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text('Current AI Plan Focus', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_weeklyFocus ?? 'No active plan focus found.', style: const TextStyle(color: AppColors.textPrimary)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle('Trainer Notes'),
                    TextFormField(
                      controller: _trainerNoteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Add your instructions or override notes here...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppColors.surface,
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required field' : null,
                    ),

                    _buildSectionTitle('Restricted Exercises'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _exerciseController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Barbell Squat',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onFieldSubmitted: (_) => _addRestrictedExercise(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _addRestrictedExercise,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _restrictedExercises.map((ex) {
                        return Chip(
                          label: Text(ex),
                          backgroundColor: AppColors.coral.withValues(alpha: 0.2),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => setState(() => _restrictedExercises.remove(ex)),
                        );
                      }).toList(),
                    ),

                    _buildSectionTitle('Modified Exercises'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonFormField<int>(
                                  initialValue: _modDay,
                                  decoration: const InputDecoration(labelText: 'Day', isDense: true),
                                  items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text('Day ${i + 1}'))),
                                  onChanged: (v) => setState(() => _modDay = v ?? 1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 4,
                                child: TextFormField(
                                  controller: _modNameController,
                                  decoration: const InputDecoration(labelText: 'Exercise Name', isDense: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _modSetsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Sets', isDense: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _modRepsController,
                                  decoration: const InputDecoration(labelText: 'Reps (e.g. 8-10)', isDense: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _modReasonController,
                            decoration: const InputDecoration(labelText: 'Reason (optional)', isDense: true),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _addModifiedExercise,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Modification'),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.turquoise),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._modifiedExercises.map((mod) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text('Day ${mod['day']}: ${mod['exerciseName']}'),
                          subtitle: Text('${mod['overrideSets']} sets x ${mod['overrideReps']} reps\nReason: ${mod['reason']}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => setState(() => _modifiedExercises.remove(mod)),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveOverride,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Plan Override', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
