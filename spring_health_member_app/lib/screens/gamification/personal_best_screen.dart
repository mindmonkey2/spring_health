import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../models/personal_best_model.dart';
import '../../services/personal_best_service.dart';

/// Solo Leveling rank thresholds and metadata
class _Rank {
  final String name;
  final Color color;
  final int minXp;
  const _Rank(this.name, this.color, this.minXp);
}

const _ranks = [
  _Rank('E',   Color(0xFF9E9E9E), 0),
  _Rank('D',   Color(0xFF66BB6A), 500),
  _Rank('C',   Color(0xFF29B6F6), 1500),
  _Rank('B',   Color(0xFFAB47BC), 3500),
  _Rank('A',   Color(0xFFFFCA28), 7000),
  _Rank('S',   Color(0xFFFF7043), 13000),
  _Rank('SS',  Color(0xFFFF1744), 25000),
  _Rank('SSS', Color(0xFFD500F9), 50000),
];

_Rank _rankForXp(int xp) {
  _Rank result = _ranks.first;
  for (final r in _ranks) {
    if (xp >= r.minXp) result = r;
  }
  return result;
}

_Rank _nextRank(int xp) {
  for (int i = 0; i < _ranks.length - 1; i++) {
    if (xp < _ranks[i + 1].minXp) return _ranks[i + 1];
  }
  return _ranks.last;
}

class PersonalBestScreen extends StatefulWidget {
  const PersonalBestScreen({super.key});

  @override
  State<PersonalBestScreen> createState() => _PersonalBestScreenState();
}

class _PersonalBestScreenState extends State<PersonalBestScreen>
    with SingleTickerProviderStateMixin {
  final _service = PersonalBestService();
  late final TabController _tabController;

  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // Total XP from personal bests (summed from all records)
  int _totalPBXp = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: StreamBuilder<List<PersonalBestRecord>>(
        stream: _service.watchRecords(_uid),
        builder: (context, snapshot) {
          final records = snapshot.data ?? [];
          _totalPBXp = records.fold(0, (sum, r) => sum + r.totalXpEarned);
          final rank = _rankForXp(_totalPBXp);
          final next = _nextRank(_totalPBXp);
          final progressToNext = next.minXp > rank.minXp
              ? (_totalPBXp - rank.minXp) / (next.minXp - rank.minXp)
              : 1.0;

          return NestedScrollView(
            headerSliverBuilder: (_, _) => [
              _buildSliverHeader(rank, next, progressToNext),
            ],
            body: Column(
              children: [
                // Tab bar
                Container(
                  color: AppColors.surfaceDark,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: rank.color,
                    labelColor: rank.color,
                    unselectedLabelColor: AppColors.gray400,
                    tabs: const [
                      Tab(text: 'Core Exercises'),
                      Tab(text: 'Progress'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ExerciseListTab(
                        records: records,
                        uid: _uid,
                        service: _service,
                        rankColor: rank.color,
                        onXpEarned: (xp) {
                          setState(() => _totalPBXp += xp);
                        },
                      ),
                      _ProgressTab(records: records, rankColor: rank.color),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverHeader(_Rank rank, _Rank next, double progress) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surfaceDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rank.color.withValues(alpha: 0.3),
                AppColors.backgroundBlack,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      // Rank badge
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: rank.color.withValues(alpha: 0.15),
                          border: Border.all(color: rank.color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: rank.color.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            rank.name,
                            style: TextStyle(
                              color: rank.color,
                              fontWeight: FontWeight.w900,
                              fontSize: rank.name.length > 1 ? 16 : 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rank ${rank.name}',
                              style: TextStyle(
                                color: rank.color,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_totalPBXp XP from Personal Bests',
                              style: TextStyle(
                                color: AppColors.gray400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Rank progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceDark,
                      valueColor: AlwaysStoppedAnimation<Color>(rank.color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rank.name == next.name
                        ? 'Max Rank Achieved!'
                        : 'Next: ${next.name} Rank at ${next.minXp} XP',
                    style: TextStyle(
                      color: AppColors.gray400,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      title: const Text(
        'Personal Bests',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Tab 1: Exercise List ────────────────────────────────────────────────────

class _ExerciseListTab extends StatelessWidget {
  final List<PersonalBestRecord> records;
  final String uid;
  final PersonalBestService service;
  final Color rankColor;
  final void Function(int xp) onXpEarned;

  const _ExerciseListTab({
    required this.records,
    required this.uid,
    required this.service,
    required this.rankColor,
    required this.onXpEarned,
  });

  // Checks whether all 6 exercises have been logged today
  bool get _checklistComplete {
    return CoreExercise.values.every((e) {
      final rec = records.firstWhere(
        (r) => r.exerciseKey == e.key,
        orElse: () => const PersonalBestRecord(
          exerciseKey: '',
          currentBest: 0,
          history: [],
          totalXpEarned: 0,
        ),
      );
      return rec.loggedToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Daily Checklist Banner
        _ChecklistBanner(
          isComplete: _checklistComplete,
          completedCount: CoreExercise.values
              .where((e) => records
                  .any((r) => r.exerciseKey == e.key && r.loggedToday))
              .length,
          accentColor: rankColor,
        ),
        const SizedBox(height: 16),
        // Exercise cards
        ...CoreExercise.values.map((exercise) {
          final record = records.firstWhere(
            (r) => r.exerciseKey == exercise.key,
            orElse: () => const PersonalBestRecord(
              exerciseKey: '',
              currentBest: 0,
              history: [],
              totalXpEarned: 0,
            ),
          );
          return _ExerciseCard(
            exercise: exercise,
            record: record.exerciseKey.isNotEmpty ? record : null,
            uid: uid,
            service: service,
            onXpEarned: onXpEarned,
          );
        }),
      ],
    );
  }
}

class _ChecklistBanner extends StatelessWidget {
  final bool isComplete;
  final int completedCount;
  final Color accentColor;

  const _ChecklistBanner({
    required this.isComplete,
    required this.completedCount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = CoreExercise.values.length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isComplete
              ? [const Color(0xFFFFD700).withValues(alpha: 0.2), const Color(0xFFFF8C00).withValues(alpha: 0.1)]
              : [accentColor.withValues(alpha: 0.15), accentColor.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? const Color(0xFFFFD700) : accentColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Text(
            isComplete ? '🏆' : '🎯',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete ? 'Daily Checklist Complete!' : 'Daily Checklist',
                  style: TextStyle(
                    color: isComplete ? const Color(0xFFFFD700) : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  isComplete
                      ? '+${PersonalBestXP.dailyChecklist} Bonus XP Earned!'
                      : '$completedCount / $total exercises logged today',
                  style: TextStyle(
                    color: AppColors.gray400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!isComplete)
            Text(
              '+${PersonalBestXP.dailyChecklist} XP',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final CoreExercise exercise;
  final PersonalBestRecord? record;
  final String uid;
  final PersonalBestService service;
  final void Function(int xp) onXpEarned;

  const _ExerciseCard({
    required this.exercise,
    required this.record,
    required this.uid,
    required this.service,
    required this.onXpEarned,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _isLogging = false;

  void _showLogDialog() {
    final controller = TextEditingController();
    final currentBest = widget.record?.currentBest ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(widget.exercise.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              widget.exercise.displayName,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentBest > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Current Best: $currentBest ${widget.exercise.unitShort}',
                  style: TextStyle(color: AppColors.gray400, fontSize: 13),
                ),
              ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter ${widget.exercise.unit}...',
                hintStyle: TextStyle(color: AppColors.gray400),
                suffixText: widget.exercise.unitShort,
                suffixStyle: TextStyle(color: AppColors.gray400),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.gray400.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.neonLime),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beat your best → +${PersonalBestXP.beatPersonalBest} XP\n'
              'Match your best → +${PersonalBestXP.matchPersonalBest} XP\n'
              'Any entry       → +${PersonalBestXP.loggedEntry} XP',
              style: TextStyle(color: AppColors.gray400, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.gray400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonLime,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final val = int.tryParse(controller.text.trim());
              if (val == null || val <= 0) return;
              Navigator.pop(ctx);
              setState(() => _isLogging = true);
              try {
                final xp = await widget.service.logEntry(
                  uid: widget.uid,
                  exercise: widget.exercise,
                  value: val,
                );
                widget.onXpEarned(xp);
                if (mounted) _showXpToast(xp, val > (widget.record?.currentBest ?? 0));
              } finally {
                if (mounted) setState(() => _isLogging = false);
              }
            },
            child: const Text('Log It'),
          ),
        ],
      ),
    );
  }

  void _showXpToast(int xp, bool isPB) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isPB ? const Color(0xFFFFD700) : AppColors.neonLime,
        content: Row(
          children: [
            Text(isPB ? '🏆 NEW PERSONAL BEST! ' : '✅ Logged! ',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            Text('+$xp XP', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final loggedToday = record?.loggedToday ?? false;
    final currentBest = record?.currentBest ?? 0;
    final lastEntry = record?.history.isNotEmpty == true ? record!.history.last : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: loggedToday
              ? AppColors.neonLime.withValues(alpha: 0.5)
              : AppColors.surfaceDark,
          width: 1.5,
        ),
        boxShadow: loggedToday
            ? [BoxShadow(color: AppColors.neonLime.withValues(alpha: 0.15), blurRadius: 8)]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neonLime.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Text(widget.exercise.emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          widget.exercise.displayName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: currentBest > 0
            ? Text(
                'Best: $currentBest ${widget.exercise.unitShort}'
                '${lastEntry != null ? "  •  Last: ${lastEntry.value} ${widget.exercise.unitShort}" : ""}',
                style: TextStyle(color: AppColors.gray400, fontSize: 12),
              )
            : Text(
                'No entries yet — log your first!',
                style: TextStyle(color: AppColors.gray400, fontSize: 12),
              ),
        trailing: _isLogging
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.neonLime,
                ),
              )
            : loggedToday
                ? Icon(Icons.check_circle_rounded, color: AppColors.neonLime, size: 28)
                : ElevatedButton(
                    onPressed: _showLogDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonLime,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(64, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Log', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
      ),
    );
  }
}

// ─── Tab 2: Progress Charts ──────────────────────────────────────────────────

class _ProgressTab extends StatefulWidget {
  final List<PersonalBestRecord> records;
  final Color rankColor;

  const _ProgressTab({required this.records, required this.rankColor});

  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab> {
  CoreExercise _selected = CoreExercise.pushUps;

  @override
  Widget build(BuildContext context) {
    final record = widget.records.firstWhere(
      (r) => r.exerciseKey == _selected.key,
      orElse: () => const PersonalBestRecord(
        exerciseKey: '',
        currentBest: 0,
        history: [],
        totalXpEarned: 0,
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Exercise picker
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: CoreExercise.values.map((e) {
              final selected = e == _selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${e.emoji} ${e.displayName}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = e),
                  selectedColor: widget.rankColor.withValues(alpha: 0.25),
                  backgroundColor: AppColors.cardSurface,
                  labelStyle: TextStyle(
                    color: selected ? widget.rankColor : AppColors.gray400,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: selected ? widget.rankColor : Colors.transparent,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Stats row
        if (record.exerciseKey.isNotEmpty)
          Row(
            children: [
              _StatChip(label: 'Best', value: '${record.currentBest} ${_selected.unitShort}', color: widget.rankColor),
              const SizedBox(width: 10),
              _StatChip(label: 'Entries', value: '${record.history.length}', color: AppColors.neonLime),
              const SizedBox(width: 10),
              _StatChip(label: 'XP', value: '${record.totalXpEarned}', color: const Color(0xFFFFD700)),
            ],
          ),

        const SizedBox(height: 20),

        // Chart
        if (record.history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Text(_selected.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No entries yet for ${_selected.displayName}.\nLog your first rep to see progress!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray400),
                  ),
                ],
              ),
            ),
          )
        else
          _ProgressChart(
            entries: record.history,
            color: widget.rankColor,
            unit: _selected.unitShort,
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: TextStyle(color: AppColors.gray400, fontSize: 11)),
        ],
      ),
    );
  }
}

/// Custom painter-based line chart — no external chart dependency needed
class _ProgressChart extends StatelessWidget {
  final List<PersonalBestEntry> entries;
  final Color color;
  final String unit;

  const _ProgressChart({
    required this.entries,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    // Show last 14 entries max
    final data = entries.length > 14 ? entries.sublist(entries.length - 14) : entries;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _ChartPainter(entries: data, color: color),
        child: Align(
          alignment: Alignment.topRight,
          child: Text(
            unit,
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<PersonalBestEntry> entries;
  final Color color;

  const _ChartPainter({required this.entries, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final maxVal = entries.map((e) => e.value).reduce(max).toDouble();
    final minVal = entries.map((e) => e.value).reduce(min).toDouble();
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    final xStep = size.width / (entries.length - 1);

    // Grid lines
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Line path
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Fill path
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < entries.length; i++) {
      final x = xStep * i;
      final y = size.height - ((entries[i].value - minVal) / range) * size.height * 0.85 - 10;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(xStep * (entries.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // PB dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < entries.length; i++) {
      final x = xStep * i;
      final y = size.height - ((entries[i].value - minVal) / range) * size.height * 0.85 - 10;
      dotPaint.color = entries[i].isPersonalBest
          ? const Color(0xFFFFD700)
          : color.withValues(alpha: 0.7);
      canvas.drawCircle(Offset(x, y), entries[i].isPersonalBest ? 6 : 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.entries != entries || old.color != color;
}
