import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../models/notification_model.dart';
import '../../services/in_app_notification_service.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = InAppNotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<AppNotification>> _streamForIndex(int i) {
    return switch (i) {
      1 => _service.streamByType(NotificationType.xp),
      2 => _service.streamByType(NotificationType.badge),
      3 => _service.streamByType(NotificationType.gym),
      _ => _service.streamAll(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(
                  4,
                  (i) => _NotifTabView(stream: _streamForIndex(i)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          // Live unread pill
          StreamBuilder<int>(
            stream: _service.streamUnreadCount(),
            builder: (context, snap) {
              final count = snap.data ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.neonLime.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '$count unread',
                  style: TextStyle(
                    color: AppColors.neonLime,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // ✅ FIXED: scale(begin:) takes Offset, not double
              ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
            },
          ),
          // Mark all read button
          GestureDetector(
            onTap: () async {
              // ✅ Captured before await — safe across async gap
              final messenger = ScaffoldMessenger.of(context);
              await _service.markAllAsRead();
              messenger.showSnackBar(
                SnackBar(
                  content: const Text('All notifications marked as read'),
                  backgroundColor: AppColors.neonTeal.withValues(alpha: 0.85),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.neonTeal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.neonTeal.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                Icons.done_all_rounded,
                color: AppColors.neonTeal,
                size: 18,
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 350.ms),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.neonLime.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.35)),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.neonLime,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.38),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'XP'),
          Tab(text: 'Badges'),
          Tab(text: 'Gym'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Private tab content widget
// ─────────────────────────────────────────────────────────────

class _NotifTabView extends StatelessWidget {
  final Stream<List<AppNotification>> stream;

  const _NotifTabView({required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AppNotification>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.neonLime,
              strokeWidth: 2,
            ),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) return _emptyState();
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          itemCount: items.length,
          itemBuilder: (_, i) => NotificationTile(notification: items[i]),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: Colors.white.withValues(alpha: 0.12),
            size: 68,
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'XP gains, badges & gym alerts\nwill show up here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.22),
              fontSize: 13,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 150.ms),
    );
  }
}
