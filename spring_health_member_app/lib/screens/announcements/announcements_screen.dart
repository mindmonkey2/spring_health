import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/announcement_service.dart';
import '../../services/member_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../models/announcement_model.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final authService = FirebaseAuthService();
  final memberService = MemberService();
  final announcementService = AnnouncementService();

  String? memberBranch;
  String? currentMemberId; // ✅ Store memberId
  bool isLoadingBranch = true;

  @override
  void initState() {
    super.initState();
    loadMemberData();

    _subscribeToNotifications();
  }

  Future<void> _subscribeToNotifications() async {
    try {
      final memberId = await authService.getCurrentMemberId();
      if (memberId != null) {
        final member = await memberService.getMemberData(memberId);
        if (member?.branch != null) {
          await NotificationService().subscribeToTopics(member!.branch);
        }
      }
    } catch (e) {
      debugPrint('Error subscribing to notifications: $e');
    }
  }

  Future<void> loadMemberData() async {
    try {
      final memberId = await authService.getCurrentMemberId();
      if (memberId != null) {
        final member = await memberService.getMemberData(memberId);
        setState(() {
          currentMemberId = memberId; // ✅ Store it
          memberBranch = member?.branch ?? 'Hanamkonda';
          isLoadingBranch = false;
        });
      } else {
        setState(() {
          memberBranch = 'Hanamkonda'; // Default
          isLoadingBranch = false;
        });
      }
    } catch (e) {
      setState(() {
        memberBranch = 'Hanamkonda'; // Default fallback
        isLoadingBranch = false;
      });
    }
  }

  Future<void> markAsRead(String announcementId) async {
    if (currentMemberId != null) {
      await announcementService.markAsRead(announcementId, currentMemberId!);
    }
  }

  String formatTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'en_short');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: Text(
          'ALERTS & NEWS',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        centerTitle: false,
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
      ),
      body: isLoadingBranch
          ? _buildLoadingState()
          : StreamBuilder<List<AnnouncementModel>>(
              stream: announcementService.getAnnouncementsStream(memberBranch!),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                // Error state
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                // Empty state
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final announcements = snapshot.data!;

                // Success - Display announcements
                return RefreshIndicator(
                  onRefresh: () async {
                    // Stream automatically refreshes
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  color: AppColors.neonLime,
                  backgroundColor: AppColors.cardSurface,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: announcements.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return _buildAnnouncementCard(
                        announcement: announcement,
                        delay: index * 100 + 100,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAnnouncementCard({
    required AnnouncementModel announcement,
    required int delay,
  }) {
    // ✅ FIXED: Check if current user has read this
    final isNew = currentMemberId != null
        ? !announcement.isReadBy(currentMemberId!)
        : false;
    final timeAgo = formatTimeAgo(announcement.createdAt).toUpperCase();

    return GestureDetector(
      onTap: () {
        // Mark as read when tapped
        if (isNew) {
          markAsRead(announcement.id);
        }
        // Show full announcement dialog
        _showAnnouncementDialog(announcement);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNew
                ? AppColors.neonLime.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: isNew ? 2 : 1,
          ),
          boxShadow: [
            if (isNew)
              BoxShadow(
                color: AppColors.neonLime.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: -5,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    timeAgo,
                    style: AppTextStyles.caption.copyWith(
                      color: isNew ? AppColors.neonLime : AppColors.gray600,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              announcement.title,
              style: AppTextStyles.heading3.copyWith(fontSize: 18),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Content preview (✅ FIXED: using .content getter)
            Text(
              announcement.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray400, // ✅ FIXED: was gray300
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Read more
            Row(
              children: [
                Text(
                  'READ MORE',
                  style: AppTextStyles.link.copyWith(fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.neonTeal,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  void _showAnnouncementDialog(AnnouncementModel announcement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.neonLime.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: AppTextStyles.heading2.copyWith(fontSize: 20),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: AppColors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                formatTimeAgo(announcement.createdAt).toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Full content (✅ FIXED: using .content getter)
              Text(
                announcement.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400, // ✅ FIXED: was gray300
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 2,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.neonLime, strokeWidth: 3),
          const SizedBox(height: 16),
          Text(
            'LOADING ANNOUNCEMENTS...',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              letterSpacing: 2,
            ),
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
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: AppColors.gray600,
          ),
          const SizedBox(height: 16),
          Text(
            'NO ANNOUNCEMENTS',
            style: AppTextStyles.heading3.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
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
          Icon(Icons.error_outline, size: 64, color: AppColors.neonOrange),
          const SizedBox(height: 16),
          Text(
            'ERROR LOADING',
            style: AppTextStyles.heading3.copyWith(color: AppColors.neonOrange),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
