import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_model.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Get all payments for a member (real-time stream)
  Stream<List<PaymentModel>> getPaymentsByMember(String memberId) {
    return _firestore
        .collection('payments')
        .where('memberId', isEqualTo: memberId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PaymentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // ✅ Get total paid amount
  Future<double> getTotalPaid(String memberId) async {
    final snapshot = await _firestore
        .collection('payments')
        .where('memberId', isEqualTo: memberId)
        .where('status', isEqualTo: 'paid')
        .get();

    double total = 0;
    for (final doc in snapshot.docs) {
      total += (doc.data()['amount'] ?? 0).toDouble();
    }
    return total;
  }
}
