import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/member_service.dart';
import '../../services/gamification_service.dart';
import '../../models/member_model.dart';
import '../../models/gamification_model.dart';
import 'widgets/membership_card_widget.dart';
import 'widgets/stats_overview_widget.dart';
import '../workout/workout_logger_screen.dart';
import '../gamification/xp_screen.dart';
import '../checkin/qr_checkin_screen.dart';
import '../clash/war_screen.dart';
import '../fitness/body_metrics_screen.dart';
import '../social/social_coming_soon_screen.dart';
import '../../services/wearable_snapshot_service.dart';
import '../../services/ai_coach_service.dart';
import '../ai_coach/ai_coach_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // ✅ FIX 3: typed generic
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = FirebaseAuthService();
  final _memberService = MemberService();
  final _gamService = GamificationService();
  final _wearableService = WearableSnapshotService.instance;
  final _aiCoachService = AiCoachService();

  String? _memberId;
  MemberModel? _member;
  MemberGamification? _gamification;
  bool _isLoading = true;
  String? _error;

  String? _recoveryStatus;
  String? _coachNoteSnippet;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  // ── Data ─────────────────────────────────────────────────────────────────

  Future<void> _loadMemberData() async {
    // ✅ FIX 4: Future<void>
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null; // ✅ FIX 7: clear previous error on refresh
    });

    try {
      final memberId = await _authService.getCurrentMemberId();
      if (memberId == null) {
        if (mounted) {
          setState(() {
            _error = 'Member ID not found';
            _isLoading = false;
          });
        }
        return;
      }

      final member = await _memberService.getMemberData(memberId);
      if (member == null) {
        if (mounted) {
          setState(() {
            _error = 'Member data not found';
            _isLoading = false;
          });
        }
        return;
      }

      final gamification = await _gamService.getOrCreate(memberId);
      _gamService.listenToEvents(memberId);

      // Load AI data concurrently
      String? recoveryStatus;
      String? coachNoteSnippet;
      try {
        final snapshot = await _wearableService.getTodaySnapshot(memberId);
        recoveryStatus = snapshot?.recoveryStatus;

        final aiPlan = await _aiCoachService.getCachedWorkoutPlan(memberId);
        if (aiPlan != null && aiPlan['coachNote'] != null) {
          final note = aiPlan['coachNote'] as String;
          final firstSentence = note.split('.').first;
          coachNoteSnippet = firstSentence.length > 60
              ? '${firstSentence.substring(0, 60)}...'
              : '$firstSentence.';
        }
      } catch (e) {
        debugPrint('Error loading AI data for home screen banner: $e');
      }

      if (mounted) {
        setState(() {
          _memberId = memberId;
          _member = member;
          _gamification = gamification;
          _recoveryStatus = recoveryStatus;
          _coachNoteSnippet = coachNoteSnippet;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data';
          _isLoading = false;
        });
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  // ✅ FIX 8: context-aware subtitle
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  String get _motivationalSubtitle {
    final streak = _gamification?.currentStreak ?? 0;
    if (streak >= 14) return ' $streak DAYS UNSTOPPABLE!';
    if (streak >= 7) return ' $streak DAY STREAK — KEEP IT UP!';
    if (streak >= 3) return 'Energy $streak DAYS STRONG!';
    return 'READY TO TRAIN?';
  }

  // ── Badge toast ───────────────────────────────────────────────────────────

  void _showBadgeToast(BadgeDefinition badge) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: badge.color.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: badge.color.withValues(alpha: 0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ' BADGE UNLOCKED!',
                style: AppTextStyles.caption.copyWith(
                  color: badge.color,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.color.withValues(alpha: 0.15),
                  border: Border.all(color: badge.color, width: 2.5),
                ),
                child: Icon(badge.icon, color: badge.color, size: 36),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                curve: Curves.elasticOut,
                duration: 800.ms,
              ),
              const SizedBox(height: 16),
              Text(
                badge.title,
                style: AppTextStyles.heading3.copyWith(color: badge.color),
              ),
              const SizedBox(height: 6),
              Text(
                badge.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
                textAlign: TextAlign.center,
              ),
              if (badge.xpReward > 0) ...[
                const SizedBox(height: 12),
                Text(
                  '+${badge.xpReward} XP',
                  style: const TextStyle(
                    color: AppColors.neonLime,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: badge.color,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'AWESOME! ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.neonLime,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'LOADING YOUR DATA...',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error state
    if (_error != null || _member == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Something went wrong',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadMemberData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('RETRY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMemberData,
          color: AppColors.neonLime,
          backgroundColor: AppColors.cardSurface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                _buildHeader(),
                const SizedBox(height: 24),

                // ── XP Mini Card ─────────────────────────────────────
                if (_gamification != null) ...[
                  _buildXpMiniCard(),
                  const SizedBox(height: 24),
                ],

                // ── Membership Card ──────────────────────────────────
                MembershipCardWidget(
                  member: _member!,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 24),

                // ── AI Personal Trainer Banner ───────────────────────
                _buildAiCoachBanner().animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 28),

                // ── Today's Metrics ──────────────────────────────────
                Text(
                  "TODAY'S METRICS",
                  style: AppTextStyles.heading3.copyWith(fontSize: 18),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),
                StatsOverviewWidget(memberId: _memberId!),
                const SizedBox(height: 28),

                // ── Quick Actions ────────────────────────────────────
                Text(
                  'QUICK ACTIONS',
                  style: AppTextStyles.heading3.copyWith(fontSize: 18),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                _buildQuickActionsGrid(),
                const SizedBox(height: 28),

                // ── Spring Social Teaser ─────────────────────────────
                // ✅ FIX 1 & 2: method added below + called here
                _buildSpringSocialCard(),
                const SizedBox(height: 28),

                // ── Streak Banner ────────────────────────────────────
                if (_gamification != null &&
                    _gamification!.currentStreak > 0) ...[
                  _buildStreakBanner(),
                  const SizedBox(
                    height: 20,
                  ), // ✅ FIX 5: breathing room at bottom
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AI Coach Banner ───────────────────────────────────────────────────────

  Widget _buildAiCoachBanner() {
    Color chipColor = AppColors.neonLime;
    String chipText = ' Ready to Train';

    if (_recoveryStatus != null) {
      switch (_recoveryStatus) {
        case 'fully_recovered':
          chipColor = AppColors.neonLime;
          chipText = 'Ready Fully Recovered';
          break;
        case 'recovered':
          chipColor = AppColors.neonLime;
          chipText = 'Check Recovered';
          break;
        case 'moderate':
          chipColor = const Color(0xFFFF9800);
          chipText = ' Moderate';
          break;
        case 'fatigued':
          chipColor = AppColors.error;
          chipText = ' Fatigued';
          break;
        case 'sick':
          chipColor = AppColors.error;
          chipText = ' Rest Today';
          break;
        case 'cardiac_flag':
          chipColor = AppColors.error;
          chipText = ' Cardiac Alert';
          break;
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate directly to AiCoachScreen via push to keep Bottom Nav
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AiCoachScreen(memberId: _memberId!),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonLime.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.smart_toy_rounded,
                  color: AppColors.neonLime,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text('AI Personal Trainer', style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: chipColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                chipText,
                style: AppTextStyles.caption.copyWith(
                  color: chipColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _coachNoteSnippet ?? 'Generate your first AI plan.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('View Today\'s Plan', style: AppTextStyles.link),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.neonLime,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting,',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                _member!.name.toUpperCase().split(' ').first,
                style: AppTextStyles.heading2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _motivationalSubtitle, // ✅ FIX 8: streak-aware subtitle
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonLime,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neonLime, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonLime.withValues(alpha: 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.surfaceDark,
            backgroundImage: _member!.photoUrl != null
                ? NetworkImage(_member!.photoUrl!)
                : null,
            child: _member!.photoUrl == null
                ? Text(
                    _member!.name.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.neonLime,
                    ),
                  )
                : null,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  // ── XP Mini Card ──────────────────────────────────────────────────────────

  Widget _buildXpMiniCard() {
    final gam = _gamification!;
    final level = gam.currentLevel;
    final progress = level.progressPercent(gam.totalXp);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              XpScreen(memberId: _memberId!, memberName: _member!.name),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              level.color.withValues(alpha: 0.15),
              level.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: level.color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: level.color.withValues(alpha: 0.15),
                border: Border.all(color: level.color, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(level.icon, color: level.color, size: 18),
                  Text(
                    'LV${level.level}',
                    style: TextStyle(
                      color: level.color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        level.title.toUpperCase(),
                        style: TextStyle(
                          color: level.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        '${gam.totalXp} XP',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.gray800,
                        valueColor: AlwaysStoppedAnimation(level.color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 12,
                        color: AppColors.neonOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${gam.currentStreak} day streak',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'VIEW ALL →',
                        style: AppTextStyles.caption.copyWith(
                          color: level.color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
    );
  }

  // ── Quick Actions Grid ────────────────────────────────────────────────────

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildQuickAction(
          label: 'LOG\nWORKOUT',
          icon: Icons.fitness_center_rounded,
          color: AppColors.neonLime,
          delay: 500,
          onTap: () async {
            if (_memberId == null) return;
            final saved = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutLoggerScreen(memberId: _memberId!),
              ),
            );
            if (saved == true && _memberId != null) {
              final badges = await _gamService.awardXp(
                _memberId!,
                'Workout Logged',
                XpSource.workoutLogged,
                isWorkout: true,
              );
              if (mounted) {
                _loadMemberData();
                if (badges.isNotEmpty) _showBadgeToast(badges.first);
              }
            }
          },
        ),
        _buildQuickAction(
          label: 'MY XP\n& BADGES',
          icon: Icons.emoji_events_rounded,
          color: Colors.amber,
          delay: 550,
          onTap: () {
            if (_memberId == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    XpScreen(memberId: _memberId!, memberName: _member!.name),
              ),
            );
          },
        ),
        _buildQuickAction(
          label: 'CLASH\nBATTLE',
          icon: Icons.sports_kabaddi_rounded,
          color: AppColors.neonOrange,
          delay: 600,
          onTap: () {
            if (_memberId == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    WarScreen(memberId: _memberId!, memberName: _member!.name),
              ),
            );
          },
        ),
        _buildQuickAction(
          label: 'BODY\nMETRICS',
          icon: Icons.monitor_weight_rounded,
          color: AppColors.neonTeal,
          delay: 650,
          onTap: () {
            if (_memberId == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BodyMetricsScreen(memberId: _memberId!),
              ),
            );
          },
        ),
        _buildQuickAction(
          label: 'GYM\nCHECK IN',
          icon: Icons.qr_code_2_rounded,
          color: AppColors.neonLime,
          delay: 700,
          onTap: () {
            if (_member == null) return;
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (ctx, anim, _) =>
                    QrCheckInScreen(member: _member!),
                transitionsBuilder: (ctx, anim, _, child) => SlideTransition(
                  position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                      .animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: child,
                ),
              ),
            );
          },
        ),
        // ✅ FIX 6: neonTeal instead of dead gray400
        _buildQuickAction(
          label: 'BOOK\nCLASS',
          icon: Icons.calendar_today_rounded,
          color: AppColors.neonTeal,
          delay: 750,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Class Booking — Coming Soon! '),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildQuickAction({
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.1),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    duration: 2.seconds,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }

  // ── Spring Social Teaser Card ─────────────────────────────────────────────
  // ✅ FIX 1: method was missing — now added

  Widget _buildSpringSocialCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SocialComingSoonScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.neonLime.withValues(alpha: 0.15),
              AppColors.neonOrange.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonLime.withValues(alpha: 0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Pulsing bolt icon
            Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.neonLime.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.neonLime,
                    size: 26,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(width: 16),
            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SPRING SOCIAL',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.neonLime,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.neonOrange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'SOON',
                          style: TextStyle(
                            color: AppColors.neonOrange,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Flex. Compete. Squad up.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.neonLime.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Streak Banner ─────────────────────────────────────────────────────────

  Widget _buildStreakBanner() {
    final streak = _gamification!.currentStreak;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonOrange.withValues(alpha: 0.15),
            Colors.deepOrange.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.neonOrange,
                size: 32,
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 1.seconds,
                curve: Curves.easeInOut,
              ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak DAY STREAK ',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.neonOrange,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  streak >= 7
                      ? 'You\'re on fire! Keep it up!'
                      : 'Keep coming back to grow your streak!',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          const Text('', style: TextStyle(fontSize: 28)),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
