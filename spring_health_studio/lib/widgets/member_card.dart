import 'package:flutter/material.dart';

import '../models/member_model.dart';

import '../utils/date_utils.dart' as app_date_utils;

import '../theme/app_colors.dart';

/// Modern member card with improved styling and subtle glow effects
class MemberCard extends StatelessWidget {
  final MemberModel member;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = app_date_utils.DateUtils.daysUntilExpiry(member.expiryDate);
    final isExpiringSoon = daysLeft >= 0 && daysLeft <= 7;
    final isActive = member.isActive;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isActive
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isActive
        ? Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 1,
        )
        : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar with gradient border
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    gradient: isActive
                    ? AppColors.successGradient
                    : AppColors.errorGradient,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: isActive
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                    child: Text(
                      member.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Member Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              member.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Status Badge
                          _buildStatusBadge(isActive),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${member.category} • ${member.plan}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            member.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: isExpiringSoon
                            ? AppColors.warning
                            : AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires: ${app_date_utils.DateUtils.formatDate(member.expiryDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isExpiringSoon
                              ? AppColors.warningDark
                              : AppColors.textSecondary,
                              fontWeight:
                              isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (isExpiringSoon) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$daysLeft days',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warningDark,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (member.dueAmount > 0) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Due: Rs.${member.dueAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow Icon - FIXED: Removed const from Container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: isActive
        ? LinearGradient(
          colors: [
            AppColors.success.withValues(alpha: 0.2),
            AppColors.turquoise.withValues(alpha: 0.15),
          ],
        )
        : LinearGradient(
          colors: [
            AppColors.error.withValues(alpha: 0.2),
            AppColors.coral.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
          ? AppColors.success.withValues(alpha: 0.3)
          : AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Expired',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }
}
