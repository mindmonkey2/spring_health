// lib/services/renewal_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RenewalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Writes a renewal payment record and extends member expiry.
  /// [memberId]    — Firestore doc ID in `members`
  /// [memberPhone] — member phone (used as branch-agnostic identifier)
  /// [branch]      — member's branch
  /// [plan]        — selected plan label, e.g. "1 Month"
  /// [planDays]    — number of days the plan adds
  /// [amount]      — amount paid online (paise converted to rupees)
  /// [razorpayPaymentId] — Razorpay payment ID for reference
  /// [currentExpiry] — member's current expiry date
  Future<void> recordRenewal({
    required String memberId,
    required String memberPhone,
    required String branch,
    required String plan,
    required int planDays,
    required double amount,
    required String razorpayPaymentId,
    required DateTime currentExpiry,
  }) async {
    final now = DateTime.now();

    // Extend from today if already expired, else extend from current expiry
    final baseDate = currentExpiry.isBefore(now) ? now : currentExpiry;
    final newExpiry = baseDate.add(Duration(days: planDays));

    final batch = _db.batch();

    // 1. Payment record (mirrors PaymentModel schema)
    final paymentRef = _db.collection('payments').doc();
    batch.set(paymentRef, {
      'memberId': memberId,
      'memberPhone': memberPhone,
      'branch': branch,
      'amount': amount,
      'mode': 'online',
      'type': 'renewal',
      'plan': plan,
      'razorpayPaymentId': razorpayPaymentId,
      'createdAt': Timestamp.fromDate(now),
      'month': now.month,
      'year': now.year,
    });

    // 2. Update member expiry + isActive
    final memberRef = _db.collection('members').doc(memberId);
    batch.update(memberRef, {
      'expiryDate': Timestamp.fromDate(newExpiry),
      'isActive': true,
      'lastRenewedAt': Timestamp.fromDate(now),
      'plan': plan,
    });

    await batch.commit();
  }
}
