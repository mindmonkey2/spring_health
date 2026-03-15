// lib/screens/trainers/add_trainer_screen.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/trainer_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../theme/app_colors.dart';

class AddTrainerScreen extends StatefulWidget {
  final String? branch;
  final TrainerModel? trainer; // For editing

  const AddTrainerScreen({super.key, this.branch, this.trainer});

  @override
  State<AddTrainerScreen> createState() => _AddTrainerScreenState();
}

class _AddTrainerScreenState extends State<AddTrainerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _addressController = TextEditingController();

  // Form state
  String _selectedGender = 'Male';
  String _selectedBranch = '';
  String _selectedSpecialization = 'Gym Training';
  String _selectedExperience = '1-2 years';
  DateTime? _dateOfBirth;
  DateTime _joiningDate = DateTime.now();
  bool _isProcessing = false;

  // Specialization options
  final List<String> _specializations = [
    'Gym Training',
    'Yoga',
    'Cardio',
    'Zumba',
    'CrossFit',
    'Personal Training',
    'Nutrition',
    'Other',
  ];

  // Experience options
  final List<String> _experienceOptions = [
    'Less than 1 year',
    '1-2 years',
    '2-5 years',
    '5-10 years',
    '10+ years',
  ];

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.branch ?? AppConstants.branches.first;

    // If editing, populate fields
    if (widget.trainer != null) {
      _nameController.text = widget.trainer!.name;
      _phoneController.text = widget.trainer!.phone;
      _emailController.text = widget.trainer!.email;
      _salaryController.text = widget.trainer!.salary.toString();
      _qualificationController.text = widget.trainer!.qualification;
      _addressController.text = widget.trainer!.address ?? '';
      _selectedGender = widget.trainer!.gender;
      _selectedBranch = widget.trainer!.branch;
      _selectedSpecialization = widget.trainer!.specialization;
      _selectedExperience = widget.trainer!.experience;
      _dateOfBirth = widget.trainer!.dateOfBirth;
      _joiningDate = widget.trainer!.joiningDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    _qualificationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.success,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _selectJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.success,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  Future<void> _saveTrainer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final trainerId = widget.trainer?.id ?? const Uuid().v4().substring(0, 13);

      final trainer = TrainerModel(
        id: trainerId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dateOfBirth,
        branch: _selectedBranch,
        specialization: _selectedSpecialization,
        experience: _selectedExperience,
        salary: double.parse(_salaryController.text),
        qualification: _qualificationController.text.trim(),
        joiningDate: _joiningDate,
        isActive: true,
        assignedMembers: widget.trainer?.assignedMembers ?? [],
        createdAt: widget.trainer?.createdAt ?? DateTime.now(),
        address: _addressController.text.trim(),
      );

      if (widget.trainer != null) {
        await _firestoreService.updateTrainer(trainer);
      } else {
        await _firestoreService.addTrainer(trainer);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.trainer != null
          ? 'Trainer updated successfully!'
          : 'Trainer added successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainer != null ? 'Edit Trainer' : 'Add New Trainer'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.turquoise],
            ),
          ),
        ),
        foregroundColor: Colors.white,
          elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Personal Information Section
            _buildSectionHeader('Personal Information', Icons.person),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter trainer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!value.contains('@')) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.wc),
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.genders.map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedGender = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectDateOfBirth,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.cake),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : 'Select',
                      style: TextStyle(
                        color: _dateOfBirth != null ? Colors.black : Colors.grey,
                      ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address (Optional)',
              icon: Icons.home,
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // Professional Details Section
            _buildSectionHeader('Professional Details', Icons.work),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSpecialization,
              decoration: const InputDecoration(
                labelText: 'Specialization',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
              ),
              items: _specializations.map((spec) {
                return DropdownMenuItem(value: spec, child: Text(spec));
              }).toList(),
              onChanged: (value) => setState(() => _selectedSpecialization = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedExperience,
              decoration: const InputDecoration(
                labelText: 'Experience',
                prefixIcon: Icon(Icons.timeline),
                border: OutlineInputBorder(),
              ),
              items: _experienceOptions.map((exp) {
                return DropdownMenuItem(value: exp, child: Text(exp));
              }).toList(),
              onChanged: (value) => setState(() => _selectedExperience = value!),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _qualificationController,
              label: 'Qualification',
              icon: Icons.school,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter qualification';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Branch selector
            if (widget.branch == null)
              DropdownButtonFormField<String>(
                initialValue: _selectedBranch,
                decoration: const InputDecoration(
                  labelText: 'Branch',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.branches.map((branch) {
                  return DropdownMenuItem(value: branch, child: Text(branch));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBranch = value!),
              )
              else
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Branch',
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  child: Text(
                    _selectedBranch,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectJoiningDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Joining Date',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      '${_joiningDate.day}/${_joiningDate.month}/${_joiningDate.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Salary Section
                _buildSectionHeader('Compensation', Icons.currency_rupee),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _salaryController,
                  label: 'Monthly Salary',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter salary';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _saveTrainer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                    ),
                    child: _isProcessing
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.trainer != null ? Icons.save : Icons.person_add, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.trainer != null ? 'Update Trainer' : 'Add Trainer',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.success, AppColors.turquoise],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        counterText: '',
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[100],
      ),
      validator: validator,
    );
  }
}
