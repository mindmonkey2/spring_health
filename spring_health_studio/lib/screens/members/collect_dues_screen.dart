import 'package:flutter/material.dart';
import '../../models/member_model.dart';
import '../../models/payment_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/validators.dart';
import '../../widgets/document_send_dialog.dart';
import '../../widgets/payment_mode_selector.dart';

class CollectDuesScreen extends StatefulWidget {
  final MemberModel member;

  const CollectDuesScreen({super.key, required this.member});

  @override
  State<CollectDuesScreen> createState() => _CollectDuesScreenState();
}

class _CollectDuesScreenState extends State<CollectDuesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _amountController = TextEditingController();
  final _cashAmountController = TextEditingController(text: '0');
  final _upiAmountController = TextEditingController(text: '0');
  String _selectedPaymentMode = 'Cash';
  bool _isLoading = false;

  // Colors
  static const Color primaryPurple = Color(0xFF6366F1);
  static const Color accentPink = Color(0xFFEC4899);

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.member.dueAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _cashAmountController.dispose();
    _upiAmountController.dispose();
    super.dispose();
  }

  bool _validateMixedPayment() {
    if (_selectedPaymentMode != 'Mixed') return true;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
    final upiAmount = double.tryParse(_upiAmountController.text) ?? 0;
    return (cashAmount + upiAmount) == amount;
  }

  Future<void> _collectDues() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPaymentMode == 'Mixed' && !_validateMixedPayment()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cash + UPI amounts must equal collection amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final collectionAmount = double.tryParse(_amountController.text) ?? 0;
      if (collectionAmount <= 0) {
        throw Exception('Collection amount must be greater than 0');
      }

      if (collectionAmount > widget.member.dueAmount) {
        throw Exception('Collection amount cannot exceed due amount');
      }

      // Calculate payment breakdown
      double cashAmount = 0;
      double upiAmount = 0;
      if (_selectedPaymentMode == 'Cash') {
        cashAmount = collectionAmount;
      } else if (_selectedPaymentMode == 'UPI') {
        upiAmount = collectionAmount;
      } else if (_selectedPaymentMode == 'Mixed') {
        cashAmount = double.tryParse(_cashAmountController.text) ?? 0;
        upiAmount = double.tryParse(_upiAmountController.text) ?? 0;
      }

      // Update member's due amount and cash/UPI totals
      final newDueAmount = widget.member.dueAmount - collectionAmount;
      final updatedMember = widget.member.copyWith(
        dueAmount: newDueAmount,
        cashAmount: widget.member.cashAmount + cashAmount,
        upiAmount: widget.member.upiAmount + upiAmount,
      );

      await _firestoreService.updateMember(updatedMember);

      // Create payment record
      final payment = PaymentModel(
        id: '${widget.member.id}_due_${DateTime.now().millisecondsSinceEpoch}',
        memberId: widget.member.id,
        memberName: widget.member.name,
        branch: widget.member.branch,
        amount: collectionAmount,
        paymentMode: _selectedPaymentMode,
        cashAmount: cashAmount,
        upiAmount: upiAmount,
        type: 'due',
        paymentDate: DateTime.now(),
      );

      await _firestoreService.addPayment(payment);

      if (!mounted) return;

      // Show success dialog with receipt sending option
      final sendReceipt = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => DocumentSendDialog(
          member: updatedMember,
          documentType: 'receipt',
          payment: payment,
          title: 'Payment Received! 💰',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment of ₹${collectionAmount.toStringAsFixed(0)} received from ${updatedMember.name}',
                style: const TextStyle(fontSize: 15),
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
                    _buildSummaryRow('Amount Paid:', '₹${collectionAmount.toStringAsFixed(0)}'),
                    _buildSummaryRow('Payment Mode:', _selectedPaymentMode),
                    if (_selectedPaymentMode == 'Mixed') ...[
                      _buildSummaryRow(' • Cash:', '₹${cashAmount.toStringAsFixed(0)}'),
                      _buildSummaryRow(' • UPI:', '₹${upiAmount.toStringAsFixed(0)}'),
                    ],
                    const Divider(height: 16),
                    _buildSummaryRow(
                      'Remaining Due:',
                      newDueAmount > 0
                      ? '₹${newDueAmount.toStringAsFixed(0)}'
                    : '✅ Fully Paid',
                    valueColor: newDueAmount > 0 ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Send Payment Receipt?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share invoice with payment details',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      if (sendReceipt == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final collectionAmount = double.tryParse(_amountController.text) ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collect Dues'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryPurple, Color(0xFF8B5CF6), accentPink],
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
            // Member Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Member Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Name: ${widget.member.name}'),
                    Text('ID: ${widget.member.id}'),
                    Text('Phone: ${widget.member.phone}'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Due Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${widget.member.dueAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Collection Amount
            const Text(
              'Collection Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Collection Amount *',
                prefixIcon: const Icon(Icons.currency_rupee),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                helperText: 'Maximum: ₹${widget.member.dueAmount.toStringAsFixed(0)}',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }

                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }

                if (amount > widget.member.dueAmount) {
                  return 'Amount exceeds due amount';
                }

                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // Payment Mode
            PaymentModeSelector(
              selectedMode: _selectedPaymentMode,
              onModeChanged: (mode) {
                setState(() {
                  _selectedPaymentMode = mode;
                  _cashAmountController.text = '0';
                _upiAmountController.text = '0';
                });
              },
            ),
            const SizedBox(height: 16),

            // Mixed Payment Fields
            if (_selectedPaymentMode == 'Mixed') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cashAmountController,
                      decoration: InputDecoration(
                        labelText: 'Cash Amount *',
                        prefixIcon: const Icon(Icons.money),
                        prefixText: '₹ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateNumber(value, 'Cash Amount'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _upiAmountController,
                      decoration: InputDecoration(
                        labelText: 'UPI Amount *',
                        prefixIcon: const Icon(Icons.qr_code),
                        prefixText: '₹ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateNumber(value, 'UPI Amount'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cash + UPI must equal ₹${collectionAmount.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Collecting:'),
                      Text(
                        '₹${collectionAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Remaining Due:'),
                      Text(
                        '₹${(widget.member.dueAmount - collectionAmount).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: (widget.member.dueAmount - collectionAmount) > 0
                          ? Colors.red
                          : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: _isLoading
      ? null
      : FloatingActionButton.extended(
        onPressed: _collectDues,
        icon: const Icon(Icons.check_circle),
        label: const Text('Collect Dues'),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
