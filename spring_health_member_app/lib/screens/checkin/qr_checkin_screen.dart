import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/member_model.dart';
import '../../models/gamification_model.dart';
import '../../services/gamification_service.dart';

class QrCheckInScreen extends StatefulWidget {
  final MemberModel member;

  const QrCheckInScreen({super.key, required this.member});

  @override
  State<QrCheckInScreen> createState() => _QrCheckInScreenState();
}

class _QrCheckInScreenState extends State<QrCheckInScreen>
    with SingleTickerProviderStateMixin {
  // ── Check-in state ──────────────────────────────────────
  bool _isInitialLoad = true; // prevents XP re-award on screen re-open
  bool _checkedInToday = false;
  bool _xpAwarded = false;
  int _earnedXp = 0;
  List<BadgeDefinition> _newBadges = [];
  DateTime? _checkInTime;

  // ── Streams / subscriptions ──────────────────────────────
  StreamSubscription<QuerySnapshot>? _attendanceSub;
  StreamSubscription<MemberGamification>? _gamSub;
  MemberGamification? _gamification;

  // ── Pulse animation for QR glow ─────────────────────────
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _listenToTodaysCheckIn();
    _listenToGamification();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _attendanceSub?.cancel();
    _gamSub?.cancel();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────
  // ATTENDANCE STREAM — listens for today's check-in doc
  // First emission: existing → mark checked in, skip XP award
  // Later emission: NEW doc → award XP once
  // ─────────────────────────────────────────────────────────
  void _listenToTodaysCheckIn() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    _attendanceSub = FirebaseFirestore.instance
        .collection('attendance')
        .where('memberId', isEqualTo: widget.member.id)
        .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('checkInTime', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
          if (!mounted) return;

          final hasDoc = snapshot.docs.isNotEmpty;

          if (_isInitialLoad) {
            // First emission — restore state without awarding XP
            _isInitialLoad = false;
            if (hasDoc) {
              final data = snapshot.docs.first.data();
              final t = (data['checkInTime'] as Timestamp?)?.toDate();
              setState(() {
                _checkedInToday = true;
                _xpAwarded = true; // already checked in — don't re-award
                _checkInTime = t;
              });
            }
            return;
          }

          // ── Real-time: admin just scanned → new doc appeared
          if (hasDoc && !_checkedInToday) {
            final data = snapshot.docs.first.data();
            final t = (data['checkInTime'] as Timestamp?)?.toDate();
            setState(() {
              _checkedInToday = true;
              _checkInTime = t;
            });
            if (!_xpAwarded) {
              setState(() => _xpAwarded = true);
              await _awardCheckInXp();
            }
          }

          // ── Edge case: admin corrected / deleted the check-in doc
          if (!hasDoc && _checkedInToday) {
            setState(() {
              _checkedInToday = false;
              _xpAwarded = false;
              _earnedXp = 0;
              _newBadges = [];
              _checkInTime = null;
              _isInitialLoad = false;
            });
          }
        });
  }

  // ─────────────────────────────────────────────────────────
  // GAMIFICATION STREAM — live streak / level on stat row
  // ─────────────────────────────────────────────────────────
  void _listenToGamification() {
    _gamSub = GamificationService().stream(widget.member.id).listen((g) {
      if (mounted) setState(() => _gamification = g);
    });
  }

  // ─────────────────────────────────────────────────────────
  // AWARD XP — only ever called once per new check-in
  // ─────────────────────────────────────────────────────────
  Future<void> _awardCheckInXp() async {
    try {
      await GamificationService.instance.processEvent(
        'check_in',
        widget.member.id,
      );
      if (mounted) {
        setState(() {
          _earnedXp = 20; // Changed according to processEvent check_in
          _newBadges =
              []; // processEvent handles badge notifications directly now
        });
      }
    } catch (e) {
      debugPrint(' QrCheckInScreen processEvent error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'GYM CHECK-IN',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.neonLime,
            letterSpacing: 3,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              // ── Status chip ───────────────────────────────
              _buildStatusChip(),
              const SizedBox(height: 20),
              // ── QR card or success card ───────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(Tween(begin: 0.92, end: 1.0)),
                    child: child,
                  ),
                ),
                child: _checkedInToday
                    ? _buildSuccessCard(key: const ValueKey('success'))
                    : _buildQrCard(key: const ValueKey('qr')),
              ),
              const SizedBox(height: 16),
              // ── Streak / level / XP stats ─────────────────
              _buildStatsRow(),
              const SizedBox(height: 12),
              // ── Instruction text ──────────────────────────
              if (!_checkedInToday) _buildInstruction(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STATUS CHIP
  // ─────────────────────────────────────────────────────────
  Widget _buildStatusChip() {
    final checked = _checkedInToday;
    final color = checked ? AppColors.neonLime : AppColors.neonOrange;
    final icon = checked
        ? Icons.check_circle_rounded
        : Icons.radio_button_unchecked_rounded;
    final label = checked ? 'CHECKED IN TODAY' : 'NOT YET CHECKED IN';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          if (_checkInTime != null) ...[
            Container(
              width: 1,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: color.withValues(alpha: 0.4),
            ),
            Text(
              '${_checkInTime!.hour.toString().padLeft(2, '0')}:'
              '${_checkInTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // QR CODE CARD — shown until admin scans
  // ─────────────────────────────────────────────────────────
  Widget _buildQrCard({Key? key}) {
    return AnimatedBuilder(
      key: key,
      animation: _pulseController,
      builder: (context, child) {
        final glowAlpha = 0.10 + (_pulseController.value * 0.18);
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonLime.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonLime.withValues(alpha: glowAlpha),
                blurRadius: 32,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        children: [
          Text(
            'SCAN TO CHECK IN',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.neonLime,
              letterSpacing: 2.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Show this code to the receptionist',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 24),

          // ── QR Code (white bg for scanner contrast) ──────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonLime.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: QrImageView(
              data:
                  widget.member.qrCode, // SPRING{memberId} — exact admin format
              version: QrVersions.auto,
              size: 210,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Member info strip ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundBlack,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.neonLime.withValues(alpha: 0.15),
                  child: Text(
                    widget.member.name.isNotEmpty
                        ? widget.member.name[0].toUpperCase()
                        : 'M',
                    style: const TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.member.name.toUpperCase(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                      Text(
                        widget.member.membershipPlan,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonLime.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${widget.member.daysRemaining}d left',
                    style: const TextStyle(
                      color: AppColors.neonLime,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // SUCCESS CARD — shown after admin scans the QR
  // ─────────────────────────────────────────────────────────
  Widget _buildSuccessCard({Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonLime.withValues(alpha: 0.12),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Checkmark ─────────────────────────────────────
          Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.neonLime.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.neonLime.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.neonLime,
                  size: 48,
                ),
              )
              .animate()
              .scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 450.ms,
                curve: Curves.elasticOut,
              )
              .shimmer(
                delay: 300.ms,
                duration: 1200.ms,
                color: AppColors.neonLime.withValues(alpha: 0.4),
              ),
          const SizedBox(height: 16),

          Text(
            'WELCOME BACK!',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.neonLime,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms),

          Text(
            widget.member.name,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // ── XP earned pill ────────────────────────────────
          if (_earnedXp > 0)
            Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.neonLime.withValues(alpha: 0.18),
                        AppColors.neonTeal.withValues(alpha: 0.18),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Energy', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '+$_earnedXp XP EARNED',
                        style: const TextStyle(
                          color: AppColors.neonLime,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 300.ms),

          // ── Badge unlocked pills ──────────────────────────
          for (int i = 0; i < _newBadges.length; i++)
            Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'BADGE: ${_newBadges[i].title.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 550 + i * 100))
                .shimmer(
                  delay: Duration(milliseconds: 650 + i * 100),
                  duration: 1000.ms,
                  color: Colors.amber.withValues(alpha: 0.4),
                ),

          // ── Check-in time ─────────────────────────────────
          if (_checkInTime != null) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: AppColors.gray400,
                ),
                const SizedBox(width: 5),
                Text(
                  'Checked in at '
                  '${_checkInTime!.hour.toString().padLeft(2, '0')}:'
                  '${_checkInTime!.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STATS ROW — streak · total XP · level (live from stream)
  // ─────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final g = _gamification;
    final streak = g?.currentStreak ?? 0;
    final totalXp = g?.totalXp ?? 0;
    final level = GymLevel.forXp(totalXp);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _statCell(
            emoji: '',
            value: '$streak',
            label: 'Streak',
            color: AppColors.neonOrange,
          ),
          _verticalDivider(),
          _statCell(
            emoji: 'Energy',
            value: '$totalXp',
            label: 'Total XP',
            color: AppColors.neonLime,
          ),
          _verticalDivider(),
          _statCell(
            emoji: 'Trophy',
            value: level.title,
            label: 'Level',
            color: AppColors.neonTeal,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 300.ms);
  }

  Widget _statCell({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withValues(alpha: 0.07),
  );

  // ─────────────────────────────────────────────────────────
  // INSTRUCTION TEXT
  // ─────────────────────────────────────────────────────────
  Widget _buildInstruction() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 13,
              color: AppColors.gray600,
            ),
            const SizedBox(width: 6),
            Text(
              'Waiting for receptionist to scan your QR code...',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray600,
                fontSize: 11,
              ),
            ),
          ],
        )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 800.ms)
        .then()
        .fadeOut(delay: 1600.ms, duration: 800.ms);
  }
}
