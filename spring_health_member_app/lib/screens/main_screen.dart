// lib/screens/main_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/member_model.dart';
import '../services/member_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/membership_alert_service.dart';
import 'home/widgets/membership_expiry_banner.dart';
import 'home/home_screen.dart';
import 'fitness/fitness_dashboard_screen.dart';
import 'announcements/announcements_screen.dart';
import 'profile/profile_screen.dart';
import 'lockout/membership_expired_screen.dart';
import '../screens/ai_coach/ai_coach_screen.dart';
import '../services/wearable_snapshot_service.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  // ── Services ───────────────────────────────────────────────────
  final _authService = FirebaseAuthService();
  final _memberService = MemberService();

  // ── State ──────────────────────────────────────────────────────
  late int _currentIndex;
  String? _memberId;
  MemberModel? _member;
  bool _isLoading = true;
  String? _error;
  int _unreadCount = 0;

  // ── Stream subscriptions — cancelled in dispose() ──────────────
  StreamSubscription<DocumentSnapshot>? _memberSub;
  StreamSubscription<QuerySnapshot>? _announcementSub;

  // ── Cached screens — only rebuilt when _member changes ─────────
  List<Widget>? _cachedScreens;
  String? _cachedMemberId;

  // ── Nav config ─────────────────────────────────────────────────
  static const _navItems = [
    _NavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Home'),
    _NavItem(
      Icons.fitness_center_rounded,
      Icons.fitness_center_outlined,
      'Train',
    ),
    _NavItem(Icons.smart_toy_rounded, Icons.smart_toy_outlined, 'AjAX'),
    _NavItem(
      Icons.notifications_rounded,
      Icons.notifications_outlined,
      'Alerts',
    ),
    _NavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  // ══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this); // ✅ lifecycle observer
    _init();

    // Silently sync wearable data in background — no loading state shown
    Future.microtask(() async {
      try {
        final memberId = await FirebaseAuthService.instance
            .getCurrentMemberId();
        if (memberId != null) {
          await WearableSnapshotService.instance.syncTodaySnapshot(memberId);
          debugPrint('Check Wearable snapshot synced');
        }
      } catch (e) {
        debugPrint(' Wearable sync skipped: $e');
        // Silent fail — never block app startup
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _memberSub?.cancel(); // ✅ no memory leaks
    _announcementSub?.cancel();
    super.dispose();
  }

  // ✅ Refresh member data when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _memberId != null) {
      _memberService.getMemberData(_memberId!).then((m) {
        if (mounted && m != null) setState(() => _member = m);
      });
    }
  }

  // ══════════════════════════════════════════════════════════════
  // DATA
  // ══════════════════════════════════════════════════════════════

  Future<void> _init() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memberId = await _authService.getCurrentMemberId();
      if (memberId == null) {
        if (mounted) {
          setState(() {
            _error = 'Member not found';
            _isLoading = false;
          });
        }
        return;
      }

      _memberId = memberId;

      // ✅ One-time load for initial render
      final member = await _memberService.getMemberData(memberId);
      if (!mounted) return;

      setState(() {
        _member = member;
        _isLoading = false;
      });

      // ✅ Real-time member doc stream — auto-reflects renewals & expiry
      _memberSub?.cancel();
      _memberSub = FirebaseFirestore.instance
          .collection('members')
          .doc(memberId)
          .snapshots()
          .listen((snap) {
            if (!mounted || !snap.exists) return;
            final updated = MemberModel.fromMap(
              snap.data() as Map<String, dynamic>,
              id: snap.id,
            );
            setState(() => _member = updated);
          });

      // ✅ Unread announcements stream — Alerts tab badge only
      _listenToUnreadAnnouncements(memberId);

      // ✅ Membership expiry alert — non-blocking
      if (member != null) MembershipAlertService().checkAndNotify(member);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _listenToUnreadAnnouncements(String memberId) {
    _announcementSub?.cancel();
    _announcementSub = FirebaseFirestore.instance
        .collection('announcements')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snap) {
          if (!mounted) return;
          final unread = snap.docs.where((doc) {
            final readBy = List.from(doc.data()['readBy'] ?? []);
            return !readBy.contains(memberId);
          }).length;
          setState(() => _unreadCount = unread);
        });
  }

  // ══════════════════════════════════════════════════════════════
  // SCREENS — cached, only rebuilt when member identity changes
  // ══════════════════════════════════════════════════════════════

  List<Widget> get _screens {
    if (_member == null) {
      return [
        const HomeScreen(),
        const FitnessDashboardScreen(),
        const SizedBox(), // AjAX placeholder
        const AnnouncementsScreen(),
        _buildProfileErrorState(),
      ];
    }

    // ✅ Only recreate screen instances when member ID changes
    if (_cachedScreens == null || _cachedMemberId != _member!.id) {
      _cachedMemberId = _member!.id;
      _cachedScreens = [
        const HomeScreen(),
        FitnessDashboardScreen(memberId: _member!.id),
        AiCoachScreen(memberId: _member!.id),
        const AnnouncementsScreen(),
        ProfileScreen(member: _member!),
      ];
    }
    return _cachedScreens!;
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingState();

    if (_error != null && _member == null) return _buildErrorState();

    if (_member != null && _member!.isExpired) {
      return MembershipExpiredScreen(member: _member!);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Column(
        children: [
          if (_member != null && _member!.isExpiringSoon)
            MembershipExpiryBanner(member: _member!),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ══════════════════════════════════════════════════════════════

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.07),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: List.generate(_navItems.length, (i) {
              // ✅ Only Alerts tab (index 3) gets a badge
              final badge = i == 3 ? _unreadCount : 0;
              return _buildNavItem(
                index: i,
                item: _navItems[i],
                badgeCount: badge,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required _NavItem item,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.neonLime : AppColors.gray600;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_currentIndex == index) return; // ✅ no rebuild on same tab
          HapticFeedback.selectionClick(); // ✅ tactile feedback
          setState(() => _currentIndex = index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.neonLime.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✅ Icon scales up on selection
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? item.selectedIcon : item.unselectedIcon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  // ✅ Badge animates in/out smoothly
                  if (badgeCount > 0)
                    Positioned(
                      top: -5,
                      right: -7,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child:
                            Container(
                              key: ValueKey(badgeCount),
                              padding: const EdgeInsets.all(3),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                badgeCount > 9 ? '9+' : '$badgeCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ).animate().scale(
                              begin: const Offset(0.5, 0.5),
                              end: const Offset(1, 1),
                              duration: 300.ms,
                              curve: Curves.elasticOut,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: isSelected ? 0.5 : 0,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOADING & ERROR STATES
  // ══════════════════════════════════════════════════════════════

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ Pulsing logo instead of plain spinner
            Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonLime.withValues(alpha: 0.1),
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.neonLime,
                    size: 36,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.05, 1.05),
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                )
                .then()
                .shimmer(color: AppColors.neonLime.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            Text(
              'SPRING HEALTH',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neonLime,
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              'Loading your data...',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray400,
                fontSize: 12,
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 40,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'CONNECTION ERROR',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error ?? 'Could not load your data.\nCheck your connection.',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _init,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('TRY AGAIN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileErrorState() {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.person_off_rounded,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load profile',
              style: AppTextStyles.heading3.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _init,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
  const _NavItem(this.selectedIcon, this.unselectedIcon, this.label);
}
