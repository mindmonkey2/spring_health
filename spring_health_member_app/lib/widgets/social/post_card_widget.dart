import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class PostCardWidget extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final VoidCallback onLikePressed;
  final VoidCallback onCommentPressed;
  final VoidCallback? onHeaderTap;
  final bool isLiked;

  const PostCardWidget({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLikePressed,
    required this.onCommentPressed,
    this.onHeaderTap,
    required this.isLiked,
  });

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAtDate = post.createdAt.toDate();
    final timeAgo = _getRelativeTime(createdAtDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Member Name and Branch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onHeaderTap,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.backgroundBlack,
                          backgroundImage: post.photoUrl != null && post.photoUrl!.isNotEmpty
                              ? NetworkImage(post.photoUrl!)
                              : null,
                          child: post.photoUrl == null || post.photoUrl!.isEmpty
                              ? Text(
                                  post.memberName.isNotEmpty ? post.memberName[0].toUpperCase() : 'M',
                                  style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.memberName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neonLime,
                                ),
                              ),
                              Text(
                                post.branch,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.gray400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  timeAgo,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content: Text
            Text(
              post.text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            // Content: Media (Optional)
            if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  post.mediaUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: AppColors.surfaceDark,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.gray400,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Footer: Actions (Like & Comment)
            Row(
              children: [
                // Like Button
                InkWell(
                  onTap: onLikePressed,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? AppColors.error : AppColors.gray400,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.likeCount}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isLiked ? AppColors.error : AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Comment Button
                InkWell(
                  onTap: onCommentPressed,
                  borderRadius: BorderRadius.circular(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentCount}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}