import 'package:flutter/material.dart';
import '../../models/expense_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/date_utils.dart' as app_date_utils;
import 'add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  final String? branch;

  const ExpensesScreen({super.key, this.branch});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _firestoreService = FirestoreService();
  String _selectedDateRange = 'This Month';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Wellness & Balance Colors
  static const Color sageGreen = Color(0xFF10B981);
  static const Color tealAqua = Color(0xFF14B8A6);

  static const Color softCoral = Color(0xFFF87171);

  @override
  void initState() {
    super.initState();
    _setDateRange('This Month');
  }

  void _setDateRange(String range) {
    final today = DateTime.now();
    setState(() {
      _selectedDateRange = range;
      switch (range) {
        case 'Today':
          _startDate = DateTime(today.year, today.month, today.day, 0, 0, 0);
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'This Week':
          final weekday = today.weekday;
          _startDate = DateTime(today.year, today.month, today.day).subtract(Duration(days: weekday - 1));
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'This Month':
          _startDate = DateTime(today.year, today.month, 1);
          _endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);
          break;
        case 'Last Month':
          final lastMonth = DateTime(today.year, today.month - 1, 1);
          _startDate = lastMonth;
          _endDate = DateTime(today.year, today.month, 0, 23, 59, 59);
          break;
      }
    });
  }

  Future<void> _addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(branch: widget.branch), // ✅ Fixed
      ),
    );

    if (result == true && mounted) { // ✅ Added mounted check
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully'),
          backgroundColor: sageGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
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
      body: Column(
        children: [
          // Date Range Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.date_range, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'Today',
                      'This Week',
                      'This Month',
                      'Last Month',
                    ].map((range) {
                      final isSelected = _selectedDateRange == range;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(range),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) _setDateRange(range);
                          },
                          selectedColor: sageGreen.withValues(alpha: 0.2),
                          checkmarkColor: sageGreen,
                          backgroundColor: Colors.grey[100],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Expenses List
          Expanded(
            child: StreamBuilder<List<ExpenseModel>>(
              stream: _firestoreService.getExpensesForDateRange(
                widget.branch,
                _startDate,
                _endDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses recorded',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate total
                final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

                return Column(
                  children: [
                    // Total Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [softCoral, Colors.deepOrange],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Expenses',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Expenses List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          final expense = expenses[index];
                          return _buildExpenseCard(expense);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: sageGreen,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseModel expense) {
    final icon = ExpenseCategories.categoryIcons[expense.category] ?? 'Box';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // ✅ Reduced padding
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: softCoral.withValues(alpha: 0.2),
          child: Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          expense.category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              expense.description,
              maxLines: 1, // ✅ Changed to 1 line
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2), // ✅ Reduced spacing
            Text(
              app_date_utils.DateUtils.formatDate(expense.expenseDate),
              style: TextStyle(fontSize: 11, color: Colors.grey[600]), // ✅ Smaller font
            ),
          ],
        ),
        trailing: SizedBox(
          width: 90, // ✅ Slightly reduced width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${expense.amount.toStringAsFixed(0)}', // ✅ No decimals to save space
                style: const TextStyle(
                  fontSize: 16, // ✅ Reduced from 18
                  fontWeight: FontWeight.bold,
                  color: softCoral,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // ✅ Reduced spacing
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // ✅ Reduced padding
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  expense.paymentMode,
                  style: const TextStyle(
                    fontSize: 9, // ✅ Reduced from 10
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          // Show expense details
          _showExpenseDetails(expense);
        },
      ),
    );
  }

  // ✅ ADDED: Show expense details dialog
  void _showExpenseDetails(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              ExpenseCategories.categoryIcons[expense.category] ?? 'Box',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                expense.category,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', '₹${expense.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            _buildDetailRow('Description', expense.description),
            const SizedBox(height: 12),
            _buildDetailRow('Date', app_date_utils.DateUtils.formatDate(expense.expenseDate)),
            const SizedBox(height: 12),
            _buildDetailRow('Payment Mode', expense.paymentMode),
            if (expense.branch != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Branch', expense.branch!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ✅ ADDED: Helper for detail rows
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
