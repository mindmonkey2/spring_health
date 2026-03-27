import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/gym_equipment_model.dart';
import '../../theme/app_colors.dart';

class EquipmentManagerScreen extends StatefulWidget {
  const EquipmentManagerScreen({super.key});

  @override
  State<EquipmentManagerScreen> createState() => _EquipmentManagerScreenState();
}

class _EquipmentManagerScreenState extends State<EquipmentManagerScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _selectedBranch = 'Hanamkonda';
  final TextEditingController _customEquipmentController = TextEditingController();

  final List<String> _presetEquipment = [
    'Barbell', 'Dumbbells', 'Treadmill', 'Elliptical', 'Rowing Machine',
    'Squat Rack', 'Bench Press', 'Leg Press', 'Lat Pulldown', 'Cable Machine',
    'Kettlebells', 'Medicine Balls', 'Resistance Bands', 'Pull-up Bar', 'Smith Machine',
    'Leg Extension', 'Leg Curl', 'Pec Deck', 'Chest Press', 'Shoulder Press',
    'Bicep Curl Machine', 'Tricep Extension', 'Calf Raise Machine', 'Hip Abductor', 'Hip Adductor', 'Ab Crunch Machine'
  ];

  @override
  void dispose() {
    _customEquipmentController.dispose();
    super.dispose();
  }

  Future<void> _updateEquipmentList(List<String> newEquipment) async {
    final docRef = _db.collection('gymEquipment').doc(_selectedBranch);
    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        await docRef.update({
          'equipment': newEquipment,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.set({
          'branch': _selectedBranch,
          'equipment': newEquipment,
          'updatedAt': FieldValue.serverTimestamp(),
          'updatedBy': '', // Can be populated with user ID
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update equipment: $e')),
        );
      }
    }
  }

  void _showAddEquipmentBottomSheet(List<String> currentEquipment) {
    List<String> selectedEquipment = List.from(currentEquipment);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Manage Equipment',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customEquipmentController,
                          decoration: InputDecoration(
                            hintText: 'Add custom equipment',
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final text = _customEquipmentController.text.trim();
                          if (text.isNotEmpty && !selectedEquipment.contains(text)) {
                            setModalState(() {
                              selectedEquipment.add(text);
                            });
                            _customEquipmentController.clear();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.all(14),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Preset Equipment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _presetEquipment.map((preset) {
                          final isSelected = selectedEquipment.contains(preset);
                          return FilterChip(
                            label: Text(preset),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  selectedEquipment.add(preset);
                                } else {
                                  selectedEquipment.remove(preset);
                                }
                              });
                            },
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _updateEquipmentList(selectedEquipment);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Manager'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBranch,
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: ['Hanamkonda', 'Warangal'].map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBranch = val;
                    });
                  }
                },
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('gymEquipment').doc(_selectedBranch).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> currentEquipment = [];
          if (snapshot.hasData && snapshot.data!.exists) {
            final model = GymEquipmentModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
            currentEquipment = model.equipment;
          }

          return Column(
            children: [
              Expanded(
                child: currentEquipment.isEmpty
                    ? const Center(
                        child: Text(
                          'No equipment found for this branch.\nTap the + button to add some.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: currentEquipment.length,
                        itemBuilder: (context, index) {
                          final item = currentEquipment[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: AppColors.surface,
                            child: ListTile(
                              leading: const Icon(Icons.fitness_center, color: AppColors.primary),
                              title: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  List<String> newEquipment = List.from(currentEquipment);
                                  newEquipment.removeAt(index);
                                  _updateEquipmentList(newEquipment);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('gymEquipment').doc(_selectedBranch).snapshots(),
        builder: (context, snapshot) {
          List<String> currentEquipment = [];
          if (snapshot.hasData && snapshot.data!.exists) {
            final model = GymEquipmentModel.fromMap(
                snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
            currentEquipment = model.equipment;
          }
          return FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () => _showAddEquipmentBottomSheet(currentEquipment),
            child: const Icon(Icons.add, color: Colors.white),
          );
        }
      ),
    );
  }
}
