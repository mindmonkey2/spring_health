// lib/screens/renewal/renewal_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RenewalConfirmationScreen extends StatelessWidget {
  final String memberName;
  final String plan;
  final double amountPaid;
  final String paymentId;
  final int planDays;
  final DateTime currentExpiry;

  const RenewalConfirmationScreen({
    super.key,
    required this.memberName,
    required this.plan,
    required this.amountPaid,
    required this.paymentId,
    required this.planDays,
    required this.currentExpiry,
  });

  DateTime get _newExpiry {
    final now = DateTime.now();
    final base = currentExpiry.isBefore(now) ? now : currentExpiry;
    return base.add(Duration(days: planDays));
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success animation ring
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonLime.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.neonLime, width: 2),
                ),
                child: const Icon(Icons.check_circle_outline,
                                  color: AppColors.neonLime, size: 56),
              ),
              const SizedBox(height: 24),
              const Text(
                'Membership Renewed!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hey $memberName, you\'re all set!',
                style: const TextStyle(
                  color: Colors.white60, fontSize: 14),
                   textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildDetailCard(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to home, removing renewal screens
                    Navigator.of(context)
                    .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildDetailRow('Plan', plan),
          _buildDivider(),
          _buildDetailRow(
            'Amount Paid', 'Rs. ${amountPaid.toInt()}'),
            _buildDivider(),
            _buildDetailRow(
              'New Expiry', _formatDate(_newExpiry),
              valueColor: AppColors.neonLime),
              _buildDivider(),
              _buildDetailRow('Payment ID', paymentId,
                              valueColor: Colors.white54,
                              valueFontSize: 11),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
      Color valueColor = Colors.white,
      double valueFontSize = 14,
    }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
               style: const TextStyle(
                 color: Colors.white54, fontSize: 13)),
                 Flexible(
                   child: Text(
                     value,
                     style: TextStyle(
                       color: valueColor,
                       fontSize: valueFontSize,
                       fontWeight: FontWeight.w600,
                     ),
                     textAlign: TextAlign.right,
                   ),
                 ),
        ],
      ),
    );
    }

    Widget _buildDivider() {
      return Divider(
        color: Colors.white.withValues(alpha: 0.07), height: 1);
    }
}
