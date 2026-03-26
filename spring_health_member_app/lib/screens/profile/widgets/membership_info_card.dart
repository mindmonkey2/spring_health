import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/member_model.dart';

class MembershipInfoCard extends StatelessWidget {
  final MemberModel member;

  const MembershipInfoCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonLime.withValues(alpha: 0.1),
            AppColors.turquoise.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_membership,
                  color: AppColors.neonLime,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEMBERSHIP DETAILS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neonLime,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.membershipPlan,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              _buildStatusBadge(),
            ],
          ),

          const SizedBox(height: 24),

          // Divider
          Container(height: 1, color: AppColors.gray400.withValues(alpha: 0.2)),

          const SizedBox(height: 24),

          // Membership Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Start Date',
                  DateFormat('dd MMM yyyy').format(member.membershipStartDate),
                  Icons.calendar_today,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.gray400.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildInfoItem(
                  'End Date',
                  DateFormat('dd MMM yyyy').format(member.membershipEndDate),
                  Icons.event,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Days Remaining',
                  '${member.daysRemaining} days',
                  Icons.timer,
                  valueColor: member.isExpiringSoon
                      ? AppColors.warning
                      : member.isExpired
                      ? AppColors.error
                      : AppColors.success,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: AppColors.gray400.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Branch',
                  member.branch,
                  Icons.location_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    if (member.isExpired) {
      badgeColor = AppColors.error;
      statusText = 'EXPIRED';
      statusIcon = Icons.cancel;
    } else if (member.isExpiringSoon) {
      badgeColor = AppColors.warning;
      statusText = 'EXPIRING SOON';
      statusIcon = Icons.warning;
    } else {
      badgeColor = AppColors.success;
      statusText = 'ACTIVE';
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: badgeColor, size: 16),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.gray400),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
