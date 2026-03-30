import 'dart:async';

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/challenge_model.dart';
import '../../services/challenge_service.dart';
import '../../models/weekly_war_model.dart';
import '../../services/weekly_war_service.dart';
import '../../services/member_service.dart';
import '../../models/member_model.dart';
import '../workout/workout_logger_screen.dart';

// ════════════════════════════════════════════════════════════════
// WAR SCREEN
// ════════════════════════════════════════════════════════════════

class WarScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const WarScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<WarScreen> createState() => _WarScreenState();
}

class _ChallengePickerSheet extends StatefulWidget {
  const _ChallengePickerSheet();

  @override
  State<_ChallengePickerSheet> createState() => _ChallengePickerSheetState();
}

class _ChallengePickerSheetState extends State<_ChallengePickerSheet> {
  int _step = 0;
  String? _selectedOpponentName; // For UI display
  String? _selectedExercise;

  final _exercises = ['Push-ups', 'Squats', 'Pull-ups', 'Burpees', 'Plank'];
  bool _isLoading = false;

  void _nextStep() {
    setState(() {
      if (_step < 2) _step++;
    });
  }

  void _prevStep() {
    setState(() {
      if (_step > 0) _step--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_step > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: _prevStep,
                )
              else
                const SizedBox(width: 48),
              Text(
                _step == 0
                    ? 'Pick an Opponent'
                    : _step == 1
                        ? 'Pick an Exercise'
                        : 'Confirm Your Duel',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: _buildStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _buildStep0();
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep0() {
    // Note: No members stream/future available from imported services.
    // Displaying 'Coming Soon' for this step only as requested.
    return Center(
      child: Text(
        'Coming Soon',
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
      ),
    );
  }

  Widget _buildStep1() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final ex = _exercises[index];
        return ListTile(
          title: Text(ex, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.neonLime),
          onTap: () {
            setState(() => _selectedExercise = ex);
            _nextStep();
          },
        );
      },
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'You vs $_selectedOpponentName — $_selectedExercise — 7 days',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonLime,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  try {
                    // EXACT method signature from pre-work:
                    // Future<void> createDemoChallenge() async
                    await ChallengeService().createDemoChallenge(); // Using an inline instance directly, as ChallengeService has no singleton.

                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Duel sent!'),
                        backgroundColor: AppColors.neonLime,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to send challenge'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : const Text(
                  'Send Challenge',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}

class _WarScreenState extends State<WarScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _challengeService = ChallengeService();
  final _weeklyWarService = WeeklyWarService.instance;
  final _memberService = MemberService();

  MemberModel? _member;
  WeeklyWarModel? _activeWar;
  List<WeeklyWarModel> _pastWars = [];

  bool _isLoading = true;

  Timer? _timer;
  final _countdown = ValueNotifier<String>('');
  String? _lastWarId;

  Timer? _duelTimer;
  final ValueNotifier<String> duelCountdown = ValueNotifier('--');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _member = await _memberService.getMemberData(widget.memberId);
    if (_member != null) {
      _activeWar = await _weeklyWarService.getActiveWar(_member!.branch);
      _pastWars = await _weeklyWarService.getPastWars(_member!.branch);

      if (_activeWar != null) {
        _startTimerFor(_activeWar!);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timer?.cancel();
    _countdown.dispose();
    _duelTimer?.cancel();
    duelCountdown.dispose();
    super.dispose();
  }

  String _formatCountdown(DateTime end) {
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return 'ENDED';
    final d = diff.inDays;
    final h = (diff.inHours % 24).toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    if (d > 0) return '${d}d ${h}h';
    return '${h}h ${m}m';
  }

  void _startTimerFor(WeeklyWarModel war) {
    if (_lastWarId == war.id) return;
    _lastWarId = war.id;
    _timer?.cancel();
    _tick(war.endDate);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick(war.endDate);
    });
  }

  void _tick(DateTime end) {
    final diff = end.difference(DateTime.now());
    if (!mounted) return;
    if (diff.isNegative) {
      _countdown.value = 'ENDED';
      _timer?.cancel();
      return;
    }
    final d = diff.inDays;
    final h = (diff.inHours % 24).toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    _countdown.value = d > 0 ? '${d}d ${h}h ${m}m ${s}s' : '${h}h ${m}m ${s}s';
  }

  // ── UI BUILDERS ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'BRANCH WARS',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonLime,
          labelColor: AppColors.neonLime,
          unselectedLabelColor: AppColors.gray400,
          tabs: const [
            Tab(text: 'THIS WEEK'),
            Tab(text: '1v1 DUELS'),
            Tab(text: 'HISTORY'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildThisWeekTab(),
                _buildDuelsTab(),
                _buildHistoryTab(),
              ],
            ),
    );
  }

  // ── THIS WEEK TAB ─────────────────────────────────────────────────────────

  Widget _buildThisWeekTab() {
    if (_activeWar == null) {
      return Center(
        child: Text(
          'No active war this week.\nStay tuned!',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonLime,
      backgroundColor: AppColors.cardSurface,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWarBanner(_activeWar!),
          const SizedBox(height: 20),
          _buildPrizesCard(_activeWar!),
          const SizedBox(height: 20),
          _buildMyEntryCard(_activeWar!),
          const SizedBox(height: 24),
          Text(
            'LIVE LEADERBOARD',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildLeaderboard(_activeWar!.id),
        ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1),
      ),
    );
  }

  Widget _buildWarBanner(WeeklyWarModel war) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonLime.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'WEEK ${war.weekNumber}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neonLime,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            war.exercise.toUpperCase(),
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          Text(
            'Total ${war.unit}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppColors.neonOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<String>(
                valueListenable: _countdown,
                builder: (context, val, child) => Text(
                  val,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.neonOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WorkoutLoggerScreen(
                    memberId: widget.memberId,
                    initialExercise: war.exercise,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: AppColors.backgroundBlack,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'LOG IT NOW',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizesCard(WeeklyWarModel war) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIZE POOL (XP)',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _prizeItem('1st', '1st', '${war.prizePool['1st'] ?? 500}'),
              _prizeItem('2nd', '2nd', '${war.prizePool['2nd'] ?? 300}'),
              _prizeItem('3rd', '3rd', '${war.prizePool['3rd'] ?? 150}'),
              _prizeItem(
                '',
                'Part.',
                '${war.prizePool['participation'] ?? 20}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _prizeItem(String emoji, String rank, String xp) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          rank,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
        ),
        Text(
          xp,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMyEntryCard(WeeklyWarModel war) {
    return StreamBuilder<List<WarEntryModel>>(
      stream: _weeklyWarService.getWarLeaderboard(war.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final entries = snapshot.data!;
        final myIndex = entries.indexWhere(
          (e) => e.memberId == widget.memberId,
        );

        if (myIndex == -1) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.neonOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.neonOrange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You haven\'t logged any ${war.unit} yet. Log a workout to join!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final myEntry = entries[myIndex];
        final rank = myIndex + 1;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.neonLime.withValues(alpha: 0.2),
                AppColors.neonLime.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonLime.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.backgroundBlack,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonLime),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#$rank',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.neonLime,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MY PROGRESS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    Text(
                      '${myEntry.totalReps} ${war.unit}',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sessions',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                  Text(
                    '${myEntry.sessionCount}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboard(String warId) {
    return StreamBuilder<List<WarEntryModel>>(
      stream: _weeklyWarService.getWarLeaderboard(warId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonLime),
          );
        }

        final entries = snapshot.data!;
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No entries yet.\nBe the first to dominate!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ),
          );
        }

        // Limit to top 10
        final topEntries = entries.take(10).toList();

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topEntries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = topEntries[index];
            final rank = index + 1;
            final isMe = entry.memberId == widget.memberId;

            Color rankColor;
            if (rank == 1) {
              rankColor = Colors.amber;
            } else if (rank == 2) {
              rankColor = Colors.grey.shade300;
            } else if (rank == 3) {
              rankColor = Colors.brown.shade300;
            } else {
              rankColor = AppColors.gray400;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.neonLime.withValues(alpha: 0.1)
                    : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: isMe
                    ? Border.all(
                        color: AppColors.neonLime.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '#$rank',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.backgroundBlack,
                    child: Text(
                      entry.memberName.isNotEmpty ? entry.memberName[0] : '?',
                      style: const TextStyle(color: AppColors.neonLime),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isMe
                          ? 'You'
                          : (entry.memberName.isEmpty
                                ? 'Unknown'
                                : entry.memberName),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isMe
                            ? AppColors.neonLime
                            : AppColors.textPrimary,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.totalReps}',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── 1v1 DUELS TAB ─────────────────────────────────────────────────────────

  /*
  // PRE-WORK CONTRACT:
  // ChallengeService methods:
  // - getActiveChallengeStream() -> Stream<ChallengeModel?>
  // - createDemoChallenge() -> Future<void>
  //
  // ChallengeModel fields:
  // - title: String
  // - status: ChallengeStatus
  // - startDate: DateTime
  // - endDate: DateTime
  // - teamA: ChallengeTeam
  // - teamB: ChallengeTeam
  //
  // ChallengeTeam fields:
  // - name: String
  // - totalScore: int
  // - memberIds: List<String>
  */

  Widget _buildDuelsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // SECTION 1 — ACTIVE CHALLENGE CARD
        StreamBuilder<ChallengeModel?>(
          stream: _challengeService.getActiveChallengeStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: AppColors.neonLime),
                ),
              );
            }

            final challenge = snapshot.data;

            if (challenge == null) {
              // State A — No active challenge
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter:
                      ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Assuming ui is imported? Let's check imports
                  // Wait, I need to make sure I don't break with imports. Let me just use the standard backdrop filter.
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.flash_on,
                          color: AppColors.neonOrange,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Active Duel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Challenge a member to a head-to-head war',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonOrange,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => _showChallengePicker(context),
                          child: const Text('Start a Duel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
            }

            // State B — Active challenge exists
            if (_duelTimer == null || !_duelTimer!.isActive) {
              duelCountdown.value = _formatCountdown(challenge.endDate);
              _duelTimer = Timer.periodic(const Duration(minutes: 1), (_) {
                if (mounted) {
                  duelCountdown.value = _formatCountdown(challenge.endDate);
                }
              });
            }

            final isMeA = challenge.teamA.memberIds.contains(widget.memberId);
            final isMeB = challenge.teamB.memberIds.contains(widget.memberId);
            final nameA = isMeA ? 'You' : challenge.teamA.name;
            final nameB = isMeB ? 'You' : challenge.teamB.name;

            final scoreA = challenge.teamA.totalScore;
            final scoreB = challenge.teamB.totalScore;
            final maxScore = math.max(1, math.max(scoreA, scoreB));
            final progressA = (scoreA / maxScore).clamp(0.0, 1.0);
            final progressB = (scoreB / maxScore).clamp(0.0, 1.0);

            final isActive = challenge.status.name == 'active';
            final statusColor = isActive ? AppColors.neonLime : Colors.grey;
            final statusLabel = isActive ? 'Active' : 'Completed';

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ACTIVE DUEL',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.neonLime,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nameA,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Text(
                            'vs',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              nameB,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          color: AppColors.neonLime,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bar A
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progressA,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.neonLime,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$nameA: $scoreA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Bar B
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progressB,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.1,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.neonOrange,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$nameB: $scoreB',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<String>(
                        valueListenable: duelCountdown,
                        builder: (context, val, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: Colors.grey,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                val,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
          },
        ),

        const SizedBox(height: 32),
        const Text(
          'CHALLENGE HISTORY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),

        // SECTION 2 — CHALLENGE HISTORY LIST
        // Note: ChallengeService has NO getPastChallenges method.
        // As per instructions, showing a Coming Soon card for this specific section ONLY.
        Card(
          color: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'Coming Soon',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // SECTION 3 — _showChallengePicker
  void _showChallengePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChallengePickerSheet(),
    );
  }

  // ── HISTORY TAB ───────────────────────────────────────────────────────────

  Widget _buildHistoryTab() {
    if (_pastWars.isEmpty) {
      return Center(
        child: Text(
          'No past wars found.',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pastWars.length,
      itemBuilder: (context, index) {
        final war = _pastWars[index];
        return Card(
          color: AppColors.cardSurface,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WEEK ${war.weekNumber}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.neonLime,
                      ),
                    ),
                    Text(
                      war.status.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  war.exercise,
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (war.winnerName != null)
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Winner: ${war.winnerName}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                FutureBuilder<WarEntryModel?>(
                  future: _weeklyWarService.getMemberWarEntry(
                    war.id,
                    widget.memberId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text(
                        'You did not participate.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                      );
                    }
                    final entry = snapshot.data!;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Rank: ${entry.rank ?? '-'}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.neonLime,
                            ),
                          ),
                          Text(
                            '${entry.totalReps} ${war.unit}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
