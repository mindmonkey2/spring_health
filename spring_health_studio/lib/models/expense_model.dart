import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String category;
  final String description;
  final double amount;
  final String paymentMode;
  final DateTime expenseDate;
  final String? branch;
  final String? receiptUrl;
  final String addedBy;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.paymentMode,
    required this.expenseDate,
    this.branch,
    this.receiptUrl,
    required this.addedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'description': description,
      'amount': amount,
      'paymentMode': paymentMode,
      'expenseDate': Timestamp.fromDate(expenseDate),
      'branch': branch,
      'receiptUrl': receiptUrl,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentMode: map['paymentMode'] ?? 'Cash',
      expenseDate: (map['expenseDate'] as Timestamp).toDate(),
      branch: map['branch'],
      receiptUrl: map['receiptUrl'],
      addedBy: map['addedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

// Expense Categories
class ExpenseCategories {
  static const List<String> categories = [
    'Rent',
    'Utilities',
    'Salaries',
    'Equipment Purchase',
    'Equipment Maintenance',
    'Supplements',
    'Marketing',
    'Cleaning Supplies',
    'Office Supplies',
    'Insurance',
    'Taxes',
    'Miscellaneous',
  ];

  static const Map<String, String> categoryIcons = {
    'Rent': 'Office',
    'Utilities': 'Energy',
    'Salaries': 'Money',
    'Equipment Purchase': 'Cart',
    'Equipment Maintenance': 'Wrench',
    'Supplements': 'Pill',
    'Marketing': 'Announcement',
    'Cleaning Supplies': 'Broom',
    'Office Supplies': 'Attachment',
    'Insurance': '',
    'Taxes': 'Chart',
    'Miscellaneous': 'Box',
  };
}
