import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String memberId;
  final double amount;
  final String planName;
  final String paymentMode; // cash, upi, card, online
  final String status; // paid, pending, failed
  final DateTime paymentDate;
  final DateTime membershipStartDate;
  final DateTime membershipEndDate;
  final String? transactionId;
  final String? notes;
  final String collectedBy; // staff name

  PaymentModel({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.planName,
    required this.paymentMode,
    required this.status,
    required this.paymentDate,
    required this.membershipStartDate,
    required this.membershipEndDate,
    this.transactionId,
    this.notes,
    required this.collectedBy,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      memberId: data['memberId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      planName: data['planName'] ?? '',
      paymentMode: data['paymentMode'] ?? 'cash',
      status: data['status'] ?? 'paid',
      paymentDate:
          (data['paymentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      membershipStartDate:
          (data['membershipStartDate'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      membershipEndDate:
          (data['membershipEndDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionId: data['transactionId'],
      notes: data['notes'],
      collectedBy: data['collectedBy'] ?? 'Staff',
    );
  }

  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'amount': amount,
      'planName': planName,
      'paymentMode': paymentMode,
      'status': status,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'membershipStartDate': Timestamp.fromDate(membershipStartDate),
      'membershipEndDate': Timestamp.fromDate(membershipEndDate),
      'transactionId': transactionId,
      'notes': notes,
      'collectedBy': collectedBy,
    };
  }
}
