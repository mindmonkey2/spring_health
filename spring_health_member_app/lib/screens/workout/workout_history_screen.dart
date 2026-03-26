import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/workout_model.dart';
import '../../services/workout_service.dart';
import 'workout_detail_screen.dart';
import 'workout_logger_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  final String memberId;

  const WorkoutHistoryScreen({super.key, required this.memberId});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen>
    with SingleTickerProviderStateMixin {
  final _workoutService = WorkoutService();

  List<WorkoutLog> _allWorkouts = [];
  List<WorkoutLog> _filtered = [];
  bool _isLoading = true;
  String? _error;

  // Filters
  String _selectedFilter = 'All';
  String _sortBy = 'Newest';

  static const _filters = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
  ];
  static const _sortOptions = ['Newest', 'Oldest', 'Most Volume', 'Longest'];

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final workouts = await _workoutService.getWorkoutHistory(widget.memberId);
      if (mounted) {
        setState(() {
          _allWorkouts = workouts;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load workouts';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<WorkoutLog> result = List.from(_allWorkouts);

    // Category filter
    if (_selectedFilter != 'All') {
      result = result
          .where(
            (w) => w.exercises.any(
              (e) => e.category.toLowerCase() == _selectedFilter.toLowerCase(),
            ),
          )
          .toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Newest':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Most Volume':
        result.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
        break;
      case 'Longest':
        result.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
        break;
    }

    setState(() => _filtered = result);
  }

  // ─────────────────────────────────────
  // COMPUTED STATS
  // ─────────────────────────────────────
  int get _totalVolume =>
      _allWorkouts.fold(0, (total, w) => total + w.totalVolume);

  int get _totalSessions => _allWorkouts.length;

  int get _totalMinutes =>
      _allWorkouts.fold(0, (total, w) => total + w.durationMinutes);

  int get _thisWeekSessions {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _allWorkouts
        .where(
          (w) => w.date.isAfter(
            DateTime(weekStart.year, weekStart.month, weekStart.day),
          ),
        )
        .length;
  }

  // Group workouts by month
  Map<String, List<WorkoutLog>> get _groupedByMonth {
    final grouped = <String, List<WorkoutLog>>{};
    for (final w in _filtered) {
      final key = DateFormat('MMMM yyyy').format(w.date);
      grouped.putIfAbsent(key, () => []).add(w);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: Text(
          'WORKOUT HISTORY',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        actions: [
          // Sort dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.sort_rounded, color: AppColors.neonLime),
            color: AppColors.cardSurface,
            onSelected: (val) {
              setState(() => _sortBy = val);
              _applyFilters();
            },
            itemBuilder: (_) => _sortOptions
                .map(
                  (s) => PopupMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Icon(
                          _sortBy == s
                              ? Icons.check_rounded
                              : Icons.circle_outlined,
                          color: _sortBy == s
                              ? AppColors.neonLime
                              : AppColors.gray600,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          s,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _sortBy == s
                                ? AppColors.neonLime
                                : AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          IconButton(
            onPressed: _loadWorkouts,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.neonLime),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final saved = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutLoggerScreen(memberId: widget.memberId),
            ),
          );
          if (saved == true) _loadWorkouts();
        },
        backgroundColor: AppColors.neonLime,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'LOG WORKOUT',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _allWorkouts.isEmpty
          ? _buildEmptyState()
          : _buildContent(),
    );
  }

  // ─────────────────────────────────────
  // CONTENT
  // ─────────────────────────────────────
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadWorkouts,
      color: AppColors.neonLime,
      backgroundColor: AppColors.cardSurface,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Stats Summary
          SliverToBoxAdapter(child: _buildStatsSummary()),

          // Category Filter chips
          SliverToBoxAdapter(child: _buildFilterChips()),

          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    '${_filtered.length} WORKOUT${_filtered.length != 1 ? 'S' : ''}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray400,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedFilter != 'All')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonTeal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _selectedFilter,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neonTeal,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Grouped workout list
          if (_filtered.isEmpty)
            SliverToBoxAdapter(child: _buildNoResults())
          else
            ..._buildGroupedList(),

          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // STATS SUMMARY
  // ─────────────────────────────────────
  Widget _buildStatsSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.15),
            AppColors.neonTeal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALL TIME STATS',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.neonLime,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat(
                '$_totalSessions',
                'Sessions',
                Icons.fitness_center_rounded,
                AppColors.neonLime,
              ),
              _buildStatDivider(),
              _buildStat(
                '${(_totalMinutes / 60).toStringAsFixed(1)}h',
                'Total Time',
                Icons.timer_rounded,
                AppColors.neonTeal,
              ),
              _buildStatDivider(),
              _buildStat(
                '${_totalVolume}kg',
                'Volume',
                Icons.monitor_weight_rounded,
                AppColors.neonOrange,
              ),
              _buildStatDivider(),
              _buildStat(
                '$_thisWeekSessions',
                'This Week',
                Icons.calendar_today_rounded,
                Colors.purpleAccent,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white.withValues(alpha: 0.07),
  );

  // ─────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          final color = filter == 'All'
              ? AppColors.neonLime
              : _getCategoryColor(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedFilter = filter);
                _applyFilters();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.2)
                      : AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.white10,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? color : AppColors.gray400,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  // ─────────────────────────────────────
  // GROUPED LIST
  // ─────────────────────────────────────
  List<Widget> _buildGroupedList() {
    final grouped = _groupedByMonth;
    final slivers = <Widget>[];

    grouped.forEach((month, workouts) {
      // Month header
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Text(
                  month.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neonTeal,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 1,
                    color: AppColors.neonTeal.withValues(alpha: 0.2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${workouts.length} session${workouts.length > 1 ? 's' : ''}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Workout cards for this month
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWorkoutCard(workouts[index], index),
            ),
            childCount: workouts.length,
          ),
        ),
      );
    });

    return slivers;
  }

  // ─────────────────────────────────────
  // WORKOUT CARD
  // ─────────────────────────────────────
  Widget _buildWorkoutCard(WorkoutLog workout, int index) {
    // Determine dominant category
    final categoryCounts = <String, int>{};
    for (final e in workout.exercises) {
      categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
    }
    final dominantCategory = categoryCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    final color = _getCategoryColor(dominantCategory);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(workout: workout),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Title + Date
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(dominantCategory),
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat(
                          'EEE, dd MMM yyyy • hh:mm a',
                        ).format(workout.date),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.gray600),
              ],
            ),

            const SizedBox(height: 14),

            // Row 2: Stats chips
            Row(
              children: [
                _buildChip(
                  Icons.timer_rounded,
                  '${workout.durationMinutes}m',
                  AppColors.neonTeal,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  Icons.fitness_center_rounded,
                  '${workout.exercises.length} ex',
                  AppColors.neonLime,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  Icons.monitor_weight_rounded,
                  '${workout.totalVolume}kg',
                  AppColors.neonOrange,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  Icons.local_fire_department_rounded,
                  '${workout.caloriesBurned} cal',
                  Colors.redAccent,
                ),
              ],
            ),

            // Row 3: Muscle group tags
            if (workout.exercises.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildMuscleTags(workout),
            ],

            // Row 4: Notes snippet
            if ((workout.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notes_rounded, size: 12, color: AppColors.gray600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      workout.notes ?? '',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleTags(WorkoutLog workout) {
    final categories = workout.exercises
        .map((e) => e.category)
        .toSet()
        .toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: categories.map((cat) {
        final color = _getCategoryColor(cat);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            cat,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.neonLime),
          const SizedBox(height: 16),
          Text(
            'LOADING WORKOUTS...',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadWorkouts,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonLime.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 48,
              color: AppColors.neonLime,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Workouts Yet',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your first workout to start tracking!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final saved = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      WorkoutLoggerScreen(memberId: widget.memberId),
                ),
              );
              if (saved == true) _loadWorkouts();
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('LOG FIRST WORKOUT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppColors.gray600),
            const SizedBox(height: 12),
            Text(
              'No $_selectedFilter workouts found',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray400,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _selectedFilter = 'All');
                _applyFilters();
              },
              child: Text(
                'CLEAR FILTER',
                style: TextStyle(color: AppColors.neonLime),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return AppColors.neonOrange;
      case 'back':
        return AppColors.neonTeal;
      case 'legs':
        return AppColors.neonLime;
      case 'shoulders':
        return AppColors.turquoise;
      case 'arms':
        return Colors.purpleAccent;
      case 'core':
        return Colors.amber;
      case 'cardio':
        return Colors.redAccent;
      default:
        return AppColors.gray400;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return Icons.accessibility_new_rounded;
      case 'back':
        return Icons.airline_seat_recline_normal_rounded;
      case 'legs':
        return Icons.directions_run_rounded;
      case 'shoulders':
        return Icons.fitness_center_rounded;
      case 'arms':
        return Icons.sports_gymnastics_rounded;
      case 'core':
        return Icons.rotate_90_degrees_cw_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }
}
