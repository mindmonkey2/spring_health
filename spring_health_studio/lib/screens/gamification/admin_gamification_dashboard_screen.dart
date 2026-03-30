// lib/screens/gamification/admin_gamification_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/admin_leaderboard_entry.dart';
import '../../services/admin_gamification_service.dart';
import '../../theme/app_colors.dart';

class AdminGamificationDashboardScreen extends StatefulWidget {
  const AdminGamificationDashboardScreen({super.key});

  @override
  State<AdminGamificationDashboardScreen> createState() =>
      _AdminGamificationDashboardScreenState();
}

class _AdminGamificationDashboardScreenState
    extends State<AdminGamificationDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tab;
  final service = AdminGamificationService();

  // ── State ──────────────────────────────────────────────────────────────────
  String branchFilter = 'All';
  final List<String> branches = ['All', 'Hanamkonda', 'Warangal'];

  late Future<int?> challengesFuture;
  late Future<int?> entriesFuture;
  late Future<Map<String, dynamic>> gymStatsFuture;

  @override
  void initState() {
    super.initState();
    tab = TabController(length: 3, vsync: this);
    refresh();
  }

  void refresh() {
    setState(() {
      challengesFuture = service.getChallengesCount();
      entriesFuture = service.getChallengeEntriesCount();
      gymStatsFuture = service.getGymXpStats();
    });
  }

  @override
  void dispose() {
    tab.dispose();
    super.dispose();
  }

  Future<List<AdminLeaderboardEntry>> futureForTab(int i) {
    final sortBy = i == 0 ? 'totalXp' : i == 1 ? 'currentStreak' : 'totalWorkouts';
    return service.getLeaderboard(
      sortBy: sortBy,
      limit: 50,
      branch: branchFilter == 'All' ? null : branchFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.success, AppColors.turquoise]),
                ),
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gamification',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 2),
                        Text('XP · Streaks · Badges',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: AppColors.turquoise,
                child: TabBar(
                  controller: tab,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                  tabs: const [
                    Tab(text: 'XP'),
                    Tab(text: 'Streaks'),
                    Tab(text: 'Workouts'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: RefreshIndicator(
          color: AppColors.success,
          onRefresh: () async => refresh(),
          child: Column(
            children: [
              _StatsStrip(
                challengesFuture: challengesFuture,
                entriesFuture: entriesFuture,
                gymStatsFuture: gymStatsFuture,
                green: AppColors.success,
                teal: AppColors.turquoise,
                orange: AppColors.warning,
              ),
              _BranchFilter(
                selected: branchFilter,
                branches: branches,
                green: AppColors.success,
                onChanged: (b) => setState(() => branchFilter = b),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: TabBarView(
                  controller: tab,
                  children: List.generate(
                    3,
                    (i) => _LeaderboardTab(
                      future: futureForTab(i),
                      tabIndex: i,
                      green: AppColors.success,
                      teal: AppColors.turquoise,
                      orange: AppColors.warning,
                      card: AppColors.surface,
                      textDark: AppColors.textPrimary,
                      textMid: AppColors.textSecondary,
                      service: service,
                      onActionDone: refresh,
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
}

// ═══════════════════════════════════════════════════════════════════════════
// STATS STRIP
// ═══════════════════════════════════════════════════════════════════════════
class _StatsStrip extends StatelessWidget {
  final Future<int?> challengesFuture;
  final Future<int?> entriesFuture;
  final Future<Map<String, dynamic>> gymStatsFuture;
  final Color green, teal, orange;

  const _StatsStrip({
    required this.challengesFuture,
    required this.entriesFuture,
    required this.gymStatsFuture,
    required this.green,
    required this.teal,
    required this.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: FutureBuilder<Map<String, dynamic>>(
        future: gymStatsFuture,
        builder: (_, snap) {
          final totalXp = snap.data?['totalXp'] ?? 0;
          final activeMembers = snap.data?['activeMembers'] ?? 0;
          return Column(
            children: [
              Row(children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total XP Awarded',
                    value: NumberFormat.compact().format(totalXp),
                    icon: Icons.bolt_rounded,
                    color: orange,
                  ).animate().fadeIn(delay: 0.ms).slideX(begin: -0.05, end: 0),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Active Members',
                    value: activeMembers.toString(),
                    icon: Icons.people_rounded,
                    color: green,
                  ).animate().fadeIn(delay: 60.ms).slideX(begin: -0.05, end: 0),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: FutureBuilder<int?>(
                    future: challengesFuture,
                    builder: (_, s) => _StatCard(
                      label: 'Challenges',
                      value: s.data?.toString() ?? '—',
                      icon: Icons.flag_rounded,
                      color: teal,
                    ).animate().fadeIn(delay: 120.ms),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FutureBuilder<int?>(
                    future: entriesFuture,
                    builder: (_, s) => _StatCard(
                      label: 'Entries',
                      value: s.data?.toString() ?? '—',
                      icon: Icons.how_to_reg_rounded,
                      color: green,
                    ).animate().fadeIn(delay: 180.ms),
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BRANCH FILTER
// ═══════════════════════════════════════════════════════════════════════════
class _BranchFilter extends StatelessWidget {
  final String selected;
  final List<String> branches;
  final Color green;
  final ValueChanged<String> onChanged;

  const _BranchFilter({
    required this.selected,
    required this.branches,
    required this.green,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: branches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final b = branches[i];
          final active = b == selected;
          return GestureDetector(
            onTap: () => onChanged(b),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active ? green : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? green : Colors.grey.shade300,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                            color: green.withValues(alpha: 0.25),
                            blurRadius: 8)
                      ]
                    : [],
              ),
              child: Text(b,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey.shade600,
                      fontWeight: active
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13)),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEADERBOARD TAB
// ═══════════════════════════════════════════════════════════════════════════
class _LeaderboardTab extends StatelessWidget {
  final Future<List<AdminLeaderboardEntry>> future;
  final int tabIndex;
  final Color green, teal, orange, card, textDark, textMid;
  final AdminGamificationService service;
  final VoidCallback onActionDone;

  const _LeaderboardTab({
    required this.future,
    required this.tabIndex,
    required this.green,
    required this.teal,
    required this.orange,
    required this.card,
    required this.textDark,
    required this.textMid,
    required this.service,
    required this.onActionDone,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdminLeaderboardEntry>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: green));
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Failed to load: ${snap.error}'),
            ),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.leaderboard_outlined,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No leaderboard data yet',
                    style: TextStyle(color: Colors.grey.shade500)),
                const SizedBox(height: 6),
                Text('Award XP to members to populate the leaderboard',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          itemBuilder: (_, i) => _LeaderboardTile(
            entry: items[i],
            tabIndex: tabIndex,
            green: green,
            teal: teal,
            orange: orange,
            service: service,
            onActionDone: onActionDone,
          ).animate().fadeIn(delay: (i * 30).ms).slideX(begin: 0.04, end: 0),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEADERBOARD TILE
// ═══════════════════════════════════════════════════════════════════════════
class _LeaderboardTile extends StatelessWidget {
  final AdminLeaderboardEntry entry;
  final int tabIndex;
  final Color green, teal, orange;
  final AdminGamificationService service;
  final VoidCallback onActionDone;

  const _LeaderboardTile({
    required this.entry,
    required this.tabIndex,
    required this.green,
    required this.teal,
    required this.orange,
    required this.service,
    required this.onActionDone,
  });

  Color rankColor(int rank) {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return AppColors.silver;
    if (rank == 3) return AppColors.bronze;
    return green;
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      if ((entry.branch ?? '').isNotEmpty) entry.branch!,
      if ((entry.phone ?? '').isNotEmpty) entry.phone!,
    ];

    return Card(
      color: Colors.white,
      elevation: entry.rank <= 3 ? 4 : 1.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: entry.rank <= 3
            ? BorderSide(
                color: rankColor(entry.rank).withValues(alpha: 0.4),
                width: 1.5)
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: rankColor(entry.rank).withValues(alpha: 0.15),
          child: Text(
            entry.rank <= 3
                ? ['1st', '2nd', '3rd'][entry.rank - 1]
                : '${entry.rank}',
            style: TextStyle(
                color: rankColor(entry.rank),
                fontWeight: FontWeight.bold,
                fontSize: entry.rank <= 3 ? 18 : 13),
          ),
        ),
        title: Text(entry.memberName,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: subtitleParts.isEmpty
            ? null
            : Text(subtitleParts.join(' · '),
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.totalXp} XP',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: orange,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                    '${entry.currentStreak}d · ${entry.totalWorkouts}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert,
                  color: Colors.grey.shade400, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (v) => _handleAction(context, v),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'xpadd',
                  child: Row(children: [
                    Icon(Icons.add_circle_outline, color: orange, size: 18),
                    const SizedBox(width: 8),
                    const Text('Add XP'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'xpremove',
                  child: Row(children: [
                    Icon(Icons.remove_circle_outline,
                        color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    const Text('Deduct XP'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'badge',
                  child: Row(children: [
                    Icon(Icons.military_tech_rounded,
                        color: green, size: 18),
                    const SizedBox(width: 8),
                    const Text('Award Badge'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'streakreset',
                  child: Row(children: [
                    Icon(Icons.restart_alt_rounded,
                        color: Colors.red.shade400, size: 18),
                    const SizedBox(width: 8),
                    const Text('Reset Streak'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'details',
                  child: Row(children: [
                    Icon(Icons.info_outline,
                        color: Colors.grey.shade600, size: 18),
                    const SizedBox(width: 8),
                    const Text('View Details'),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    switch (action) {
      case 'xpadd':
      case 'xpremove':
        await _showXpDialog(context, add: action == 'xpadd');
        break;
      case 'badge':
        await _showBadgeDialog(context);
        break;
      case 'streakreset':
        await _confirmStreakReset(context);
        break;
      case 'details':
        _showDetailsSheet(context);
        break;
    }
  }

  // ── XP Dialog ─────────────────────────────────────────────────────────────
  Future<void> _showXpDialog(BuildContext context,
      {required bool add}) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(add ? 'Add XP' : 'Deduct XP',
            style: TextStyle(color: add ? orange : Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Member: ${entry.memberName}',
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'XP amount',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                suffixText: 'XP',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: add ? orange : Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(add ? 'ADD' : 'DEDUCT',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && ctrl.text.isNotEmpty) {
      final amount = int.tryParse(ctrl.text) ?? 0;
      if (amount > 0) {
        // ✅ FIX: use adjustXpSafe which uses set+merge so doc is created
        // if it doesn't exist yet — fixes empty leaderboard after admin XP award
        await service.adjustXp(
          memberId: entry.memberId,
          delta: add ? amount : -amount,
          reason: add ? 'Admin bonus' : 'Admin correction',
        );
        onActionDone();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${add ? '+' : '-'}$amount XP ${add ? 'added to' : 'deducted from'} ${entry.memberName}'),
            backgroundColor: add ? orange : Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }
  }

  // ── Badge Dialog ───────────────────────────────────────────────────────────
  // FIX 1: badges defined outside builder — no more infinite duplication
  // FIX 2: SizedBox+ListView instead of Column — no overflow
  // FIX 3: StatefulBuilder tracks selection — AWARD button now responds
  Future<void> _showBadgeDialog(BuildContext context) async {
    const badges = [
      ('Trophy', 'Champion', 'champion'),
      ('Energy', 'Power Week', 'power_week'),
      ('', 'On Fire', 'on_fire'),
      ('', 'Diamond Member', 'diamond'),
      ('', 'Goal Crusher', 'goal_crusher'),
      ('Lion', 'Iron Week', 'iron_week'),
      ('Boost', 'Rocket Start', 'rocket_start'),
      ('', 'All Star', 'all_star'),
    ];

    String? selected;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Award Badge to ${entry.memberName}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          // ✅ FIX: bounded SizedBox prevents overflow
          content: SizedBox(
            width: double.maxFinite,
            height: 320,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final b = badges[i];
                final isSelected = selected == b.$3;
                return GestureDetector(
                  onTap: () => setSt(() => selected = b.$3),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? green.withValues(alpha: 0.1)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? green : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Text(b.$1,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(b.$2,
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 14)),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: green, size: 20),
                    ]),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                // ✅ FIX: disabled until a badge is selected
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: selected == null
                  ? null
                  : () => Navigator.pop(ctx, true),
              child: const Text('AWARD',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && selected != null) {
      // ✅ FIX: set+merge so doc is created if it doesn't exist
      await service.awardBadge(
          memberId: entry.memberId, badgeId: selected!);
      onActionDone();
      if (context.mounted) {
        final badge = badges.firstWhere((b) => b.$3 == selected);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('${badge.$1} ${badge.$2} awarded to ${entry.memberName}'),
          backgroundColor: green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Streak Reset ──────────────────────────────────────────────────────────
  Future<void> _confirmStreakReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Streak?'),
        content: Text(
            'This will reset ${entry.memberName}\'s current streak '
            '(${entry.currentStreak} days) to 0. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await service.resetStreak(memberId: entry.memberId);
      onActionDone();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Streak reset for ${entry.memberName}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Details Sheet ─────────────────────────────────────────────────────────
  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MemberGamificationSheet(
        entry: entry,
        green: green,
        teal: teal,
        orange: orange,
        service: service,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MEMBER DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _MemberGamificationSheet extends StatelessWidget {
  final AdminLeaderboardEntry entry;
  final Color green, teal, orange;
  final AdminGamificationService service;

  const _MemberGamificationSheet({
    required this.entry,
    required this.green,
    required this.teal,
    required this.orange,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: green.withValues(alpha: 0.12),
                radius: 24,
                child: Text(
                  entry.memberName.isNotEmpty
                      ? entry.memberName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.memberName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800)),
                    if ((entry.branch ?? '').isNotEmpty)
                      Text(entry.branch!,
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              Text('Rank #${entry.rank}',
                  style: TextStyle(
                      color: green, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Divider(height: 1),
          // Stats
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.all(20),
              children: [
                _detailGrid(),
                const SizedBox(height: 20),
                _recentXpSection(),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _detailGrid() {
    final stats = [
      ('Total XP', '${entry.totalXp}', orange),
      ('Current Streak', '${entry.currentStreak} days', AppColors.warning),
      ('Best Streak', '${entry.longestStreak} days', teal),
      ('Workouts', '${entry.totalWorkouts}', green),
      ('Check-ins', '${entry.totalCheckIns}', AppColors.info),
      ('Badges', '${entry.badgeCount}', AppColors.gold),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: stats
          .map((s) => Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: s.$3.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: s.$3.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.$1,
                        style: const TextStyle(fontSize: 12)),
                    Text(s.$2,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: s.$3)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _recentXpSection() {
    final events = entry.recentXpEvents ?? [];
    if (events.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent XP Events',
            style:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 10),
        ...events.take(5).map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.bolt_rounded, color: orange, size: 16),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(e['reason'] ?? '',
                        style: const TextStyle(fontSize: 13))),
                Text('${e['xp'] ?? 0} XP',
                    style: TextStyle(
                        color: orange, fontWeight: FontWeight.w700)),
              ]),
            )),
      ],
    );
  }
}
