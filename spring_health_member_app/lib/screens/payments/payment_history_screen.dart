import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/payment_model.dart';
import '../../services/payment_service.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const PaymentHistoryScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final PaymentService _paymentService = PaymentService();
  String _selectedFilter = 'all'; // all, paid, pending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: const Text('Payment History'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: AppColors.neonLime),
            color: AppColors.cardSurface,
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (context) => [
              _buildFilterItem('all', 'All Payments'),
              _buildFilterItem('paid', 'Paid Only'),
              _buildFilterItem('pending', 'Pending Only'),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<PaymentModel>>(
        stream: _paymentService.getPaymentsByMember(widget.memberId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final allPayments = snapshot.data!;
          final filtered = _filterPayments(allPayments);

          return RefreshIndicator(
            color: AppColors.neonLime,
            backgroundColor: AppColors.cardSurface,
            onRefresh: () async => setState(() {}),
            child: CustomScrollView(
              slivers: [
                // ✅ Summary Card
                SliverToBoxAdapter(child: _buildSummaryCard(allPayments)),

                // ✅ Filter Chips
                SliverToBoxAdapter(child: _buildFilterChips()),

                // ✅ Payment List Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TRANSACTIONS',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          '${filtered.length} records',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Payment Items
                filtered.isEmpty
                    ? SliverFillRemaining(child: _buildNoDataForFilter())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildPaymentCard(filtered[index]),
                          childCount: filtered.length,
                        ),
                      ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Summary Card
  Widget _buildSummaryCard(List<PaymentModel> payments) {
    final paid = payments.where((p) => p.status == 'paid');
    final totalPaid = paid.fold(0.0, (sum, p) => sum + p.amount);
    final totalCount = paid.length;
    final pending = payments.where((p) => p.status == 'pending').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.2),
            AppColors.neonTeal.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PAID',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalCount payments',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neonLime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rs.${NumberFormat('#,##,###').format(totalPaid)}',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.neonLime,
              fontSize: 42,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryItem(
                Icons.check_circle_rounded,
                '$totalCount Paid',
                AppColors.neonLime,
              ),
              const SizedBox(width: 24),
              if (pending > 0)
                _buildSummaryItem(
                  Icons.pending_rounded,
                  '$pending Pending',
                  AppColors.neonOrange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ✅ Filter Chips
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip('all', 'All'),
          const SizedBox(width: 8),
          _buildChip('paid', 'Paid'),
          const SizedBox(width: 8),
          _buildChip('pending', 'Pending'),
        ],
      ),
    );
  }

  Widget _buildChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonLime.withValues(alpha: 0.2)
              : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonLime : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.neonLime : AppColors.gray400,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ✅ Individual Payment Card
  Widget _buildPaymentCard(PaymentModel payment) {
    final isPaid = payment.status == 'paid';
    final statusColor = isPaid ? AppColors.neonLime : AppColors.neonOrange;

    return GestureDetector(
      onTap: () => _showReceiptDialog(payment),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Payment mode icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPaymentModeIcon(payment.paymentMode),
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Plan name & date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.planName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(payment.paymentDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Amount & status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs.${NumberFormat('#,##,###').format(payment.amount)}',
                      style: AppTextStyles.heading3.copyWith(
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        payment.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 10),
            // Bottom row - payment mode & validity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.payment_rounded,
                      size: 12,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      payment.paymentMode.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.date_range_rounded,
                      size: 12,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${DateFormat('dd MMM').format(payment.membershipStartDate)} → ${DateFormat('dd MMM yy').format(payment.membershipEndDate)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 12,
                      color: AppColors.neonTeal,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'VIEW',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neonTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Receipt Dialog
  void _showReceiptDialog(PaymentModel payment) {
    final isPaid = payment.status == 'paid';
    final statusColor = isPaid ? AppColors.neonLime : AppColors.neonOrange;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RECEIPT',
                    style: AppTextStyles.heading3.copyWith(
                      color: statusColor,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.gray400,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Spring Health Gym',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
              ),
              const SizedBox(height: 20),

              // Amount
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'AMOUNT PAID',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${NumberFormat('#,##,###').format(payment.amount)}',
                      style: AppTextStyles.heading1.copyWith(
                        color: statusColor,
                        fontSize: 38,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details
              _buildReceiptRow('Plan', payment.planName, AppColors.white),
              _buildReceiptRow(
                'Date',
                DateFormat('dd MMM yyyy').format(payment.paymentDate),
                AppColors.white,
              ),
              _buildReceiptRow(
                'Mode',
                payment.paymentMode.toUpperCase(),
                AppColors.neonTeal,
              ),
              _buildReceiptRow(
                'Status',
                payment.status.toUpperCase(),
                statusColor,
              ),
              _buildReceiptRow(
                'Valid From',
                DateFormat('dd MMM yyyy').format(payment.membershipStartDate),
                AppColors.white,
              ),
              _buildReceiptRow(
                'Valid Until',
                DateFormat('dd MMM yyyy').format(payment.membershipEndDate),
                AppColors.white,
              ),
              _buildReceiptRow(
                'Collected By',
                payment.collectedBy,
                AppColors.white,
              ),
              if (payment.transactionId != null)
                _buildReceiptRow(
                  'Txn ID',
                  payment.transactionId!,
                  AppColors.gray400,
                ),

              const SizedBox(height: 16),
              const Divider(color: Colors.white10),
              const SizedBox(height: 12),

              // Copy Txn ID button
              if (payment.transactionId != null)
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: payment.transactionId!),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction ID copied!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Transaction ID'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.neonTeal,
                  ),
                ),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Helper Methods
  List<PaymentModel> _filterPayments(List<PaymentModel> payments) {
    switch (_selectedFilter) {
      case 'paid':
        return payments.where((p) => p.status == 'paid').toList();
      case 'pending':
        return payments.where((p) => p.status == 'pending').toList();
      default:
        return payments;
    }
  }

  IconData _getPaymentModeIcon(String mode) {
    switch (mode.toLowerCase()) {
      case 'upi':
        return Icons.qr_code_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'online':
        return Icons.language_rounded;
      case 'cash':
      default:
        return Icons.payments_rounded;
    }
  }

  PopupMenuItem<String> _buildFilterItem(String value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      ),
    );
  }

  // ✅ State Widgets
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.neonLime, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'LOADING PAYMENTS...',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.heading3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.gray400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Payments Yet',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment history will appear here',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_off, size: 48, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different filter',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
