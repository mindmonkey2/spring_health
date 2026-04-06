import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/weekly_war_model.dart';
import '../../services/weekly_war_service.dart';
import '../../core/theme/app_colors.dart';

class WarScreen extends StatefulWidget {
  final String memberId;
  final String memberName;
  final String branch;

  const WarScreen({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.branch,
  });

  @override
  State<WarScreen> createState() => _WarScreenState();
}

class _WarScreenState extends State<WarScreen> {
  Timer? _countdownTimer;
  String _timeRemaining = '';

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime endDate) {
    _countdownTimer?.cancel();
    _updateTimeRemaining(endDate);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateTimeRemaining(endDate);
        });
      }
    });
  }

  void _updateTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      _timeRemaining = 'Ended';
      _countdownTimer?.cancel();
      return;
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    _timeRemaining = 'Ends in  ${days}d ${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundBlack,
          title: const Text('War', style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: AppColors.neonLime,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.neonLime,
            tabs: [
              Tab(text: '⚔️ THIS WEEK'),
              Tab(text: '🥊 1v1 DUELS'),
              Tab(text: '🏆 HISTORY'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildThisWeekTab(),
            _buildDuelsTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildThisWeekTab() {
    return FutureBuilder<WeeklyWarModel?>(
      future: WeeklyWarService.instance.getActiveWar(widget.branch),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonLime),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong', style: TextStyle(color: Colors.red)),
          );
        }

        final war = snapshot.data;
        if (war == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.neonLime),
                SizedBox(height: 16),
                Text('No active war this week', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Check back Monday 6 AM', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          );
        }

        if (_countdownTimer == null || !_countdownTimer!.isActive) {
          _startCountdown(war.endDate);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION A - War Banner Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonLime, width: 1),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonLime.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('WEEK ${war.weekNumber}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Text(war.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(war.exercise, style: const TextStyle(color: AppColors.neonLime, fontSize: 36, fontWeight: FontWeight.w900)),
                    Text('Max ${war.unit} this week', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer, color: AppColors.info, size: 16),
                        const SizedBox(width: 4),
                        Text(_timeRemaining, style: const TextStyle(color: AppColors.info, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonLime,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/workout-logger',
                            arguments: {'prefilledExercise': war.exercise},
                          );
                        },
                        child: const Text('LOG IT NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION B - Member's Own Entry Card
              FutureBuilder<WarEntryModel?>(
                future: WeeklyWarService.instance.getMemberEntry(war.id, widget.memberId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.neonLime));
                  }
                  if (snapshot.hasError) {
                    return const Text('Something went wrong', style: TextStyle(color: Colors.red));
                  }
                  final entry = snapshot.data;
                  if (entry == null) {
                    return Text('You haven\'t logged ${war.exercise} yet this week — start now!', style: const TextStyle(color: Colors.grey));
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YOUR STATS', style: TextStyle(color: AppColors.info, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${entry.totalReps} ${war.unit}', style: const TextStyle(color: AppColors.neonLime, fontSize: 24, fontWeight: FontWeight.bold)),
                            Text('Rank #${entry.rank ?? '?'}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${entry.sessionCount} session(s) logged', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // SECTION C - Prize Pool Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPrizeChip('🥇 500 XP', Colors.amber),
                    const SizedBox(width: 8),
                    _buildPrizeChip('🥈 300 XP', Colors.grey[600]!),
                    const SizedBox(width: 8),
                    _buildPrizeChip('🥉 150 XP', Colors.brown[400]!),
                    const SizedBox(width: 8),
                    _buildPrizeChip('🎯 20 XP participation', AppColors.cardSurface),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SECTION D - Live Leaderboard
              const Text('LIVE LEADERBOARD', style: TextStyle(color: AppColors.info, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<List<WarEntryModel>>(
                stream: WeeklyWarService.instance.getWarLeaderboard(war.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.neonLime));
                  }
                  if (snapshot.hasError) {
                    return const Text('Something went wrong', style: TextStyle(color: Colors.red));
                  }

                  final entries = snapshot.data ?? [];
                  if (entries.isEmpty) {
                    return const Text('No entries yet.', style: TextStyle(color: Colors.grey));
                  }

                  final topEntries = entries.take(10).toList();

                  return Column(
                    children: topEntries.asMap().entries.map((mapEntry) {
                      final index = mapEntry.key;
                      final entry = mapEntry.value;
                      final rank = index + 1;

                      String rankText;
                      if (rank == 1) {
                        rankText = '🥇';
                      } else if (rank == 2) {
                        rankText = '🥈';
                      } else if (rank == 3) {
                        rankText = '🥉';
                      } else {
                        rankText = '#$rank';
                      }

                      final isCurrentMember = entry.memberName == widget.memberName;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: isCurrentMember ? BoxDecoration(
                          border: Border.all(color: AppColors.neonLime, width: 1),
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.cardSurface,
                        ) : null,
                        child: ListTile(
                          leading: Text(rankText, style: const TextStyle(fontSize: 18)),
                          title: Text(entry.memberName, style: TextStyle(color: Colors.white, fontWeight: isCurrentMember ? FontWeight.bold : FontWeight.normal)),
                          trailing: Text('${entry.totalReps} ${war.unit}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrizeChip(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDuelsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.sports_kabaddi, size: 64, color: AppColors.info),
          SizedBox(height: 16),
          Text('1v1 Duels', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Challenge a gym mate to a head-to-head battle.\nComing soon.', style: TextStyle(color: Colors.grey, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<WeeklyWarModel>>(
      future: WeeklyWarService.instance.getWarHistory(widget.branch),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.neonLime));
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong', style: TextStyle(color: Colors.red)));
        }

        final pastWars = snapshot.data ?? [];
        if (pastWars.isEmpty) {
          return const Center(child: Text('No past wars yet', style: TextStyle(color: Colors.grey)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pastWars.length,
          itemBuilder: (context, index) {
            final war = pastWars[index];
            final isCompleted = war.status == 'completed';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Week ${war.weekNumber}', style: const TextStyle(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(war.status, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(war.exercise, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${war.category}  •  ${war.unit}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (war.winnerName != null && war.winnerName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, size: 16, color: AppColors.neonLime),
                        const SizedBox(width: 4),
                        Text(' ${war.winnerName}', style: const TextStyle(color: AppColors.neonLime, fontSize: 12)),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
