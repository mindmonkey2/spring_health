import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/firestore_service.dart';
import '../../services/fee_calculator.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import '../../widgets/custom_dropdown.dart';
import '../../widgets/payment_mode_selector.dart';
import '../../theme/app_colors.dart';

class EditMemberScreen extends StatefulWidget {
  final MemberModel member;
  final bool isRejoin;

  const EditMemberScreen({
    super.key,
    required this.member,
    this.isRejoin = false,
  });

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _discountController;
  late TextEditingController _discountDescController;
  late TextEditingController _dueAmountController;
  late TextEditingController _cashAmountController;
  late TextEditingController _upiAmountController;

  // Form values
  late String _selectedBranch;
  late String _selectedGender;
  late String _selectedCategory;
  late String _selectedPlan;
  late String _selectedPaymentMode;
  late DateTime _joiningDate;
  DateTime? _dateOfBirth;
  DateTime? _expiryDate;

  double _totalFee = 0;
  double _finalAmount = 0;
  List<String> _availablePlans = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.member.name);
    _phoneController = TextEditingController(text: widget.member.phone);
    _emailController = TextEditingController(text: widget.member.email);

    if (widget.isRejoin) {
      _discountController = TextEditingController(text: '0');
      _discountDescController = TextEditingController();
      _dueAmountController = TextEditingController(text: '0');
      _cashAmountController = TextEditingController(text: '0');
      _upiAmountController = TextEditingController(text: '0');
    } else {
      _discountController = TextEditingController(text: widget.member.discount.toString());
      _discountDescController = TextEditingController(text: widget.member.discountDescription);
      _dueAmountController = TextEditingController(text: widget.member.dueAmount.toString());
      _cashAmountController = TextEditingController(text: widget.member.cashAmount.toString());
      _upiAmountController = TextEditingController(text: widget.member.upiAmount.toString());
    }

    _discountController.addListener(_calculateFinalAmount);
    _dueAmountController.addListener(_calculateFinalAmount);
  }

  void _loadInitialData() {
    _selectedBranch = widget.member.branch;
    _selectedGender = widget.member.gender;
    _selectedCategory = widget.member.category;
    _selectedPlan = widget.member.plan;
    _selectedPaymentMode = widget.isRejoin ? 'Cash' : widget.member.paymentMode;
    _joiningDate = widget.isRejoin ? DateTime.now() : widget.member.joiningDate;
    _dateOfBirth = widget.member.dateOfBirth;
    _expiryDate = widget.member.expiryDate;

    _availablePlans = FeeCalculator.getAvailablePlans(_selectedBranch, _selectedCategory);

    final fee = FeeCalculator.getFee(_selectedBranch, _selectedCategory, _selectedPlan);
    _totalFee = fee ?? 0;

    if (widget.isRejoin) {
      _expiryDate = app_date_utils.DateUtils.calculateExpiryDate(_joiningDate, _selectedPlan);
    }

    _calculateFinalAmount();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _discountController.dispose();
    _discountDescController.dispose();
    _dueAmountController.dispose();
    _cashAmountController.dispose();
    _upiAmountController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _selectedCategory = category!;
      _selectedPlan = '';
    _totalFee = 0;
    _finalAmount = 0;
    _expiryDate = null;

    _availablePlans = FeeCalculator.getAvailablePlans(_selectedBranch, category);
    if (_availablePlans.isNotEmpty) {
      _selectedPlan = _availablePlans[0];
      _onPlanChanged(_selectedPlan);
    }
    });
  }

  void _onPlanChanged(String? plan) {
    setState(() {
      _selectedPlan = plan!;

      final fee = FeeCalculator.getFee(_selectedBranch, _selectedCategory, plan);
      _totalFee = fee ?? 0;
      _expiryDate = app_date_utils.DateUtils.calculateExpiryDate(_joiningDate, plan);
      _calculateFinalAmount();
    });
  }

  void _calculateFinalAmount() {
    final discount = double.tryParse(_discountController.text) ?? 0;

    setState(() {
      _finalAmount = FeeCalculator.calculateFinalAmount(_totalFee, discount);
    });
  }

  bool _validateMixedPayment() {
    if (_selectedPaymentMode != 'Mixed') return true;

    final cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
    final upiAmount = double.tryParse(_upiAmountController.text) ?? 0;

    return FeeCalculator.validateMixedPayment(_finalAmount, cashAmount, upiAmount);
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (widget.isRejoin && _selectedPaymentMode == 'Mixed' && !_validateMixedPayment()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cash + UPI amounts must equal Final Amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final discount = double.tryParse(_discountController.text) ?? 0;
      final dueAmount = double.tryParse(_dueAmountController.text) ?? 0;
      double cashAmount = 0;
      double upiAmount = 0;

      if (widget.isRejoin) {
        // For rejoin, calculate new payment amounts
        if (_selectedPaymentMode == 'Cash') {
          cashAmount = _finalAmount - dueAmount;
        } else if (_selectedPaymentMode == 'UPI') {
          upiAmount = _finalAmount - dueAmount;
        } else if (_selectedPaymentMode == 'Mixed') {
          cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
          upiAmount = double.tryParse(_upiAmountController.text) ?? 0;
        }
      } else {
        // For edit, keep existing payment amounts unless modified
        cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
        upiAmount = double.tryParse(_upiAmountController.text) ?? 0;
      }

      final updatedMember = widget.member.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _dateOfBirth,
        branch: _selectedBranch,
        category: _selectedCategory,
        plan: _selectedPlan,
        joiningDate: _joiningDate,
        expiryDate: _expiryDate!,
        paymentMode: widget.isRejoin ? _selectedPaymentMode : widget.member.paymentMode,
        totalFee: widget.isRejoin ? _totalFee : widget.member.totalFee,
        discount: widget.isRejoin ? discount : widget.member.discount,
        discountDescription: widget.isRejoin ? _discountDescController.text.trim() : widget.member.discountDescription,
        finalAmount: widget.isRejoin ? _finalAmount : widget.member.finalAmount,
        cashAmount: widget.isRejoin ? cashAmount : widget.member.cashAmount,
        upiAmount: widget.isRejoin ? upiAmount : widget.member.upiAmount,
        dueAmount: widget.isRejoin ? dueAmount : widget.member.dueAmount,
        isActive: app_date_utils.DateUtils.isActive(_expiryDate!),
      );

      await _firestoreService.updateMember(updatedMember);

      // Create renewal payment record if rejoining
      if (widget.isRejoin && (_finalAmount - dueAmount) > 0) {
        final payment = PaymentModel(
          id: '${widget.member.id}_renewal_${DateTime.now().millisecondsSinceEpoch}',
          memberId: widget.member.id,
          memberName: updatedMember.name,
          branch: updatedMember.branch,
          amount: _finalAmount - dueAmount,
          paymentMode: _selectedPaymentMode,
          cashAmount: cashAmount,
          upiAmount: upiAmount,
          type: 'renewal',
          paymentDate: DateTime.now(),
        );
        await _firestoreService.addPayment(payment);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isRejoin ? 'Member rejoined successfully' : 'Member updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRejoin ? 'Rejoin Member' : 'Edit Member'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.turquoise],
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.isRejoin)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.infoLight),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Rejoining member with new membership plan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Personal Details
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                validator: (value) => Validators.validateRequired(value, 'Name'),
                enabled: !widget.isRejoin,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                validator: Validators.validatePhone,
                enabled: !widget.isRejoin,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                validator: Validators.validateEmail,
                enabled: !widget.isRejoin,
              ),
              const SizedBox(height: 24),

              // Membership Details
              const Text(
                'Membership Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              CustomDropdown(
                label: 'Category *',
                value: _selectedCategory,
                items: AppConstants.categories,
                onChanged: widget.isRejoin
                ? (String? category) => _onCategoryChanged(category)  // Simplified
                : null,
                prefixIcon: Icons.fitness_center,
              ),

              const SizedBox(height: 16),

              CustomDropdown(
                label: 'Plan *',
                value: _selectedPlan,
                items: _availablePlans,
                onChanged: widget.isRejoin
                ? (String? plan) => _onPlanChanged(plan)  // Simplified
                : null,
                prefixIcon: Icons.calendar_today,
              ),

              const SizedBox(height: 16),

              if (_expiryDate != null)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: widget.isRejoin ? 'New Expiry Date' : 'Expiry Date',
                    prefixIcon: const Icon(Icons.event_busy),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.infoLight,
                  ),
                  child: Text(
                    app_date_utils.DateUtils.formatDate(_expiryDate!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                if (widget.isRejoin) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Payment Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Fee:', style: TextStyle(fontSize: 16)),
                        Text(
                          'Rs.${_totalFee.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _discountController,
                          decoration: InputDecoration(
                            labelText: 'Discount',
                            prefixIcon: const Icon(Icons.discount),
                            prefixText: 'Rs. ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _dueAmountController,
                          decoration: InputDecoration(
                            labelText: 'Due Amount',
                            prefixIcon: const Icon(Icons.pending_actions),
                            prefixText: 'Rs. ',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Final Amount:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rs.${_finalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  PaymentModeSelector(
                    selectedMode: _selectedPaymentMode,
                    onModeChanged: (mode) {
                      setState(() => _selectedPaymentMode = mode);
                    },
                  ),
                  const SizedBox(height: 16),

                  if (_selectedPaymentMode == 'Mixed')
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cashAmountController,
                            decoration: InputDecoration(
                              labelText: 'Cash Amount *',
                              prefixIcon: const Icon(Icons.money),
                              prefixText: 'Rs. ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _upiAmountController,
                            decoration: InputDecoration(
                              labelText: 'UPI Amount *',
                              prefixIcon: const Icon(Icons.qr_code),
                              prefixText: 'Rs. ',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                ],
                const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: _isLoading
      ? null
      : FloatingActionButton.extended(
        onPressed: _saveMember,
        icon: const Icon(Icons.save),
        label: Text(widget.isRejoin ? 'Rejoin' : 'Save'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
