// lib/screens/renewal/renewal_screen.dart
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/member_model.dart';
import '../../services/renewal_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/config/app_config.dart';
import 'renewal_confirmation_screen.dart';

/// Renewal plans: label → days. Prices pulled from branch constants.
/// Kept inline to avoid coupling with Studio's constants.dart.
const Map<String, _RenewalPlan> _kPlans = {
  '1 Month': _RenewalPlan(days: 30, hanamkondaPrice: 700, warangalPrice: 800),
  '3 Months': _RenewalPlan(
    days: 90,
    hanamkondaPrice: 1950,
    warangalPrice: 2100,
  ),
  '6 Months': _RenewalPlan(
    days: 180,
    hanamkondaPrice: 3600,
    warangalPrice: 3900,
  ),
  '1 Year': _RenewalPlan(days: 365, hanamkondaPrice: 6500, warangalPrice: 7000),
};

class RenewalScreen extends StatefulWidget {
  final MemberModel member;
  const RenewalScreen({super.key, required this.member});

  @override
  State<RenewalScreen> createState() => _RenewalScreenState();
}

class _RenewalScreenState extends State<RenewalScreen> {
  final RenewalService _renewalService = RenewalService();
  late Razorpay _razorpay;

  String _selectedPlan = '1 Month';
  final ValueNotifier<bool> _processingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _processingNotifier.dispose();
    super.dispose();
  }

  int _priceForPlan(String planKey) {
    final plan = _kPlans[planKey]!;
    return widget.member.branch == 'Hanamkonda'
        ? plan.hanamkondaPrice
        : plan.warangalPrice;
  }

  void _openRazorpay() {
    final price = _priceForPlan(_selectedPlan);
    final options = {
      'key': AppConfig.razorpayKey,
      'amount': price * 100, // paise
      'name': 'Spring Health Studio',
      'description': '$_selectedPlan Membership Renewal',
      'prefill': {'contact': widget.member.phone, 'name': widget.member.name},
      'theme': {'color': '#00C853'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnack('Failed to open payment: $e');
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Razorpay Success: ${response.paymentId}');
    if (!mounted) return;
    _processingNotifier.value = true;
    try {
      final plan = _kPlans[_selectedPlan]!;
      await _renewalService.processSuccessfulRenewal(
        memberId: widget.member.id,
        memberPhone: widget.member.phone,
        branch: widget.member.branch,
        plan: _selectedPlan,
        planDays: plan.days,
        amount: _priceForPlan(_selectedPlan).toDouble(),
        razorpayPaymentId: response.paymentId ?? '',
        currentExpiry: widget.member.expiryDate,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RenewalConfirmationScreen(
              memberName: widget.member.name,
              plan: _selectedPlan,
              amountPaid: _priceForPlan(_selectedPlan).toDouble(),
              paymentId: response.paymentId ?? '',
              planDays: plan.days,
              currentExpiry: widget.member.expiryDate,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Razorpay Update Error: $e');
      _showSnack('Payment recorded but update failed. Contact gym.');
    } finally {
      if (mounted) _processingNotifier.value = false;
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    debugPrint(
      'Razorpay Error: code=${response.code} message=${response.message}',
    );
    _showSnack('Payment failed: ${response.message ?? 'Unknown error'}');
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay External Wallet: ${response.walletName}');
    _showSnack('External wallet selected: ${response.walletName ?? ''}');
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.neonTeal.withValues(alpha: 0.5)),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Renew Membership',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _processingNotifier,
        builder: (context, isProcessing, child) {
          if (isProcessing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.neonLime),
                  SizedBox(height: 16),
                  Text(
                    'Processing renewal...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMemberCard(),
                const SizedBox(height: 24),
                const Text(
                  'Select Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ..._kPlans.keys.map((key) => _buildPlanTile(key)),
                const SizedBox(height: 32),
                _buildPayButton(),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Secured by Razorpay',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberCard() {
    final expiry = widget.member.expiryDate;
    final now = DateTime.now();
    final isExpired = expiry.isBefore(now);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonTeal.withValues(alpha: 0.15),
            AppColors.neonLime.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.neonTeal.withValues(alpha: 0.2),
            radius: 26,
            child: Text(
              widget.member.name.isNotEmpty
                  ? widget.member.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: AppColors.neonTeal,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.member.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  widget.member.branch,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isExpired ? Icons.cancel : Icons.access_time,
                      size: 13,
                      color: isExpired ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpired
                          ? 'Expired · ${_formatDate(expiry)}'
                          : 'Expires ${_formatDate(expiry)}',
                      style: TextStyle(
                        color: isExpired ? Colors.red : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTile(String key) {
    final plan = _kPlans[key]!;
    final price = _priceForPlan(key);
    final isSelected = _selectedPlan == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonLime.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.neonLime
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.neonLime : Colors.white38,
                  width: 2,
                ),
                color: isSelected ? AppColors.neonLime : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.black, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: TextStyle(
                      color: isSelected ? AppColors.neonLime : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${plan.days} days',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              'Rs. $price',
              style: TextStyle(
                color: isSelected ? AppColors.neonLime : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    final price = _priceForPlan(_selectedPlan);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _openRazorpay,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonLime,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pay Rs. $price',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

// Private data class — no unused fields
class _RenewalPlan {
  final int days;
  final int hanamkondaPrice;
  final int warangalPrice;
  const _RenewalPlan({
    required this.days,
    required this.hanamkondaPrice,
    required this.warangalPrice,
  });
}
