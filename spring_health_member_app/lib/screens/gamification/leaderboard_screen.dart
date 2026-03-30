import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/gamification_model.dart';
import '../../services/gamification_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String memberId;

  const LeaderboardScreen({super.key, required this.memberId});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _gamService = GamificationService();

  // Tab configs
  static const _tabs = [
    _LeaderboardTab(label: 'XP', sortBy: 'totalXp', icon: Icons.bolt_rounded),
    _LeaderboardTab(
      label: 'STREAK',
      sortBy: 'currentStreak',
      icon: Icons.local_fire_department_rounded,
    ),
    _LeaderboardTab(
      label: 'WORKOUTS',
      sortBy: 'totalWorkouts',
      icon: Icons.fitness_center_rounded,
    ),
  ];

  // Cache results per tab
  final Map<String, List<LeaderboardEntry>> _cache = {};
  final Map<String, bool> _loading = {};
  final Map<String, String?> _errors = {};
  int? _myRank;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadTab(_tabs[_tabController.index].sortBy);
      }
    });
    _loadTab('totalXp');
    _loadMyRank();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTab(String sortBy) async {
    if (_cache.containsKey(sortBy)) return; // already loaded
    setState(() {
      _loading[sortBy] = true;
      _errors[sortBy] = null;
    });
    try {
      final entries = await _gamService.getLeaderboardWithNames(sortBy: sortBy);
      if (mounted) {
        setState(() {
          _cache[sortBy] = entries;
          _loading[sortBy] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errors[sortBy] = 'Failed to load leaderboard';
          _loading[sortBy] = false;
        });
      }
    }
  }

  Future<void> _loadMyRank() async {
    final rank = await _gamService.getMemberRank(widget.memberId);
    if (mounted) setState(() => _myRank = rank);
  }

  Future<void> _refresh() async {
    _cache.clear();
    final sortBy = _tabs[_tabController.index].sortBy;
    await _loadTab(sortBy);
    await _loadMyRank();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: Text(
          'LEADERBOARD',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.neonLime),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonLime,
          indicatorWeight: 2,
          labelColor: AppColors.neonLime,
          unselectedLabelColor: AppColors.gray400,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
          tabs: _tabs
              .map((t) => Tab(icon: Icon(t.icon, size: 16), text: t.label))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return _buildTabContent(tab);
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────
  // TAB CONTENT
  // ─────────────────────────────────────
  Widget _buildTabContent(_LeaderboardTab tab) {
    final isLoading = _loading[tab.sortBy] ?? true;
    final error = _errors[tab.sortBy];
    final entries = _cache[tab.sortBy] ?? [];

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.neonLime),
            const SizedBox(height: 16),
            Text(
              'LOADING RANKS...',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray400,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('RETRY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.gray600,
            ),
            const SizedBox(height: 16),
            Text(
              'No data yet',
              style: AppTextStyles.heading3.copyWith(color: AppColors.gray400),
            ),
            Text(
              'Be the first to earn XP!',
              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.neonLime,
      backgroundColor: AppColors.cardSurface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ✅ Podium — top 3
            if (entries.length >= 3) _buildPodium(entries, tab.sortBy),

            const SizedBox(height: 24),

            // ✅ My rank banner
            if (_myRank != null && _myRank! > 3)
              _buildMyRankBanner(entries, tab.sortBy),

            // ✅ Full ranked list (4+)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: entries.skip(3).toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final e = entry.value;
                  final isMe = e.memberId == widget.memberId;
                  return _buildRankRow(
                    e,
                    tab.sortBy,
                    isMe: isMe,
                    delay: (index * 60),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // PODIUM
  // ─────────────────────────────────────
  Widget _buildPodium(List<LeaderboardEntry> entries, String sortBy) {
    final first = entries[0];
    final second = entries[1];
    final third = entries[2];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Crown above 1st
          Icon(Icons.auto_awesome_rounded, color: AppColors.warning, size: 28)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 1500.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 8),

          // Podium row: 2nd | 1st | 3rd
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              Expanded(
                child: _buildPodiumCard(
                  second,
                  rank: 2,
                  height: 130,
                  color: AppColors.silver, // silver
                  sortBy: sortBy,
                  delay: 200,
                ),
              ),
              const SizedBox(width: 8),
              // 1st place — tallest
              Expanded(
                child: _buildPodiumCard(
                  first,
                  rank: 1,
                  height: 170,
                  color: AppColors.gold,
                  sortBy: sortBy,
                  delay: 0,
                ),
              ),
              const SizedBox(width: 8),
              // 3rd place
              Expanded(
                child: _buildPodiumCard(
                  third,
                  rank: 3,
                  height: 110,
                  color: AppColors.bronze, // bronze
                  sortBy: sortBy,
                  delay: 400,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildPodiumCard(
    LeaderboardEntry entry, {
    required int rank,
    required double height,
    required Color color,
    required String sortBy,
    required int delay,
  }) {
    final isMe = entry.memberId == widget.memberId;
    final statValue = _getStatValue(entry, sortBy);
    final statLabel = _getStatLabel(sortBy);

    return Column(
      children: [
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isMe ? AppColors.neonLime : color,
                  width: isMe ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipOval(
                child: entry.photoUrl != null
                    ? Image.network(
                        entry.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _buildAvatarFallback(entry.memberName, color),
                      )
                    : _buildAvatarFallback(entry.memberName, color),
              ),
            ),
            // Rank badge
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.backgroundBlack,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Name
        Text(
          entry.memberName.split(' ').first,
          style: AppTextStyles.caption.copyWith(
            color: isMe ? AppColors.neonLime : AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        // Level
        Text(
          entry.level.title,
          style: TextStyle(
            color: entry.level.color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        // Podium block
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                statValue,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                statLabel,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
              if (entry.earnedBadgeCount > 0) ...[
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.military_tech_rounded,
                      size: 10,
                      color: AppColors.warning,
                    ),
                    Text(
                      ' ${entry.earnedBadgeCount}',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.3, end: 0);
  }

  // ─────────────────────────────────────
  // MY RANK BANNER
  // ─────────────────────────────────────
  Widget _buildMyRankBanner(List<LeaderboardEntry> entries, String sortBy) {
    final myEntry = entries.firstWhere(
      (e) => e.memberId == widget.memberId,
      orElse: () => LeaderboardEntry(
        rank: _myRank ?? 0,
        memberId: widget.memberId,
        memberName: 'You',
        photoUrl: null,
        totalXp: 0,
        currentStreak: 0,
        totalWorkouts: 0,
        totalCheckIns: 0,
        earnedBadgeCount: 0,
        level: GymLevel.levels.first,
      ),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.neonLime.withValues(alpha: 0.15),
            AppColors.neonTeal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.neonLime.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.neonLime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.neonLime.withValues(alpha: 0.4),
              ),
            ),
            child: Center(
              child: Text(
                '#${myEntry.rank}',
                style: TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR RANK',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neonLime,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${_getStatValue(myEntry, sortBy)} ${_getStatLabel(sortBy)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(myEntry.level.icon, color: myEntry.level.color, size: 20),
          const SizedBox(width: 6),
          Text(
            myEntry.level.title,
            style: TextStyle(
              color: myEntry.level.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0);
  }

  // ─────────────────────────────────────
  // RANK ROW (4th place and below)
  // ─────────────────────────────────────
  Widget _buildRankRow(
    LeaderboardEntry entry,
    String sortBy, {
    required bool isMe,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.neonLime.withValues(alpha: 0.08)
            : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe
              ? AppColors.neonLime.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? AppColors.neonLime : AppColors.gray400,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe
                    ? AppColors.neonLime
                    : entry.level.color.withValues(alpha: 0.4),
                width: isMe ? 2 : 1,
              ),
            ),
            child: ClipOval(
              child: entry.photoUrl != null
                  ? Image.network(
                      entry.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildAvatarFallback(
                        entry.memberName,
                        entry.level.color,
                      ),
                    )
                  : _buildAvatarFallback(entry.memberName, entry.level.color),
            ),
          ),

          const SizedBox(width: 12),

          // Name + Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isMe ? '${entry.memberName} (You)' : entry.memberName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isMe ? AppColors.neonLime : AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(entry.level.icon, size: 10, color: entry.level.color),
                    const SizedBox(width: 4),
                    Text(
                      'LV${entry.level.level} ${entry.level.title}',
                      style: TextStyle(
                        color: entry.level.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.earnedBadgeCount > 0) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.military_tech_rounded,
                        size: 10,
                        color: AppColors.warning,
                      ),
                      Text(
                        ' ${entry.earnedBadgeCount}',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Stat value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getStatValue(entry, sortBy),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isMe ? AppColors.neonLime : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getStatLabel(sortBy),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray600,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.05, end: 0);
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────
  Widget _buildAvatarFallback(String name, Color color) {
    return Container(
      color: color.withValues(alpha: 0.15),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getStatValue(LeaderboardEntry entry, String sortBy) {
    switch (sortBy) {
      case 'totalXp':
        return '${entry.totalXp} XP';
      case 'currentStreak':
        return '${entry.currentStreak}';
      case 'totalWorkouts':
        return '${entry.totalWorkouts}';
      default:
        return '${entry.totalXp} XP';
    }
  }

  String _getStatLabel(String sortBy) {
    switch (sortBy) {
      case 'totalXp':
        return 'XP';
      case 'currentStreak':
        return 'day streak';
      case 'totalWorkouts':
        return 'workouts';
      default:
        return 'XP';
    }
  }
}

// ─────────────────────────────────────
// TAB CONFIG
// ─────────────────────────────────────
class _LeaderboardTab {
  final String label;
  final String sortBy;
  final IconData icon;

  const _LeaderboardTab({
    required this.label,
    required this.sortBy,
    required this.icon,
  });
}
