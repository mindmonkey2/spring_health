import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_studio/theme/app_colors.dart';
import 'package:spring_health_studio/utils/constants.dart';
import 'package:spring_health_studio/services/auth_service.dart';

class EquipmentManagerScreen extends StatefulWidget {
  const EquipmentManagerScreen({super.key});

  @override
  State<EquipmentManagerScreen> createState() => _EquipmentManagerScreenState();
}

class _EquipmentManagerScreenState extends State<EquipmentManagerScreen> {
  String _selectedBranch = AppConstants.branches.first;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  final List<String> _equipmentPresets = [
    'Barbell + Plates', 'Dumbbells 5-50kg', 'EZ Bar', 'Cable Machine',
    'Smith Machine', 'Leg Press', 'Hack Squat', 'Pull-up Bar', 'Dip Bar',
    'Bench (Flat)', 'Bench (Incline)', 'Bench (Decline)', 'Pec Deck',
    'T-Bar Row', 'Preacher Curl', 'Kettlebells (various)', 'Resistance Bands',
    'Battle Ropes', 'Treadmill', 'Stationary Bike', 'Rowing Machine',
    'Pull-down Machine', 'Leg Curl Machine', 'Leg Extension Machine',
    'Shoulder Press Machine', 'Lat Pulldown'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Manager', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.successGradient,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildBranchSelector(),
          Expanded(child: _buildEquipmentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEquipmentSheet(context),
        backgroundColor: AppColors.success,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedBranch,
        decoration: InputDecoration(
          labelText: 'Branch',
          prefixIcon: const Icon(Icons.location_on, color: AppColors.success),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.success, width: 2),
          ),
        ),
        items: AppConstants.branches.map((branch) {
          return DropdownMenuItem(value: branch, child: Text(branch));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedBranch = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildEquipmentList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('gymEquipment').doc(_selectedBranch).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading equipment: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final equipmentList = (data?['equipmentList'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

        if (equipmentList.isEmpty) {
          return const Center(
            child: Text(
              'No equipment configured.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: equipmentList.length,
          itemBuilder: (context, index) {
            final equipment = equipmentList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.successLight,
                  child: Icon(Icons.check, color: AppColors.success),
                ),
                title: Text(equipment, style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.coral),
                  onPressed: () => _confirmDelete(equipment),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String equipment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Equipment'),
        content: Text('Are you sure you want to remove "$equipment" from $_selectedBranch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () {
              Navigator.pop(context);
              _removeEquipment(equipment);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _removeEquipment(String equipment) async {
    try {
      final uid = _authService.currentUser?.uid;
      await _firestore.collection('gymEquipment').doc(_selectedBranch).set({
        'equipmentList': FieldValue.arrayRemove([equipment]),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': uid,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $equipment'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove equipment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddEquipmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddEquipmentBottomSheet(
        branch: _selectedBranch,
        presets: _equipmentPresets,
        onSave: _saveEquipment,
      ),
    );
  }

  Future<void> _saveEquipment(List<String> newItems) async {
    if (newItems.isEmpty) return;

    try {
      final uid = _authService.currentUser?.uid;
      await _firestore.collection('gymEquipment').doc(_selectedBranch).set({
        'equipmentList': FieldValue.arrayUnion(newItems),
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': uid,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment added successfully.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add equipment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _AddEquipmentBottomSheet extends StatefulWidget {
  final String branch;
  final List<String> presets;
  final Future<void> Function(List<String>) onSave;

  const _AddEquipmentBottomSheet({
    required this.branch,
    required this.presets,
    required this.onSave,
  });

  @override
  State<_AddEquipmentBottomSheet> createState() => _AddEquipmentBottomSheetState();
}

class _AddEquipmentBottomSheetState extends State<_AddEquipmentBottomSheet> {
  final Set<String> _selectedPresets = {};
  final TextEditingController _customEquipmentController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _customEquipmentController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final customText = _customEquipmentController.text.trim();
    final itemsToSave = _selectedPresets.toList();

    if (customText.isNotEmpty) {
      itemsToSave.add(customText);
    }

    if (itemsToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter at least one item.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSave(itemsToSave);
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Equipment',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.presets.map((preset) {
                  final isSelected = _selectedPresets.contains(preset);
                  return FilterChip(
                    label: Text(preset),
                    selected: isSelected,
                    selectedColor: AppColors.successLight,
                    checkmarkColor: AppColors.success,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPresets.add(preset);
                        } else {
                          _selectedPresets.remove(preset);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customEquipmentController,
            decoration: InputDecoration(
              labelText: 'Add unlisted equipment',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.success, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
