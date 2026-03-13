import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/member_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final MemberModel member;
  final VoidCallback? onEditPhoto;

  const ProfileHeaderWidget({
    super.key,
    required this.member,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.1),
            AppColors.neonTeal.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Photo with Neon Border
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonLime.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.cardSurface,
                  backgroundImage: member.photoUrl != null
                  ? NetworkImage(member.photoUrl!)
                  : null,
                  child: member.photoUrl == null
                  ? Text(
                    member.name.isNotEmpty
                    ? member.name[0].toUpperCase()
                    : 'M',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime,
                    ),
                  )
                  : null,
                ),
              ),
              if (onEditPhoto != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onEditPhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonLime,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundBlack,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Member Name
          Text(
            member.name,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Phone Number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_outlined,
                size: 16,
                color: AppColors.gray400,
              ),
              const SizedBox(width: 8),
              Text(
                '+91 ${member.phone}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Branch
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.neonTeal,
              ),
              const SizedBox(width: 8),
              Text(
                member.branch.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonTeal,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
