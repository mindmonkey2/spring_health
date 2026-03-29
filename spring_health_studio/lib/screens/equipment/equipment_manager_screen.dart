import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';

class EquipmentManagerScreen extends StatefulWidget {
  const EquipmentManagerScreen({super.key});

  @override
  State<EquipmentManagerScreen> createState() => _EquipmentManagerScreenState();
}

class _EquipmentManagerScreenState extends State<EquipmentManagerScreen> {
  String? selectedBranch;

  @override
  void initState() {
    super.initState();
    if (AppConstants.branches.isNotEmpty) {
      selectedBranch = AppConstants.branches.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Equipment Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildBranchSelector(),
          Expanded(child: _buildEquipmentStream()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEquipmentSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Equipment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedBranch,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          items: AppConstants.branches.map((branch) {
            return DropdownMenuItem<String>(
              value: branch,
              child: Text(branch),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedBranch = val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildEquipmentStream() {
    if (selectedBranch == null) {
      return const Center(child: Text('No branch selected.'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('gymEquipment')
          .doc(selectedBranch)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error loading equipment',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(
            child: Text(
              'No equipment configured\nfor this branch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final equipmentList = List<String>.from(data['equipment'] ?? []);

        if (equipmentList.isEmpty) {
          return const Center(
            child: Text(
              'No equipment configured\nfor this branch.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: equipmentList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = equipmentList[index];
            return _buildEquipmentTile(item);
          },
        );
      },
    );
  }

  Widget _buildEquipmentTile(String item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_outline, color: AppColors.success),
        ),
        title: Text(
          item,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () => _confirmDelete(item),
        ),
      ),
    );
  }

  void _confirmDelete(String item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Equipment'),
        content: Text('Are you sure you want to remove "$item" from this branch?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteEquipment(item);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEquipment(String item) async {
    if (selectedBranch == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('gymEquipment')
          .doc(selectedBranch)
          .update({
        'equipment': FieldValue.arrayRemove([item]),
        'updatedAt': Timestamp.now(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "$item"'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showAddEquipmentSheet(BuildContext context) async {
    if (selectedBranch == null) return;

    // Fetch current equipment to disable existing ones
    final doc = await FirebaseFirestore.instance
        .collection('gymEquipment')
        .doc(selectedBranch)
        .get();

    final data = doc.data() ?? {};
    final existingItems = List<String>.from(data['equipment'] ?? []);

    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddEquipmentSheet(
        branch: selectedBranch!,
        existingItems: existingItems,
      ),
    );
  }
}

class _AddEquipmentSheet extends StatefulWidget {
  final String branch;
  final List<String> existingItems;

  const _AddEquipmentSheet({
    required this.branch,
    required this.existingItems,
  });

  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  final List<String> _presetItems = [
    'Barbell + Plates', 'Dumbbells 5-50kg', 'EZ Bar', 'Cable Machine',
    'Smith Machine', 'Leg Press', 'Hack Squat', 'Pull-up Bar', 'Dip Bar',
    'Bench (Flat)', 'Bench (Incline)', 'Bench (Decline)', 'Pec Deck',
    'T-Bar Row', 'Preacher Curl', 'Kettlebells (various)', 'Resistance Bands',
    'Battle Ropes', 'Treadmill', 'Stationary Bike', 'Rowing Machine',
    'Pull-down Machine', 'Leg Curl Machine', 'Leg Extension Machine',
    'Shoulder Press Machine', 'Lat Pulldown'
  ];

  final Set<String> _selectedItems = {};
  final TextEditingController _customController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustomItem() {
    final text = _customController.text.trim();
    if (text.isNotEmpty && !widget.existingItems.contains(text)) {
      setState(() {
        _selectedItems.add(text);
        _customController.clear();
      });
    }
  }

  Future<void> _saveEquipment() async {
    if (_selectedItems.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('gymEquipment')
          .doc(widget.branch)
          .set({
        'branch': widget.branch,
        'equipment': FieldValue.arrayUnion(_selectedItems.toList()),
        'updatedAt': Timestamp.now(),
        'updatedBy': FirebaseAuth.instance.currentUser?.uid,
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipment updated'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select Equipment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const Text(
                  'Preset items',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetItems.map((item) {
                    final isExisting = widget.existingItems.contains(item);
                    final isSelected = _selectedItems.contains(item) || isExisting;

                    return FilterChip(
                      label: Text(item),
                      selected: isSelected,
                      onSelected: isExisting
                          ? null // Disable if already exists
                          : (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedItems.add(item);
                                } else {
                                  _selectedItems.remove(item);
                                }
                              });
                            },
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Custom item',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customController,
                        decoration: InputDecoration(
                          hintText: 'Add custom equipment name',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _addCustomItem(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addCustomItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ADD'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Show added custom items that aren't presets
                if (_selectedItems.any((item) => !_presetItems.contains(item))) ...[
                  const Text(
                    'Added Custom Items',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedItems
                        .where((item) => !_presetItems.contains(item))
                        .map((item) => Chip(
                              label: Text(item),
                              onDeleted: () {
                                setState(() {
                                  _selectedItems.remove(item);
                                });
                              },
                              backgroundColor: AppColors.turquoise.withValues(alpha: 0.2),
                              deleteIconColor: AppColors.turquoiseDark,
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEquipment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
