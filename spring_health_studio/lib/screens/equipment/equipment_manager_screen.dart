import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../theme/app_colors.dart';
import '../../services/auth_service.dart';

class EquipmentManagerScreen extends StatefulWidget {
  const EquipmentManagerScreen({super.key});

  @override
  State<EquipmentManagerScreen> createState() => _EquipmentManagerScreenState();
}

class _EquipmentManagerScreenState extends State<EquipmentManagerScreen> {
  late String selectedBranch;
  final AuthService _authService = AuthService();

  // Custom presets
  final List<String> presetChips = [
    'Barbell and Plates', 'Dumbbells 5-50 kg',
    'EZ Bar', 'Cable Machine', 'Smith Machine',
    'Leg Press', 'Hack Squat', 'Pull-up Bar',
    'Dip Bar', 'Bench Flat', 'Bench Incline',
    'Bench Decline', 'Pec Deck', 'T-Bar Row',
    'Preacher Curl', 'Kettlebells Various',
    'Resistance Bands', 'Battle Ropes',
    'Treadmill', 'Stationary Bike',
    'Rowing Machine', 'Lat Pulldown Machine',
    'Leg Curl Machine', 'Leg Extension Machine',
    'Shoulder Press Machine', 'Pull-down Machine',
  ];

  @override
  void initState() {
    super.initState();
    selectedBranch = AppConstants.branches.first;
  }

  void _showAddEquipmentBottomSheet(BuildContext context, List<String> currentList) {
    Set<String> selectedItems = {};
    final TextEditingController customController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.fitness_center_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Add Equipment',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preset Equipment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: presetChips.map((chip) {
                              final bool alreadyAdded = currentList.contains(chip);
                              final bool isSelected = selectedItems.contains(chip);
                              return FilterChip(
                                label: Text(chip),
                                selected: isSelected,
                                onSelected: alreadyAdded
                                    ? null
                                    : (selected) {
                                        setSheetState(() {
                                          if (selected) {
                                            selectedItems.add(chip);
                                          } else {
                                            selectedItems.remove(chip);
                                          }
                                        });
                                      },
                                selectedColor: AppColors.turquoise,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: alreadyAdded
                                      ? Colors.grey
                                      : (isSelected ? Colors.white : AppColors.textPrimary),
                                ),
                                disabledColor: Colors.grey.shade200,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Custom Equipment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: customController,
                                  decoration: InputDecoration(
                                    hintText: 'Other equipment name',
                                    filled: true,
                                    fillColor: AppColors.background,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.primaryLight,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                                onPressed: () {
                                  final val = customController.text.trim();
                                  if (val.isNotEmpty && !currentList.contains(val)) {
                                    setSheetState(() {
                                      selectedItems.add(val);
                                      customController.clear();
                                    });
                                  }
                                },
                                child: const Text('Add Custom'),
                              ),
                            ],
                          ),
                          if (selectedItems.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Selected to Add (${selectedItems.length})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedItems.map((item) {
                                return Chip(
                                  label: Text(item),
                                  backgroundColor: AppColors.turquoise,
                                  labelStyle: const TextStyle(color: Colors.white),
                                  deleteIconColor: Colors.white,
                                  onDeleted: () {
                                    setSheetState(() {
                                      selectedItems.remove(item);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      top: 10,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: selectedItems.isEmpty
                          ? null
                          : () async {
                              final uid = _authService.currentUser?.uid ?? '';
                              await FirebaseFirestore.instance
                                  .collection('gymEquipment')
                                  .doc(selectedBranch)
                                  .set({
                                'branch': selectedBranch,
                                'equipment': FieldValue.arrayUnion(selectedItems.toList()),
                                'updatedAt': Timestamp.now(),
                                'updatedBy': uid,
                              }, SetOptions(merge: true));

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${selectedItems.length} items added.'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              Navigator.pop(context);
                            },
                      child: const Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(String equipmentName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Remove Equipment'),
          content: Text('Remove $equipmentName from equipment list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final uid = _authService.currentUser?.uid ?? '';
                await FirebaseFirestore.instance
                    .collection('gymEquipment')
                    .doc(selectedBranch)
                    .update({
                  'equipment': FieldValue.arrayRemove([equipmentName]),
                  'updatedAt': Timestamp.now(),
                  'updatedBy': uid,
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$equipmentName removed.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Equipment Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Branch Selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedBranch,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      items: AppConstants.branches.map((branch) {
                        return DropdownMenuItem(
                          value: branch,
                          child: Text('$branch Branch'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedBranch = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Equipment List
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('gymEquipment')
                  .doc(selectedBranch)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Error loading data',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.border),
                        SizedBox(height: 16),
                        Text(
                          'No equipment configured\nfor this branch.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> rawEquipment = data['equipment'] ?? [];
                final List<String> equipmentList = rawEquipment.map((e) => e.toString()).toList();

                if (equipmentList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_rounded, size: 64, color: AppColors.border),
                        SizedBox(height: 16),
                        Text(
                          'No equipment configured\nfor this branch.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: equipmentList.length,
                  itemBuilder: (context, index) {
                    final String item = equipmentList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.cardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.successLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                        ),
                        title: Text(
                          item,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _confirmDelete(item),
                          tooltip: 'Remove',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('gymEquipment')
            .doc(selectedBranch)
            .snapshots(),
        builder: (context, snapshot) {
          List<String> currentList = [];
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final List<dynamic> rawEquipment = data['equipment'] ?? [];
            currentList = rawEquipment.map((e) => e.toString()).toList();
          }

          return FloatingActionButton.extended(
            onPressed: () => _showAddEquipmentBottomSheet(context, currentList),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Equipment', style: TextStyle(fontWeight: FontWeight.bold)),
            elevation: 4,
          );
        },
      ),
    );
  }
}
