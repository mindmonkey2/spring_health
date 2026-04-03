import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/expense_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart' as app_date_utils;

class AddExpenseScreen extends StatefulWidget {
  final String? branch;

  const AddExpenseScreen({super.key, this.branch});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  // Controllers
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form state
  String _selectedCategory = ExpenseCategories.categories.first;
  String _selectedPaymentMode = 'Cash';
  String _selectedBranch = '';
  DateTime _expenseDate = DateTime.now();
  bool _isProcessing = false;

  // Colors
  static const Color sageGreen = Color(0xFF10B981);
  static const Color tealAqua = Color(0xFF14B8A6);


  @override
  void initState() {
    super.initState();
    _selectedBranch = widget.branch ?? AppConstants.branches.first;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: sageGreen,
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
        _expenseDate = picked;
      });
    }
  }

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final expenseId = const Uuid().v4();

      final expense = ExpenseModel(
        id: expenseId,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        amount: amount,
        paymentMode: _selectedPaymentMode,
        expenseDate: _expenseDate,
        branch: _selectedBranch,
        addedBy: user?.email ?? 'Unknown',
        createdAt: DateTime.now(),
      );

      await _firestoreService.addExpense(expense);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
        title: const Text('Add Expense'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [sageGreen, tealAqua],
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
            // Category Selection
            _buildSectionHeader('Expense Details', Icons.receipt),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: ExpenseCategories.categories.map((category) {
                final icon = ExpenseCategories.categoryIcons[category] ?? 'Box';
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.currency_rupee),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Expense Date
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expense Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(app_date_utils.DateUtils.formatDate(_expenseDate)),
              ),
            ),

            const SizedBox(height: 32),

            // Payment Details
            _buildSectionHeader('Payment Details', Icons.payment),
            const SizedBox(height: 16),

            // Payment Mode
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
                  selected: _selectedPaymentMode == mode,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMode = mode;
                    });
                  },
                  selectedColor: sageGreen.withValues(alpha: 0.2),
                  checkmarkColor: sageGreen,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Branch
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

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _addExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sageGreen,
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
                        Icon(Icons.add, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Add Expense',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            gradient: const LinearGradient(
              colors: [sageGreen, tealAqua],
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
                  sageGreen.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
