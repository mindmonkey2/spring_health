import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/attendance_model.dart';
import '../../models/gamification_model.dart';
import '../../services/attendance_service.dart';
import '../../services/gamification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class MemberAttendanceScreen extends StatefulWidget {
  final String memberId;
  final String memberName;

  const MemberAttendanceScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  @override
  State<MemberAttendanceScreen> createState() => _MemberAttendanceScreenState();
}

class _MemberAttendanceScreenState extends State<MemberAttendanceScreen> {
  final _attendanceService = AttendanceService();
  final _gamService = GamificationService();

  List<AttendanceModel> _records = [];
  MemberGamification? _gam;
  Set<String> _checkedInDates = {};
  bool _isLoading = true;
  String? _error;

  String _selectedFilter = 'all'; // all, thisMonth, lastMonth

  // Calendar navigation
  DateTime _calendarMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _attendanceService.getHistory(widget.memberId),
        _gamService.getOrCreate(widget.memberId),
      ]);
      if (mounted) {
        final records = results[0] as List<AttendanceModel>;
        setState(() {
          _records = records;
          _gam = results[1] as MemberGamification;
          _checkedInDates = _attendanceService.buildCheckedInDates(records);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // ─────────────────────────────────────
  // FILTERS + COMPUTED
  // ─────────────────────────────────────
  List<AttendanceModel> get _filtered {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'thisMonth':
        return _records
            .where(
              (a) =>
                  a.checkInTime.year == now.year &&
                  a.checkInTime.month == now.month,
            )
            .toList();
      case 'lastMonth':
        final last = DateTime(now.year, now.month - 1);
        return _records
            .where(
              (a) =>
                  a.checkInTime.year == last.year &&
                  a.checkInTime.month == last.month,
            )
            .toList();
      default:
        return _records;
    }
  }

  int get _thisWeekCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _records.where((a) => a.checkInTime.isAfter(weekAgo)).length;
  }

  int get _thisMonthCount => _records.where((a) => a.isThisMonth).length;

  bool _isCheckedIn(DateTime day) {
    final key = '${day.year}-${day.month}-${day.day}';
    return _checkedInDates.contains(key);
  }

  List<AttendanceModel> get _calendarMonthRecords => _records
      .where(
        (r) =>
            r.checkInTime.year == _calendarMonth.year &&
            r.checkInTime.month == _calendarMonth.month,
      )
      .toList();

  Map<String, int> get _timeOfDayBreakdown {
    final map = <String, int>{
      'Early Bird': 0,
      'Morning': 0,
      'Afternoon': 0,
      'Evening': 0,
      'Night Owl': 0,
    };
    for (final r in _records) {
      final h = r.checkInTime.hour;
      final slot = h < 7
          ? 'Early Bird'
          : h < 12
          ? 'Morning'
          : h < 17
          ? 'Afternoon'
          : h < 20
          ? 'Evening'
          : 'Night Owl';
      map[slot] = (map[slot] ?? 0) + 1;
    }
    return map;
  }

  // ─────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        title: Text(
          'MY ATTENDANCE',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.neonLime),
            color: AppColors.cardSurface,
            onSelected: (val) => setState(() => _selectedFilter = val),
            itemBuilder: (_) => [
              _filterItem('all', 'All Time'),
              _filterItem('thisMonth', 'This Month'),
              _filterItem('lastMonth', 'Last Month'),
            ],
          ),
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.neonLime),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _error != null
          ? _buildError()
          : _buildContent(),
    );
  }

  PopupMenuItem<String> _filterItem(String value, String label) {
    final isSelected = _selectedFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_rounded : Icons.circle_outlined,
            color: isSelected ? AppColors.neonLime : AppColors.gray600,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.neonLime : AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.neonLime,
      backgroundColor: AppColors.cardSurface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsSummary(),
            const SizedBox(height: 20),
            _buildStreakCards(),
            const SizedBox(height: 20),
            _buildCalendarSection(),
            const SizedBox(height: 20),
            if (_records.isNotEmpty) _buildTimeOfDaySection(),
            if (_records.isNotEmpty) const SizedBox(height: 20),
            _buildRecentLog(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // ① STATS SUMMARY
  // ─────────────────────────────────────
  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.15),
            AppColors.turquoise.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR STATS',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.neonLime,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'This Week',
                '$_thisWeekCount',
                Icons.calendar_view_week_rounded,
              ),
              _buildDivider(),
              _buildStatItem(
                'This Month',
                '$_thisMonthCount',
                Icons.calendar_month_rounded,
              ),
              _buildDivider(),
              _buildStatItem(
                'All Time',
                '${_records.length}',
                Icons.emoji_events_rounded,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neonLime, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: AppColors.neonLime),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
        ),
      ],
    );
  }

  Widget _buildDivider() => Container(
    width: 1,
    height: 40,
    color: AppColors.gray400.withValues(alpha: 0.3),
  );

  // ─────────────────────────────────────
  // ② STREAK CARDS
  // ─────────────────────────────────────
  Widget _buildStreakCards() {
    final currentStreak = _gam?.currentStreak ?? 0;
    final longestStreak = _gam?.longestStreak ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(
            value: currentStreak,
            label: 'Current Streak',
            sublabel: currentStreak > 0 ? 'Keep going! ' : 'Start today!',
            color: currentStreak > 0 ? AppColors.neonOrange : AppColors.gray400,
            pulsing: currentStreak > 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStreakCard(
            value: longestStreak,
            label: 'Best Streak',
            sublabel: 'Personal record',
            color: Colors.amber,
            pulsing: false,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard({
    required int value,
    required String label,
    required String sublabel,
    required Color color,
    required bool pulsing,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department_rounded, color: color, size: 28)
              .animate(onPlay: pulsing ? (c) => c.repeat(reverse: true) : null)
              .scale(
                begin: const Offset(1.0, 1.0),
                end: pulsing ? const Offset(1.2, 1.2) : const Offset(1.0, 1.0),
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'days',
            style: AppTextStyles.caption.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 6),
          // Milestone dots
          _buildMilestoneDots(value, color),
          const SizedBox(height: 6),
          if (value > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sublabel,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMilestoneDots(int streak, Color color) {
    const milestones = [3, 7, 14, 30, 60, 100];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: milestones.map((m) {
        final reached = streak >= m;
        return Tooltip(
          message: '$m days',
          child: Container(
            margin: const EdgeInsets.only(right: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reached ? color : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: reached ? color : Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────
  // ③ CALENDAR HEATMAP
  // ─────────────────────────────────────
  Widget _buildCalendarSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: AppColors.neonLime,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'ATTENDANCE CALENDAR',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonLime,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Month navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _calendarMonth = DateTime(
                    _calendarMonth.year,
                    _calendarMonth.month - 1,
                  );
                }),
                icon: Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.gray400,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_calendarMonth),
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed:
                    _calendarMonth.year == DateTime.now().year &&
                        _calendarMonth.month == DateTime.now().month
                    ? null
                    : () => setState(() {
                        _calendarMonth = DateTime(
                          _calendarMonth.year,
                          _calendarMonth.month + 1,
                        );
                      }),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color:
                      _calendarMonth.year == DateTime.now().year &&
                          _calendarMonth.month == DateTime.now().month
                      ? AppColors.gray600
                      : AppColors.gray400,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weekday headers — Mon first
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          _buildCalendarGrid(),
          const SizedBox(height: 12),

          // Month visit count
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.neonLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonLime.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                '${_calendarMonthRecords.length} visits in '
                '${DateFormat('MMMM').format(_calendarMonth)}',
                style: TextStyle(
                  color: AppColors.neonLime,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(AppColors.backgroundBlack, Colors.white12, 'No visit'),
              const SizedBox(width: 16),
              _legendDot(
                AppColors.neonLime.withValues(alpha: 0.25),
                AppColors.neonLime.withValues(alpha: 0.6),
                'Visited',
              ),
              const SizedBox(width: 16),
              _legendDot(
                Colors.amber.withValues(alpha: 0.2),
                Colors.amber,
                'Today',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(_calendarMonth.year, _calendarMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _calendarMonth.year,
      _calendarMonth.month,
    );
    final startOffset = (firstDay.weekday - 1) % 7;
    final rows = ((startOffset + daysInMonth) / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: List.generate(7, (col) {
              final dayNum = row * 7 + col - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox());
              }
              final day = DateTime(
                _calendarMonth.year,
                _calendarMonth.month,
                dayNum,
              );
              final isToday = DateUtils.isSameDay(day, today);
              final checked = _isCheckedIn(day);
              final isFuture = day.isAfter(today);

              return Expanded(
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isToday
                          ? Colors.amber.withValues(alpha: 0.2)
                          : checked
                          ? AppColors.neonLime.withValues(alpha: 0.25)
                          : AppColors.backgroundBlack,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isToday
                            ? Colors.amber
                            : checked
                            ? AppColors.neonLime.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.05),
                        width: isToday || checked ? 1.5 : 1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            color: isFuture
                                ? AppColors.gray600
                                : isToday
                                ? Colors.amber
                                : checked
                                ? AppColors.neonLime
                                : AppColors.gray400,
                            fontWeight: checked || isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                        if (checked)
                          Positioned(
                            bottom: 3,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.neonLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _legendDot(Color bg, Color border, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: border, width: 1.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────
  // ④ TIME OF DAY BREAKDOWN
  // ─────────────────────────────────────
  Widget _buildTimeOfDaySection() {
    final breakdown = _timeOfDayBreakdown;
    final filtered = breakdown.entries.where((e) => e.value > 0).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    final maxCount = breakdown.values.reduce((a, b) => a > b ? a : b);
    final timeColors = {
      'Early Bird': Colors.purpleAccent,
      'Morning': Colors.amber,
      'Afternoon': AppColors.neonOrange,
      'Evening': AppColors.neonTeal,
      'Night Owl': Colors.blueAccent,
    };
    final timeIcons = {
      'Early Bird': Icons.wb_twilight_rounded,
      'Morning': Icons.wb_sunny_rounded,
      'Afternoon': Icons.light_mode_rounded,
      'Evening': Icons.wb_cloudy_rounded,
      'Night Owl': Icons.nightlight_round,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppColors.neonOrange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'VISIT TIME BREAKDOWN',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonOrange,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...filtered.map((entry) {
            final color = timeColors[entry.key] ?? AppColors.gray400;
            final icon = timeIcons[entry.key] ?? Icons.access_time_rounded;
            final pct = (entry.value / _records.length * 100).toInt();
            final barFraction = maxCount > 0 ? entry.value / maxCount : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: Text(
                      entry.key,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          FractionallySizedBox(
                            widthFactor: barFraction,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color.withValues(alpha: 0.7), color],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${entry.value} ($pct%)',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 250.ms);
  }

  // ─────────────────────────────────────
  // ⑤ RECENT LOG
  // ─────────────────────────────────────
  Widget _buildRecentLog() {
    if (_filtered.isEmpty) return _buildNoDataForFilter();

    // Group by date
    final grouped = <String, List<AttendanceModel>>{};
    for (final r in _filtered) {
      final key = DateFormat('yyyy-MM-dd').format(r.checkInTime);
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, color: AppColors.neonTeal, size: 16),
            const SizedBox(width: 8),
            Text(
              'VISIT LOG',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.neonTeal,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${_filtered.length} total',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gray600,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sortedKeys.map((dateKey) {
          final records = grouped[dateKey]!;
          final date = DateTime.parse(dateKey);
          return _buildDateGroup(date, records);
        }),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDateGroup(DateTime date, List<AttendanceModel> records) {
    final today = DateTime.now();
    final isToday = DateUtils.isSameDay(date, today);
    final isYesterday = DateUtils.isSameDay(
      date,
      today.subtract(const Duration(days: 1)),
    );

    final label = isToday
        ? 'Today'
        : isYesterday
        ? 'Yesterday'
        : DateFormat('EEEE, MMM dd, yyyy').format(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isToday ? AppColors.neonLime : AppColors.gray400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...records.asMap().entries.map(
          (entry) => _buildAttendanceCard(entry.value, entry.key, isToday),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceModel record, int index, bool isToday) {
    final h = record.checkInTime.hour;
    final timeSlot = h < 7
        ? 'Early Bird'
        : h < 12
        ? 'Morning'
        : h < 17
        ? 'Afternoon'
        : h < 20
        ? 'Evening'
        : 'Night Owl';
    final timeColor = _getTimeColor(timeSlot);
    final timeIcon = _getTimeIcon(timeSlot);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? AppColors.neonLime.withValues(alpha: 0.3)
              : AppColors.neonLime.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Time-of-day icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.neonLime.withValues(alpha: 0.15),
                  timeColor.withValues(alpha: 0.15),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(timeIcon, color: timeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Check-in',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonLime.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            color: AppColors.neonLime,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('hh:mm a').format(record.checkInTime),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_rounded,
                      size: 12,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.branch,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                    // ✅ Duration if checked out
                    if (record.isCheckedOut) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer_rounded,
                        size: 12,
                        color: AppColors.neonTeal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.formattedDuration,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neonTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Done',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0);
  }

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────
  Widget _buildLoading() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: AppColors.neonLime),
        const SizedBox(height: 16),
        Text(
          'Loading your attendance...',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: AppTextStyles.heading3.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _load,
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

  Widget _buildNoDataForFilter() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.filter_list_off_rounded, size: 60, color: AppColors.gray400),
        const SizedBox(height: 16),
        Text('No records found', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text(
          'Try a different filter',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
        TextButton(
          onPressed: () => setState(() => _selectedFilter = 'all'),
          child: Text('SHOW ALL', style: TextStyle(color: AppColors.neonLime)),
        ),
      ],
    ),
  );

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────
  Color _getTimeColor(String slot) {
    switch (slot) {
      case 'Early Bird':
        return Colors.purpleAccent;
      case 'Morning':
        return Colors.amber;
      case 'Afternoon':
        return AppColors.neonOrange;
      case 'Evening':
        return AppColors.neonTeal;
      case 'Night Owl':
        return Colors.blueAccent;
      default:
        return AppColors.gray400;
    }
  }

  IconData _getTimeIcon(String slot) {
    switch (slot) {
      case 'Early Bird':
        return Icons.wb_twilight_rounded;
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.light_mode_rounded;
      case 'Evening':
        return Icons.wb_cloudy_rounded;
      case 'Night Owl':
        return Icons.nightlight_round;
      default:
        return Icons.access_time_rounded;
    }
  }
}
