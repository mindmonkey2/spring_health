import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/challenge_model.dart';
import '../../services/challenge_service.dart';

// ════════════════════════════════════════════════════════════════
// CLASH SCREEN
// ════════════════════════════════════════════════════════════════

class ClashScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const ClashScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<ClashScreen> createState() => _ClashScreenState();
}

class _ClashScreenState extends State<ClashScreen> {
  final _service = ChallengeService();
  Timer? _timer;
  // ✅ FIX: ValueNotifier so only the countdown Text rebuilds, not the whole screen
  final _countdown = ValueNotifier<String>('');
  String? _lastChallengeId;

  @override
  void dispose() {
    _timer?.cancel();
    _countdown.dispose(); // ✅ dispose notifier
    super.dispose();
  }

  // ── Countdown Timer ───────────────────────────────────────────────────────

  void _startTimerFor(ChallengeModel challenge) {
    if (_lastChallengeId == challenge.id) return;
    _lastChallengeId = challenge.id;
    _timer?.cancel();
    _tick(challenge.endDate);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _tick(challenge.endDate);
    });
  }

  void _tick(DateTime end) {
    final diff = end.difference(DateTime.now());
    if (!mounted) return;
    if (diff.isNegative) {
      _countdown.value = 'ENDED'; // ✅ .value — no setState
      _timer?.cancel();
      return;
    }
    final d = diff.inDays;
    final h = (diff.inHours % 24).toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    _countdown.value = // ✅ .value — no setState
    d > 0 ? '${d}d ${h}h ${m}m ${s}s' : '${h}h ${m}m ${s}s';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String? _myTeamId(ChallengeModel c) {
    if (c.teamA.memberIds.contains(widget.memberId)) return 'teamA';
    if (c.teamB.memberIds.contains(widget.memberId)) return 'teamB';
    return null;
  }

  Color _teamColor(String teamId) =>
  teamId == 'teamA' ? AppColors.neonLime : AppColors.neonOrange;

  ChallengeTeam _team(ChallengeModel c, String teamId) =>
  teamId == 'teamA' ? c.teamA : c.teamB;

  Color _typeColor(ChallengeType t) {
    switch (t) {
      case ChallengeType.stepWars:       return AppColors.neonLime;
      case ChallengeType.caloriesCrusher: return AppColors.neonOrange;
      case ChallengeType.workoutWarrior: return AppColors.neonTeal;
    }
  }

  String _fmt(int score, String unit) =>
  (unit == 'steps' && score >= 1000)
  ? '${(score / 1000).toStringAsFixed(1)}k'
  : '$score';

  // ── Join Dialog ───────────────────────────────────────────────────────────

  void _showJoinDialog(ChallengeModel challenge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.neonLime.withValues(alpha: 0.4)),
        ),
        title: Text('⚔️ Choose Your Team',
                    style: AppTextStyles.heading3, textAlign: TextAlign.center),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Pick a side and fight for glory!',
                             style: AppTextStyles.bodyMedium
                             .copyWith(color: AppColors.gray400),
                             textAlign: TextAlign.center),
                             const SizedBox(height: 20),
                             _joinButton(ctx, challenge, 'teamA'),
                             const SizedBox(height: 12),
                             _joinButton(ctx, challenge, 'teamB'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text('CANCEL',
                                    style: TextStyle(color: AppColors.gray400)),
                      ),
                    ],
      ),
    );
  }

  Widget _joinButton(
    BuildContext ctx, ChallengeModel challenge, String teamId) {
    final team  = _team(challenge, teamId);
    final color = _teamColor(teamId);
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        try {
          await _service.joinTeam(
            challengeId: challenge.id,
            memberId:    widget.memberId,
            memberName:  widget.memberName,
            teamId:      teamId,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                '${team.emoji} Joined ${team.name}! Let\'s crush it! 💪'),
                backgroundColor: color,
                behavior: SnackBarBehavior.floating,
            ));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ));
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Text(team.emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(team.name,
                       style: AppTextStyles.bodyLarge.copyWith(
                         color: color, fontWeight: FontWeight.bold)),
                         Text('${team.memberIds.length} members joined',
                              style: AppTextStyles.caption
                              .copyWith(color: AppColors.gray400)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
    }

    // ── Log Sheet ─────────────────────────────────────────────────────────────

    void _showLogSheet(ChallengeModel challenge, ChallengeEntryModel? entry) {
      final teamId = _myTeamId(challenge);
      if (teamId == null) { _showJoinDialog(challenge); return; }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _LogProgressSheet(
          challenge:     challenge,
          memberId:      widget.memberId,
          memberName:    widget.memberName,
          teamId:        teamId,
          service:       _service,
          previousScore: entry?.score ?? 0,
        ),
      );
    }

    // ════════════════════════════════════════════════════════════════
    // BUILD
    // ════════════════════════════════════════════════════════════════

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundBlack,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded,
                             color: AppColors.neonLime),
                              onPressed: () => Navigator.pop(context),
          ),
          title: Text('⚔️ CLASH',
                      style: AppTextStyles.heading2.copyWith(letterSpacing: 2)),
        ),
        body: StreamBuilder<ChallengeModel?>(
          stream: _service.getActiveChallengeStream(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neonLime));
            }

            final challenge = snap.data;
            if (challenge == null) return _buildNoChallengeState();

            // Start timer once per challenge (post-frame safe)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startTimerFor(challenge);
            });

            return StreamBuilder<List<ChallengeEntryModel>>(
              stream: _service.getEntriesStream(challenge.id),
              builder: (context, entriesSnap) {
                final entries   = entriesSnap.data ?? [];
                final myTeamId  = _myTeamId(challenge);
                final filtered  = entries.where((e) => e.memberId == widget.memberId);
                final myEntry   = filtered.isEmpty ? null : filtered.first;
                final aEntries  = entries.where((e) => e.teamId == 'teamA').toList();
                final bEntries  = entries.where((e) => e.teamId == 'teamB').toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ .animate() only runs ONCE — no setState triggering rebuild
                      _buildHeader(challenge)
                      .animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 20),
                      _buildBattleBar(challenge)
                      .animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 20),
                      _buildYourStatus(challenge, myEntry, myTeamId)
                      .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 24),
                      Text('LEADERBOARD',
                           style: AppTextStyles.caption.copyWith(
                             color: AppColors.gray400, letterSpacing: 2))
                      .animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 12),
                      _buildLeaderboard(challenge, aEntries, bEntries)
                      .animate().fadeIn(delay: 350.ms),
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }

    // ── Header ────────────────────────────────────────────────────────────────

    Widget _buildHeader(ChallengeModel c) {
      final tc = _typeColor(c.type);
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tc.withValues(alpha: 0.15), AppColors.cardSurface],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tc.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: tc.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tc),
                  ),
                  child: Text('${c.typeEmoji} ${c.typeLabel.toUpperCase()}',
                  style: TextStyle(
                    color: tc,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.5)),
                  ),
                  child: Text('🟢 LIVE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Text('🏆 ${c.prizeXP} XP',
                     style: AppTextStyles.bodyMedium
                     .copyWith(color: tc, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(c.title,
                 style: AppTextStyles.heading2.copyWith(fontSize: 20)),
                 if (c.description.isNotEmpty) ...[
                   const SizedBox(height: 6),
                   Text(c.description,
                        style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.gray400),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                 ],
                 const SizedBox(height: 16),
                 Container(
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   decoration: BoxDecoration(
                     color: AppColors.backgroundBlack,
                     borderRadius: BorderRadius.circular(12),
                   ),
                   // ✅ FIX: ValueListenableBuilder — ONLY this text rebuilds every second
                   child: Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.timer_rounded,
                                  size: 16, color: AppColors.neonOrange),
                              const SizedBox(width: 8),
                              Text('ENDS IN ',
                                   style: AppTextStyles.caption
                                   .copyWith(color: AppColors.gray400)),
                                   ValueListenableBuilder<String>(
                                     valueListenable: _countdown,
                                     builder: (context, value, child) => Text(
                                       value.isEmpty ? '...' : value,
                                       style: AppTextStyles.bodyLarge.copyWith(
                                         color: AppColors.neonOrange,
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

    // ── Battle Bar ────────────────────────────────────────────────────────────

    Widget _buildBattleBar(ChallengeModel c) {
      final aP   = c.teamAPercent;
      final bP   = 1.0 - aP;
      final unit = c.typeUnit;
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.teamA.emoji,
                           style: const TextStyle(fontSize: 26)),
                           const SizedBox(height: 4),
                           Text(c.teamA.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.neonLime,
                                  fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                                Text(_fmt(c.teamA.totalScore, unit),
                                style: AppTextStyles.heading3
                                .copyWith(color: AppColors.neonLime, fontSize: 20)),
                                Text('${c.teamA.memberIds.length} members',
                                     style: AppTextStyles.caption
                                     .copyWith(color: AppColors.gray400)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundBlack,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gray400.withValues(alpha: 0.3)),
                      ),
                      child: const Text('⚔️',
                                        style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(height: 4),
                    Text('VS',
                         style: AppTextStyles.caption
                         .copyWith(color: AppColors.gray400, letterSpacing: 2)),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(c.teamB.emoji,
                           style: const TextStyle(fontSize: 26)),
                           const SizedBox(height: 4),
                           Text(c.teamB.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.neonOrange,
                                  fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                                Text(_fmt(c.teamB.totalScore, unit),
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.neonOrange, fontSize: 20)),
                                Text('${c.teamB.memberIds.length} members',
                                     style: AppTextStyles.caption
                                     .copyWith(color: AppColors.gray400)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(aP * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
                Text('${(bP * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.neonOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 22,
                child: LayoutBuilder(builder: (ctx, constraints) {
                  return Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        width: constraints.maxWidth * aP,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.neonLime.withValues(alpha: 0.7),
                            AppColors.neonLime,
                          ]),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        width: constraints.maxWidth * bP,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.neonOrange,
                            AppColors.neonOrange.withValues(alpha: 0.7),
                          ]),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            if (c.totalScore > 0) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: aP > 0.5
                    ? AppColors.neonLime.withValues(alpha: 0.15)
                    : AppColors.neonOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: aP > 0.5
                      ? AppColors.neonLime.withValues(alpha: 0.4)
                      : AppColors.neonOrange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    aP > 0.5
                    ? '${c.teamA.emoji} ${c.teamA.name} is leading!'
                  : aP < 0.5
                  ? '${c.teamB.emoji} ${c.teamB.name} is leading!'
                  : '🤝 It\'s a tie!',
                  style: TextStyle(
                    color: aP > 0.5
                    ? AppColors.neonLime
                    : aP < 0.5
                    ? AppColors.neonOrange
                    : AppColors.gray400,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // ── Your Status ───────────────────────────────────────────────────────────

    Widget _buildYourStatus(
      ChallengeModel c, ChallengeEntryModel? myEntry, String? myTeamId) {
      if (myTeamId == null) return _buildJoinPrompt(c);
      final color   = _teamColor(myTeamId);
      final team    = _team(c, myTeamId);
      final myScore = myEntry?.score ?? 0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(team.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('YOUR TEAM',
                     style: AppTextStyles.caption.copyWith(
                       color: color,
                       letterSpacing: 2,
                       fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(team.name,
                 style: AppTextStyles.heading3.copyWith(color: color)),
                 const SizedBox(height: 14),
                 Row(
                   children: [
                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: AppColors.backgroundBlack,
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Column(
                           children: [
                             Text(_fmt(myScore, c.typeUnit),
                             style: AppTextStyles.heading2
                             .copyWith(color: color, fontSize: 22)),
                             Text('My ${c.typeUnit}',
                                  style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gray400)),
                           ],
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     Expanded(
                       child: Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: AppColors.backgroundBlack,
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Column(
                           children: [
                             Text(_fmt(team.totalScore, c.typeUnit),
                             style: AppTextStyles.heading2
                             .copyWith(color: color, fontSize: 22)),
                             Text('Team total',
                                  style: AppTextStyles.caption
                                  .copyWith(color: AppColors.gray400)),
                           ],
                         ),
                       ),
                     ),
                     const SizedBox(width: 10),
                     GestureDetector(
                       onTap: () => _showLogSheet(c, myEntry),
                       child: Container(
                         padding: const EdgeInsets.symmetric(
                           horizontal: 16, vertical: 14),
                           decoration: BoxDecoration(
                             color: color,
                             borderRadius: BorderRadius.circular(14),
                           ),
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.add_rounded, color: Colors.black, size: 22),
                               const SizedBox(height: 2),
                               Text('LOG',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                             ],
                           ),
                       ),
                     ),
                   ],
                 ),
          ],
        ),
      );
      }

      Widget _buildJoinPrompt(ChallengeModel c) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonLime.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              const Text('⚔️', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('Join the Battle!',
                   style: AppTextStyles.heading3, textAlign: TextAlign.center),
                   const SizedBox(height: 8),
                   Text(
                     'Pick a team and start contributing ${c.typeUnit} to help win!',
                     style: AppTextStyles.bodyMedium
                     .copyWith(color: AppColors.gray400),
                     textAlign: TextAlign.center),
                     const SizedBox(height: 18),
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton.icon(
                         onPressed: () => _showJoinDialog(c),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.neonLime,
                           foregroundColor: Colors.black,
                             padding: const EdgeInsets.symmetric(vertical: 14),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(14)),
                         ),
                         icon: const Icon(Icons.group_add_rounded),
                         label: const Text('CHOOSE YOUR TEAM',
                                           style: TextStyle(
                                             fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                       ),
                     ),
            ],
          ),
        );
      }

      // ── Leaderboard ───────────────────────────────────────────────────────────

      Widget _buildLeaderboard(ChallengeModel c,
                               List<ChallengeEntryModel> aEntries,
                               List<ChallengeEntryModel> bEntries) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border:
              Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                _teamSection(c, c.teamA, aEntries, AppColors.neonLime),
                Divider(
                  color: Colors.white.withValues(alpha: 0.08), height: 1),
                  _teamSection(c, c.teamB, bEntries, AppColors.neonOrange),
              ],
            ),
          ),
        );
                               }

                               Widget _teamSection(ChallengeModel c, ChallengeTeam team,
                                                   List<ChallengeEntryModel> entries, Color color) {
                                 return Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Container(
                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                       color: color.withValues(alpha: 0.08),
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Row(children: [
                                             Text(team.emoji, style: const TextStyle(fontSize: 18)),
                                             const SizedBox(width: 8),
                                             Text(team.name,
                                                  style: AppTextStyles.bodyLarge.copyWith(
                                                    color: color, fontWeight: FontWeight.bold)),
                                           ]),
                                           Container(
                                             padding: const EdgeInsets.symmetric(
                                               horizontal: 10, vertical: 4),
                                               decoration: BoxDecoration(
                                                 color: color,
                                                 borderRadius: BorderRadius.circular(10),
                                               ),
                                               child: Text(_fmt(team.totalScore, c.typeUnit),
                                               style: const TextStyle(
                                                 color: Colors.black,
                                                 fontWeight: FontWeight.bold,
                                                 fontSize: 12)),
                                           ),
                                         ],
                                       ),
                                     ),
                                     if (entries.isEmpty)
                                       Padding(
                                         padding: const EdgeInsets.all(16),
                                         child: Center(
                                           child: Text('No members yet — be the first!',
                                                       style: AppTextStyles.caption
                                                       .copyWith(color: AppColors.gray400)),
                                         ),
                                       )
                                       else
                                         ...entries.asMap().entries.map((e) =>
                                         _leaderboardRow(e.key + 1, e.value, color, c.typeUnit)),
                                         const SizedBox(height: 8),
                                   ],
                                 );
                                                   }

                                                   Widget _leaderboardRow(int rank, ChallengeEntryModel entry,
                                                                          Color color, String unit) {
                                                     final isMe = entry.memberId == widget.memberId;
                                                     Widget rankWidget;
                                                     if (rank == 1) {
                                                       rankWidget = const Text('🥇', style: TextStyle(fontSize: 18));
                                                     } else if (rank == 2) {
                                                       rankWidget = const Text('🥈', style: TextStyle(fontSize: 18));
                                                     } else if (rank == 3) {
                                                       rankWidget = const Text('🥉', style: TextStyle(fontSize: 18));
                                                     } else {
                                                       rankWidget = SizedBox(
                                                         width: 28,
                                                         child: Text('#$rank',
                                                                     style: AppTextStyles.caption.copyWith(
                                                                       color: AppColors.gray400, fontWeight: FontWeight.bold)),
                                                       );
                                                     }

                                                     return Container(
                                                       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                       decoration: BoxDecoration(
                                                         color: isMe ? color.withValues(alpha: 0.12) : Colors.transparent,
                                                         borderRadius: BorderRadius.circular(12),
                                                         border: Border.all(
                                                           color: isMe
                                                           ? color.withValues(alpha: 0.4)
                                                           : Colors.transparent),
                                                       ),
                                                       child: Row(
                                                         children: [
                                                           SizedBox(width: 34, child: rankWidget),
                                                           const SizedBox(width: 4),
                                                           Container(
                                                             width: 36,
                                                             height: 36,
                                                             decoration: BoxDecoration(
                                                               color: color.withValues(alpha: 0.15),
                                                               shape: BoxShape.circle,
                                                               border: Border.all(color: color.withValues(alpha: 0.4)),
                                                             ),
                                                             child: Center(
                                                               child: Text(
                                                                 entry.memberName.isNotEmpty
                                                                 ? entry.memberName[0].toUpperCase()
                                                                 : '?',
                                                                 style: TextStyle(
                                                                   color: color,
                                                                   fontWeight: FontWeight.bold,
                                                                   fontSize: 14),
                                                               ),
                                                             ),
                                                           ),
                                                           const SizedBox(width: 10),
                                                           Expanded(
                                                             child: Row(
                                                               children: [
                                                                 Flexible(
                                                                   child: Text(entry.memberName,
                                                                               style: AppTextStyles.bodyMedium.copyWith(
                                                                                 fontWeight: FontWeight.bold,
                                                                                 color: isMe ? color : AppColors.white),
                                                                               maxLines: 1,
                                                                               overflow: TextOverflow.ellipsis),
                                                                 ),
                                                                 if (isMe) ...[
                                                                   const SizedBox(width: 6),
                                                                   Container(
                                                                     padding: const EdgeInsets.symmetric(
                                                                       horizontal: 6, vertical: 1),
                                                                       decoration: BoxDecoration(
                                                                         color: color,
                                                                         borderRadius: BorderRadius.circular(6)),
                                                                         child: Text('YOU',
                                                                                     style: TextStyle(
                                                                                       color: Colors.black,
                                                                                       fontSize: 9,
                                                                                       fontWeight: FontWeight.bold)),
                                                                   ),
                                                                 ],
                                                               ],
                                                             ),
                                                           ),
                                                           Text(_fmt(entry.score, unit),
                                                           style: AppTextStyles.bodyMedium.copyWith(
                                                             color: color, fontWeight: FontWeight.bold)),
                                                         ],
                                                       ),
                                                     );
                                                                          }

                                                                          // ── No Challenge ──────────────────────────────────────────────────────────

                                                                          Widget _buildNoChallengeState() {
                                                                            return Center(
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  const Text('⚔️', style: TextStyle(fontSize: 72)),
                                                                                  const SizedBox(height: 24),
                                                                                  Text('No Active Challenge', style: AppTextStyles.heading3),
                                                                                  const SizedBox(height: 8),
                                                                                  Text(
                                                                                    'Challenges are created by your gym admin.\nCheck back soon!',
                                                                                    style: AppTextStyles.bodyMedium
                                                                                    .copyWith(color: AppColors.gray400),
                                                                                    textAlign: TextAlign.center,
                                                                                  ),
                                                                                  const SizedBox(height: 32),
                                                                                  OutlinedButton.icon(
                                                                                    onPressed: () async {
                                                                                      await _service.createDemoChallenge();
                                                                                      if (mounted) {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                                                          content: Text('Demo challenge created! 🎉'),
                                                                                          backgroundColor: AppColors.neonLime,
                                                                                          behavior: SnackBarBehavior.floating,
                                                                                        ));
                                                                                      }
                                                                                    },
                                                                                    style: OutlinedButton.styleFrom(
                                                                                      side: BorderSide(
                                                                                        color: AppColors.neonLime.withValues(alpha: 0.5)),
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(14)),
                                                                                          padding: const EdgeInsets.symmetric(
                                                                                            horizontal: 24, vertical: 12),
                                                                                    ),
                                                                                    icon: const Icon(Icons.add_rounded, color: AppColors.neonLime),
                                                                                    label: const Text('CREATE TEST CHALLENGE',
                                                                                                      style:
                                                                                                      TextStyle(color: AppColors.neonLime, letterSpacing: 1)),
                                                                                  ),
                                                                                ],
                                                                              ).animate().fadeIn().scale(),
                                                                            );
                                                                          }
}

// ════════════════════════════════════════════════════════════════
// LOG PROGRESS BOTTOM SHEET
// ════════════════════════════════════════════════════════════════

class _LogProgressSheet extends StatefulWidget {
  final ChallengeModel challenge;
  final String memberId;
  final String memberName;
  final String teamId;
  final ChallengeService service;
  final int previousScore;

  const _LogProgressSheet({
    required this.challenge,
    required this.memberId,
    required this.memberName,
    required this.teamId,
    required this.service,
    required this.previousScore,
  });

  @override
  State<_LogProgressSheet> createState() => _LogProgressSheetState();
}

class _LogProgressSheetState extends State<_LogProgressSheet> {
  final _formKey   = GlobalKey<FormState>();
  final _scoreCtrl = TextEditingController();
  bool _isSaving   = false;

  @override
  void initState() {
    super.initState();
    if (widget.previousScore > 0) {
      _scoreCtrl.text = widget.previousScore.toString();
    }
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  bool get _isTeamA => widget.teamId == 'teamA';
  Color get _color  => _isTeamA ? AppColors.neonLime : AppColors.neonOrange;
  ChallengeTeam get _team =>
  _isTeamA ? widget.challenge.teamA : widget.challenge.teamB;

  String get _label {
    switch (widget.challenge.type) {
      case ChallengeType.stepWars:        return 'Total steps today';
      case ChallengeType.caloriesCrusher: return 'Calories burned today';
      case ChallengeType.workoutWarrior:  return 'Workouts completed today';
    }
  }

  String get _hint {
    switch (widget.challenge.type) {
      case ChallengeType.stepWars:        return 'e.g. 8500';
      case ChallengeType.caloriesCrusher: return 'e.g. 450';
      case ChallengeType.workoutWarrior:  return 'e.g. 2';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final newScore = int.parse(_scoreCtrl.text.trim());
      await widget.service.logProgress(
        challengeId:   widget.challenge.id,
        memberId:      widget.memberId,
        memberName:    widget.memberName,
        teamId:        widget.teamId,
        newScore:      newScore,
        previousScore: widget.previousScore,
      );
      if (mounted) {
        Navigator.pop(context);
        final diff    = newScore - widget.previousScore;
        final diffStr = diff >= 0 ? '+$diff' : '$diff';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Progress updated! $diffStr ${widget.challenge.typeUnit} added 💪'),
            backgroundColor: _color,
            behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray400.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(_team.emoji,
                       style: const TextStyle(fontSize: 24)),
                       const SizedBox(width: 10),
                       Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('LOG PROGRESS',
                                style: AppTextStyles.heading3),
                              Text(_team.name,
                                   style: AppTextStyles.caption.copyWith(
                                     color: _color,
                                     fontWeight: FontWeight.bold)),
                         ],
                       ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                                     color: AppColors.gray400),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.previousScore > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history_rounded,
                           color: AppColors.gray400, size: 16),
                           const SizedBox(width: 8),
                           Text(
                             'Previous: ${widget.previousScore} ${widget.challenge.typeUnit}',
                             style: AppTextStyles.caption
                             .copyWith(color: AppColors.gray400),
                           ),
                           const Spacer(),
                           Text('Enter your new total',
                                style: AppTextStyles.caption.copyWith(
                                  color: _color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller:       _scoreCtrl,
                keyboardType:     TextInputType.number,
                autofocus:        true,
                inputFormatters:  [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.heading1
                .copyWith(color: _color, fontSize: 40),
                textAlign: TextAlign.center,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a value';
                  }
                  if (int.tryParse(v.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText:  _label,
                  labelStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
                  hintText:   _hint,
                  hintStyle:  TextStyle(
                    color: AppColors.gray400.withValues(alpha: 0.3),
                    fontSize: 40),
                    filled:     true,
                    fillColor:  AppColors.backgroundBlack,
                    suffixText: widget.challenge.typeUnit,
                    suffixStyle: TextStyle(
                      color: _color, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: _color.withValues(alpha: 0.5), width: 2)),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                              const BorderSide(color: AppColors.error)),
                              contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _color,
                    foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor:
                        _color.withValues(alpha: 0.4),
                  ),
                  child: _isSaving
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2))
                  : const Text('UPDATE PROGRESS',
                               style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 letterSpacing: 1.5,
                                 fontSize: 16)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
