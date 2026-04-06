import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/firestore_service.dart';
import '../../services/whatsapp_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'member_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';

class RejoinMemberScreen extends StatefulWidget {
  final MemberModel member;

  const RejoinMemberScreen({super.key, required this.member});

  @override
  State<RejoinMemberScreen> createState() => _RejoinMemberScreenState();
}

class _RejoinMemberScreenState extends State<RejoinMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers
  late final TextEditingController _totalFeeController;
  late final TextEditingController _discountController;
  late final TextEditingController _discountDescriptionController;
  late final TextEditingController _cashAmountController;
  late final TextEditingController _upiAmountController;

  // State variables
  late String _selectedCategory;
  late String _selectedPlan;
  String _paymentMode = 'Cash';
  double _finalAmount = 0;
  double _dueAmount = 0;
  DateTime _joiningDate = DateTime.now();
  late DateTime _expiryDate;
  bool _isProcessing = false;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _totalFeeController = TextEditingController();
    _discountController = TextEditingController(text: '0');
    _discountDescriptionController = TextEditingController();
    _cashAmountController = TextEditingController(text: '0');
    _upiAmountController = TextEditingController(text: '0');

    // Initialize state
    _selectedCategory = widget.member.category;
    _selectedPlan = widget.member.plan;
    _expiryDate = DateTime.now();

    // Set initial values
    _updateFeeFromConstants();
    _calculateExpiryDate();

    // Add listeners
    _totalFeeController.addListener(_onAmountChanged);
    _discountController.addListener(_onAmountChanged);
    _cashAmountController.addListener(_onPaymentChanged);
    _upiAmountController.addListener(_onPaymentChanged);
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    _totalFeeController.removeListener(_onAmountChanged);
    _discountController.removeListener(_onAmountChanged);
    _cashAmountController.removeListener(_onPaymentChanged);
    _upiAmountController.removeListener(_onPaymentChanged);

    // Dispose controllers
    _totalFeeController.dispose();
    _discountController.dispose();
    _discountDescriptionController.dispose();
    _cashAmountController.dispose();
    _upiAmountController.dispose();

    super.dispose();
  }

  void _updateFeeFromConstants() {
    final fee = AppConstants.feeStructure[widget.member.branch]
    ?[_selectedCategory]?[_selectedPlan] ?? 0;

    if (fee > 0) {
      _totalFeeController.text = fee.toString();
    } else {
      _totalFeeController.text = '';
    }
  }

  void _calculateExpiryDate() {
    setState(() {
      _expiryDate = app_date_utils.DateUtils.calculateExpiryDate(
        _joiningDate,
        _selectedPlan,
      );
    });
  }

  void _onAmountChanged() {
    final total = double.tryParse(_totalFeeController.text) ?? 0;
    final discount = double.tryParse(_discountController.text) ?? 0;

    if (mounted) {
      setState(() {
        _finalAmount = (total - discount).clamp(0, double.infinity);
      });
      _onPaymentChanged();
    }
  }

  void _onPaymentChanged() {
    final cash = double.tryParse(_cashAmountController.text) ?? 0;
    final upi = double.tryParse(_upiAmountController.text) ?? 0;

    if (mounted) {
      setState(() {
        _dueAmount = (_finalAmount - (cash + upi)).clamp(0, double.infinity);
      });
    }
  }

  Future<void> _selectRenewalDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: widget.member.expiryDate.subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select Renewal Start Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.success,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _joiningDate) {
      setState(() {
        _joiningDate = picked;
      });
      _calculateExpiryDate();
    }
  }

  Future<void> _rejoinMember() async {
    // Prevent duplicate submissions
    if (_hasSubmitted || _isProcessing) return;

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Validate final amount
    if (_finalAmount <= 0) {
      _showError('Please enter a valid total fee');
      return;
    }

    final cash = double.tryParse(_cashAmountController.text) ?? 0;
    final upi = double.tryParse(_upiAmountController.text) ?? 0;
    final totalPaid = cash + upi;

    // Validate payment
    if (totalPaid == 0) {
      _showError('Please enter payment amount');
      return;
    }

    // Warning for overpayment
    if (totalPaid > _finalAmount) {
      final confirm = await _showConfirmDialog(
        'Overpayment Detected',
        'Payment (Rs.${totalPaid.toStringAsFixed(0)}) exceeds final amount (Rs.${_finalAmount.toStringAsFixed(0)}). Continue?',
      );
      if (confirm != true) return;
    }

    setState(() {
      _isProcessing = true;
      _hasSubmitted = true;
    });

    try {
      // Create renewed member
      final renewedMember = widget.member.copyWith(
        category: _selectedCategory,
        plan: _selectedPlan,
        joiningDate: _joiningDate,
        expiryDate: _expiryDate,
        totalFee: double.parse(_totalFeeController.text),
        discount: double.parse(_discountController.text),
        discountDescription: _discountDescriptionController.text.trim(),
        finalAmount: _finalAmount,
        cashAmount: cash,
        upiAmount: upi,
        dueAmount: _dueAmount,
        isActive: true,
        paymentMode: _paymentMode,
      );

      // Update member in Firestore
      await _firestoreService.updateMember(renewedMember);

      // Create payment record
      final payment = PaymentModel(
        id: '${widget.member.id}_${DateTime.now().millisecondsSinceEpoch}',
        memberId: widget.member.id,
        memberName: widget.member.name,
        branch: widget.member.branch,
        amount: totalPaid,
        cashAmount: cash,
        upiAmount: upi,
        discount: double.tryParse(_discountController.text) ?? 0,
        paymentMode: _paymentMode,
        paymentDate: DateTime.now(),
        type: 'renewal',
      );

      await _firestoreService.addPayment(payment);

      final joinDate = widget.member.joiningDate;
      final monthsActive = DateTime.now().difference(joinDate).inDays ~/ 30;
      final alreadyAwarded = widget.member.loyaltyMilestonesAwarded;

      if (monthsActive >= 12 && !alreadyAwarded.contains('loyalty_1y')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': widget.member.id, 'event': 'loyalty_1y', 'timestamp': Timestamp.now(), 'processed': false,
        });
      } else if (monthsActive >= 6 && !alreadyAwarded.contains('loyalty_6m')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': widget.member.id, 'event': 'loyalty_6m', 'timestamp': Timestamp.now(), 'processed': false,
        });
      } else if (monthsActive >= 3 && !alreadyAwarded.contains('loyalty_3m')) {
        await FirebaseFirestore.instance.collection('gamification_events').add({
          'memberId': widget.member.id, 'event': 'loyalty_3m', 'timestamp': Timestamp.now(), 'processed': false,
        });
      }

      if (!mounted) return;

      // Show success and handle document sending
      await _handleSuccessFlow(renewedMember);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _hasSubmitted = false;
      });

      _showError('Error renewing membership: $e');
    }
  }

  Future<void> _handleSuccessFlow(MemberModel renewedMember) async {
    final sendDocs = await _showSuccessDialog(renewedMember);

    if (!mounted) return;

    if (sendDocs == true) {
      await _sendDocuments(renewedMember);
    }

    if (!mounted) return;

    // Navigate to member detail
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MemberDetailScreen(member: renewedMember),
      ),
      (route) => route.isFirst,
    );
  }

  Future<void> _sendDocuments(MemberModel member) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Preparing documents...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await WhatsAppService.instance.sendRejoinPackage(member);

      if (mounted) {
        Navigator.pop(context); // Close loading
        _showSuccess('Documents shared successfully!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showError('Error sharing documents: $e');
      }
    }
  }

  Future<bool?> _showSuccessDialog(MemberModel member) {
    final cash = double.tryParse(_cashAmountController.text) ?? 0;
    final upi = double.tryParse(_upiAmountController.text) ?? 0;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Membership Renewed!', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${member.name}!',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryCard([
              _buildSummaryRow('Plan', '$_selectedCategory - $_selectedPlan'),
              _buildSummaryRow('Start Date', app_date_utils.DateUtils.formatDate(_joiningDate)),
              _buildSummaryRow('New Expiry', app_date_utils.DateUtils.formatDate(_expiryDate)),
              const Divider(height: 16),
              _buildSummaryRow('Amount Paid', 'Rs.${(cash + upi).toStringAsFixed(0)}'),
              if (_dueAmount > 0)
                _buildSummaryRow('Due Amount', 'Rs.${_dueAmount.toStringAsFixed(0)}', valueColor: Colors.red),
            ]),
            const SizedBox(height: 16),
            _buildDocumentPrompt(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.send),
            label: const Text('Send Docs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDocumentPrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Send Rejoin Package?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Payment Invoice\n• Updated Membership Card',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onPaymentModeChanged(String mode) {
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
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop && _isProcessing) {
          _showError('Please wait, processing...');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rejoin Member'),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
            ),
          ),
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMemberInfoCard(),
              const SizedBox(height: 24),
              _buildMembershipSection(),
              const SizedBox(height: 24),
              _buildPaymentSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red.withValues(alpha: 0.2),
                  child: Text(
                    widget.member.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.member.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.member.phone,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EXPIRED',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Previous Plan',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${widget.member.category} - ${widget.member.plan}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expired On',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        app_date_utils.DateUtils.formatDate(widget.member.expiryDate),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('New Membership Details', Icons.fitness_center),
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
          onChanged: _isProcessing ? null : (value) {
            setState(() {
              _selectedCategory = value!;
            });
            _updateFeeFromConstants();
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
          onChanged: _isProcessing ? null : (value) {
            setState(() {
              _selectedPlan = value!;
            });
            _updateFeeFromConstants();
            _calculateExpiryDate();
          },
        ),
        const SizedBox(height: 16),
        _buildDateSection(),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: AppColors.success.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Renewal Start Date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app_date_utils.DateUtils.formatDate(_joiningDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _selectRenewalDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text('Change Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 20, color: AppColors.success),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You can backdate or future-date the renewal start date as needed',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.success.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.event_available, size: 20, color: AppColors.success),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Expiry Date',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app_date_utils.DateUtils.formatDate(_expiryDate),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Payment Details', Icons.payment),
        const SizedBox(height: 16),
        TextFormField(
          controller: _totalFeeController,
          keyboardType: TextInputType.number,
          enabled: !_isProcessing,
          decoration: InputDecoration(
            labelText: 'Total Fee',
            prefixIcon: const Icon(Icons.currency_rupee),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[100],
          ),
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
              child: TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                enabled: !_isProcessing,
                decoration: const InputDecoration(
                  labelText: 'Discount',
                  prefixIcon: Icon(Icons.discount),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: _discountDescriptionController,
                enabled: !_isProcessing,
                decoration: const InputDecoration(
                  labelText: 'Reason (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
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
        const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AppConstants.paymentModes.map((mode) {
            return ChoiceChip(
              label: Text(mode),
              selected: _paymentMode == mode,
              onSelected: _isProcessing ? null : (_) => _onPaymentModeChanged(mode),
              selectedColor: AppColors.success.withValues(alpha: 0.2),
              checkmarkColor: AppColors.success,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (_paymentMode == 'Cash' || _paymentMode == 'Mixed')
          TextFormField(
            controller: _cashAmountController,
            keyboardType: TextInputType.number,
            enabled: _paymentMode != 'UPI' && !_isProcessing,
            decoration: const InputDecoration(
              labelText: 'Cash Amount',
              prefixIcon: Icon(Icons.money),
              border: OutlineInputBorder(),
            ),
          ),
          if (_paymentMode == 'Mixed') const SizedBox(height: 16),
            if (_paymentMode == 'UPI' || _paymentMode == 'Mixed')
              TextFormField(
                controller: _upiAmountController,
                keyboardType: TextInputType.number,
                enabled: _paymentMode != 'Cash' && !_isProcessing,
                decoration: const InputDecoration(
                  labelText: 'UPI Amount',
                  prefixIcon: Icon(Icons.qr_code),
                  border: OutlineInputBorder(),
                ),
              ),
              if (_dueAmount > 0) ...[
                const SizedBox(height: 16),
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: (_isProcessing || _hasSubmitted) ? null : _rejoinMember,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textSecondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            Icon(Icons.refresh, size: 24),
            SizedBox(width: 8),
            Text(
              'Renew Membership',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            gradient: const LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success.withValues(alpha: 0.4), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
