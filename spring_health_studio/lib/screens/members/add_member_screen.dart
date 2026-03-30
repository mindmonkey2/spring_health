import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../widgets/document_send_dialog.dart';
import '../../theme/app_colors.dart';

// ✅ Custom text formatter for names - AUTO-CAPITALIZE & BLOCK SPECIAL CHARS
class NameTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove special characters (keep only letters and spaces)
    String filtered = newValue.text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');

    // Capitalize first letter of each word
    final words = filtered.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    final formatted = capitalizedWords.join(' ');

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddMemberScreen extends StatefulWidget {
  final String? branch;

  const AddMemberScreen({super.key, this.branch});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _totalFeeController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _discountDescriptionController = TextEditingController();
  final _cashAmountController = TextEditingController(text: '0');
  final _upiAmountController = TextEditingController(text: '0');

  // Form state
  String _selectedGender = 'Male';
  String _selectedCategory = AppConstants.categories.first;
  String _selectedPlan = AppConstants.plans.first;
  String _selectedBranch = '';
  String _paymentMode = 'Cash';
  DateTime? _dateOfBirth;
  DateTime _joiningDate = DateTime.now();
  DateTime _expiryDate = DateTime.now();
  double _finalAmount = 0;
  double _dueAmount = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.branch ?? AppConstants.branches.first;
    _updateFeeFromConstants();
    _calculateExpiryDate();
    _totalFeeController.addListener(_calculateAmounts);
    _discountController.addListener(_calculateAmounts);
    _cashAmountController.addListener(_calculateDue);
    _upiAmountController.addListener(_calculateDue);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _totalFeeController.dispose();
    _discountController.dispose();
    _discountDescriptionController.dispose();
    _cashAmountController.dispose();
    _upiAmountController.dispose();
    super.dispose();
  }

  void _updateFeeFromConstants() {
    final fee = AppConstants.feeStructure[_selectedBranch]?[_selectedCategory]?[_selectedPlan] ?? 0;
    setState(() {
      _totalFeeController.text = fee > 0 ? fee.toString() : '';
    });
  }

  void _calculateExpiryDate() {
    setState(() {
      _expiryDate = app_date_utils.DateUtils.calculateExpiryDate(_joiningDate, _selectedPlan);
    });
  }

  void _calculateAmounts() {
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;
    setState(() {
      _finalAmount = total - discount;
      _calculateDue();
    });
  }

  void _calculateDue() {
    final cash = double.tryParse(_cashAmountController.text) ?? 0;
    final upi = double.tryParse(_upiAmountController.text) ?? 0;
    setState(() {
      _dueAmount = _finalAmount - (cash + upi);
    });
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
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
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _selectJoiningDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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
      setState(() {
        _joiningDate = picked;
        _calculateExpiryDate();
      });
    }
  }

  Future<void> _addMember() async {
    if (!_formKey.currentState!.validate()) return;
    if (_finalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid total fee')),
      );
      return;
    }

    final cash = double.tryParse(_cashAmountController.text) ?? 0;
    final upi = double.tryParse(_upiAmountController.text) ?? 0;
    if (cash + upi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least some payment amount')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      // Check if phone number already exists
      final existingMember = await _firestoreService.getMemberByPhone(_phoneController.text.trim());
      if (existingMember != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A member with phone ${_phoneController.text} already exists!'),
            backgroundColor: AppColors.warning,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      final memberId = const Uuid().v4().substring(0, 13);
      final qrCode = 'SPRING_$memberId';
      final member = MemberModel(
        id: memberId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dateOfBirth,
        category: _selectedCategory,
        plan: _selectedPlan,
        branch: _selectedBranch,
        joiningDate: _joiningDate,
        expiryDate: _expiryDate,
        totalFee: double.parse(_totalFeeController.text),
        discount: double.parse(_discountController.text),
        discountDescription: _discountDescriptionController.text.trim(),
        finalAmount: _finalAmount,
        cashAmount: cash,
        upiAmount: upi,
        dueAmount: _dueAmount,
        paymentMode: _paymentMode,
        qrCode: qrCode,
        isActive: true,
        isArchived: false,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addMember(member);

      // Create initial payment record
      final payment = PaymentModel(
        id: '${memberId}_${DateTime.now().millisecondsSinceEpoch}',
        memberId: memberId,
        memberName: member.name,
        branch: member.branch,
        amount: cash + upi,
        cashAmount: cash,
        upiAmount: upi,
        discount: double.parse(_discountController.text), // ✅ Save discount in payment
        paymentMode: _paymentMode,
        paymentDate: DateTime.now(),
        type: 'initial',
      );

      await _firestoreService.addPayment(payment);

      if (!mounted) return;

      // Show success dialog with document sending option
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => DocumentSendDialog(
          member: member,
          documentType: 'welcome',
          title: 'Member Added Successfully! ',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome ${member.name}!',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow('ID:', member.id),
                    _buildSummaryRow('Plan:', '${member.category} - ${member.plan}'),
                    _buildSummaryRow('Expiry:', app_date_utils.DateUtils.formatDate(member.expiryDate)),
                    const Divider(height: 16),
                    _buildSummaryRow('Amount Paid:', 'Rs.${(cash + upi).toStringAsFixed(0)}'),
                    if (member.dueAmount > 0)
                      _buildSummaryRow(
                        'Due Amount:',
                        'Rs.${member.dueAmount.toStringAsFixed(0)}',
                        valueColor: AppColors.error,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.picture_as_pdf, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Send Welcome Package?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Payment Invoice\n• Membership Card with QR Code',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // The DocumentSendDialog handles everything internally, so just pop the screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase Error: ${e.message}'),
          backgroundColor: AppColors.error,
        ),
      );
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
        title: const Text('Add New Member'),
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
              inputFormatters: [NameTextFormatter()], // ✅ Auto-capitalize & block special chars
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter member name';
                }
                if (value.length < 3) {
                  return 'Name must be at least 3 characters';
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
              label: 'Email (Optional)',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
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
                        ? app_date_utils.DateUtils.formatDate(_dateOfBirth!)
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
            const SizedBox(height: 32),

            // Membership Details Section
            _buildSectionHeader('Membership Details', Icons.fitness_center),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
              ),
              items: AppConstants.categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                  _updateFeeFromConstants();
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedPlan,
              decoration: const InputDecoration(
                labelText: 'Plan',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              items: AppConstants.plans.map((plan) {
                return DropdownMenuItem(value: plan, child: Text(plan));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPlan = value!;
                  _updateFeeFromConstants();
                  _calculateExpiryDate();
                });
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
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value!;
                    _updateFeeFromConstants();
                  });
                },
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
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectJoiningDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Joining Date',
                            prefixIcon: Icon(Icons.event),
                            border: OutlineInputBorder(),
                          ),
                          child: Text(app_date_utils.DateUtils.formatDate(_joiningDate)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Expiry Date',
                          prefixIcon: const Icon(Icons.event_busy),
                          border: const OutlineInputBorder(),
                          fillColor: AppColors.success.withValues(alpha: 0.1),
                          filled: true,
                        ),
                        child: Text(
                          app_date_utils.DateUtils.formatDate(_expiryDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Payment Details Section
                _buildSectionHeader('Payment Details', Icons.payment),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _totalFeeController,
                  label: 'Total Fee',
                  icon: Icons.currency_rupee,
                  keyboardType: TextInputType.number,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter total fee';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(
                        controller: _discountController,
                        label: 'Discount',
                        icon: Icons.discount,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: _buildTextField(
                        controller: _discountDescriptionController,
                        label: 'Reason (Optional)',
                        icon: Icons.note,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Final Amount Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.success, AppColors.turquoise],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Final Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Rs.${_finalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Mode Selection
                const Text(
                  'Payment Mode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: AppConstants.paymentModes.map((mode) {
                    return ChoiceChip(
                      label: Text(mode),
                      selected: _paymentMode == mode,
                      onSelected: (selected) {
                        setState(() {
                          _paymentMode = mode;
                          if (mode == 'Cash') {
                            _cashAmountController.text = _finalAmount.toStringAsFixed(2);
                            _upiAmountController.text = '0';
                          } else if (mode == 'UPI') {
                            _upiAmountController.text = _finalAmount.toStringAsFixed(2);
                            _cashAmountController.text = '0';
                          } else {
                            _cashAmountController.text = '0';
                        _upiAmountController.text = '0';
                          }
                        });
                      },
                      selectedColor: AppColors.success.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.success,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Cash and UPI Amount Fields
                if (_paymentMode == 'Cash' || _paymentMode == 'Mixed')
                  _buildTextField(
                    controller: _cashAmountController,
                    label: 'Cash Amount',
                    icon: Icons.money,
                    keyboardType: TextInputType.number,
                    enabled: _paymentMode != 'UPI',
                  ),
                  if (_paymentMode == 'Mixed') const SizedBox(height: 16),
                    if (_paymentMode == 'UPI' || _paymentMode == 'Mixed')
                      _buildTextField(
                        controller: _upiAmountController,
                        label: 'UPI Amount',
                        icon: Icons.qr_code,
                        keyboardType: TextInputType.number,
                        enabled: _paymentMode != 'Cash',
                      ),
                      const SizedBox(height: 16),

                      // Due Amount Display
                      if (_dueAmount > 0)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.warning, color: AppColors.warningDark),
                                  SizedBox(width: 8),
                                  Text(
                                    'Due Amount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rs.${_dueAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warningDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isProcessing ? null : _addMember,
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
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Add Member',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    List<TextInputFormatter>? inputFormatters, // ✅ Added parameter
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      inputFormatters: inputFormatters, // ✅ Apply formatters
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

  // Helper method for summary rows in dialog
  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
