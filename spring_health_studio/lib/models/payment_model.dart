import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String memberId;
  final String memberName;
  final String branch;

  /// Total amount for this payment (after discount applied in your logic)
  final double amount;

  /// 'Cash', 'UPI', 'Both', etc.
  final String paymentMode;

  final double cashAmount;
  final double upiAmount;

  /// Discount given for this payment
  final double discount;

  /// 'initial', 'renewal', 'due', etc.
  final String type;

  final DateTime paymentDate;

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.branch,
    required this.amount,
    required this.paymentMode,
    this.cashAmount = 0,
    this.upiAmount = 0,
    this.discount = 0, // ✅ new with default
    required this.type,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'branch': branch,
      'amount': amount,
      'paymentMode': paymentMode,
      'cashAmount': cashAmount,
      'upiAmount': upiAmount,
      'discount': discount, // ✅ new
      'type': type,
      'paymentDate': Timestamp.fromDate(paymentDate),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] as String,
      memberId: map['memberId'] as String,
      memberName: map['memberName'] as String,
      branch: map['branch'] as String,
      amount: (map['amount'] as num).toDouble(),
      paymentMode: map['paymentMode'] as String,
      cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0,
      upiAmount: (map['upiAmount'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0, // ✅ safe read
      type: map['type'] as String,
      paymentDate: (map['paymentDate'] as Timestamp).toDate(),
    );
  }
}
