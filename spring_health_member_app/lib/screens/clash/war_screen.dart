import 'dart:async';

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
    super.dispose();
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
              _prizeItem('🥇', '1st', '${war.prizePool['1st'] ?? 500}'),
              _prizeItem('🥈', '2nd', '${war.prizePool['2nd'] ?? 300}'),
              _prizeItem('🥉', '3rd', '${war.prizePool['3rd'] ?? 150}'),
              _prizeItem(
                '🏅',
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

  Widget _buildDuelsTab() {
    return StreamBuilder<ChallengeModel?>(
      stream: _challengeService.getActiveChallengeStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonLime),
          );
        }

        final challenge = snapshot.data;
        if (challenge == null) {
          return Center(
            child: Text(
              'No active duels.\nChallenges coming soon!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray400),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.cardSurface,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(
                  challenge.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Ends in ${challenge.endDate.difference(DateTime.now()).inDays} days',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.neonLime,
                ),
                onTap: () {
                  // Re-use logic for Challenge Details if you wish.
                  // For now just empty placeholder or simple alert.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Duels view opening...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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
