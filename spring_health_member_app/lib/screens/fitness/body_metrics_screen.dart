import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/body_metrics_model.dart';
import '../../models/health_profile_model.dart';
import '../../services/body_metrics_service.dart';

// ════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ════════════════════════════════════════════════════════════════

class BodyMetricsScreen extends StatefulWidget {
  final String memberId;
  // nullable — screen still works without it; banner not shown if null
  final HealthProfileModel? healthProfile;

  const BodyMetricsScreen({
    super.key,
    required this.memberId,
    this.healthProfile, // optional — callers pass it if they have it
  });

  @override
  State<BodyMetricsScreen> createState() => _BodyMetricsScreenState();
}

class _BodyMetricsScreenState extends State<BodyMetricsScreen>
    with SingleTickerProviderStateMixin {
  final _service = BodyMetricsService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openSheet(List<BodyMetricsModel> existing) {
    final lastHeight = existing.isNotEmpty
        ? existing.first.height
        : widget.healthProfile?.heightCm;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMetricsBottomSheet(
        memberId: widget.memberId,
        service: _service,
        lastHeight: lastHeight,
      ),
    );
  }

  // ─── BP critical check ──────────────────────────────────────────────
  // Stage 2 HTN threshold: systolic ≥140 OR diastolic ≥90
  bool _isBPCritical(HealthProfileModel h) {
    return (h.bpSystolic != null && h.bpSystolic! >= 140) ||
        (h.bpDiastolic != null && h.bpDiastolic! >= 90);
  }

  // ─── Non-dismissible BP warning banner ──────────────────────────────
  Widget _buildBPWarningBanner() {
    return Container(
      width: double.infinity,
      color: AppColors.error,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              ' Your blood pressure reading is elevated. '
              'Please consult a doctor before intense exercise.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // No X button — non-dismissible per Phase 1 AI rules
        ],
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  // BUG 1 FIX: single StreamBuilder lifted to top level so body AND FAB share
  // one Firestore listener instead of two separate identical subscriptions.

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BodyMetricsModel>>(
      stream: _service.getMetricsStream(widget.memberId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.backgroundBlack,
            appBar: _buildAppBar(),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundBlack,
            appBar: _buildAppBar(),
            body: _buildError(snapshot.error.toString()),
          );
        }

        final metrics = snapshot.data ?? [];

        // BUG 1 FIX: FAB uses `metrics` from the outer StreamBuilder — no inner
        // StreamBuilder needed. One listener, zero duplication.
        return Scaffold(
          backgroundColor: AppColors.backgroundBlack,
          appBar: _buildAppBar(),
          body: metrics.isEmpty ? _buildEmpty() : _buildContent(metrics),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openSheet(metrics), // shared data ✅
            backgroundColor: AppColors.neonLime,
            foregroundColor: Colors.black,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'LOG METRICS',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ).animate().scale(delay: 400.ms),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.backgroundBlack,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.neonLime,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'BODY METRICS',
        style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
      ),
    );
  }

  Widget _buildContent(List<BodyMetricsModel> metrics) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BP warning banner at top — non-dismissible, shown when
          // healthProfile is passed and BP is Stage 2 or Crisis
          if (widget.healthProfile != null &&
              _isBPCritical(widget.healthProfile!))
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBPWarningBanner(),
            ),

          _buildCurrentStats(
            metrics.first,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          _buildChart(metrics)
              .animate()
              .fadeIn(delay: 100.ms, duration: 600.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          Text(
            'HISTORY',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              letterSpacing: 2,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          ...metrics.asMap().entries.map(
            (e) => _buildCard(e.value, e.key, metrics)
                .animate()
                .fadeIn(delay: (300 + e.key * 60).ms)
                .slideX(begin: 0.1, end: 0),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // ─── Current Stats Card ────────────────────────────────────────────────────

  Widget _buildCurrentStats(BodyMetricsModel m) {
    return Container(
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
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT STATS',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonLime,
                  letterSpacing: 2,
                ),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(m.recordedAt),
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statChip(
                'WEIGHT',
                m.weight.toStringAsFixed(1),
                'kg',
                AppColors.neonLime,
                Icons.monitor_weight_rounded,
              ),
              _divider(),
              _statChip(
                'BMI',
                m.bmi != null ? m.bmi!.toStringAsFixed(1) : '—',
                m.bmiCategory,
                _bmiColor(m.bmi),
                Icons.analytics_rounded,
              ),
              _divider(),
              _statChip(
                'BODY FAT',
                m.bodyFat != null ? m.bodyFat!.toStringAsFixed(1) : '—',
                m.bodyFat != null ? '%' : 'Not logged',
                AppColors.neonOrange,
                Icons.person_rounded,
              ),
            ],
          ),
          if (m.waist != null || m.chest != null || m.hips != null)
            _measurementsRow(m),
        ],
      ),
    );
  }

  Widget _statChip(
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: color, fontSize: 22),
        ),
        Text(
          unit,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontSize: 9,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 50,
    color: AppColors.gray400.withValues(alpha: 0.3),
  );

  Widget _measurementsRow(BodyMetricsModel m) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Divider(color: AppColors.gray400.withValues(alpha: 0.15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (m.chest != null) _miniMeasurement('Chest', m.chest!),
            if (m.waist != null) _miniMeasurement('Waist', m.waist!),
            if (m.hips != null) _miniMeasurement('Hips', m.hips!),
            if (m.arms != null) _miniMeasurement('Arms', m.arms!),
            if (m.thighs != null) _miniMeasurement('Thighs', m.thighs!),
          ],
        ),
      ],
    );
  }

  Widget _miniMeasurement(String label, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.neonTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(1)} cm',
        style: TextStyle(
          color: AppColors.neonTeal,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─── Progress Chart ────────────────────────────────────────────────────────

  Widget _buildChart(List<BodyMetricsModel> metrics) {
    final chrono = metrics.reversed.toList(); // oldest → newest
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PROGRESS CHART',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray400,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Last ${chrono.length} entries',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.neonLime.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.neonLime),
              ),
              labelColor: AppColors.neonLime,
              unselectedLabelColor: AppColors.gray400,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
              tabs: const [
                Tab(text: 'WEIGHT'),
                Tab(text: 'BMI'),
                Tab(text: 'BODY FAT'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: TabBarView(
              controller: _tabController,
              children: [
                _lineChart(
                  points: chrono.map((m) => m.weight).toList(),
                  labels: chrono
                      .map((m) => DateFormat('dd/MM').format(m.recordedAt))
                      .toList(),
                  color: AppColors.neonLime,
                  unit: 'kg',
                ),
                chrono.any((m) => m.bmi != null)
                    ? _lineChart(
                        points: chrono
                            .where((m) => m.bmi != null)
                            .map((m) => m.bmi!)
                            .toList(),
                        labels: chrono
                            .where((m) => m.bmi != null)
                            .map(
                              (m) => DateFormat('dd/MM').format(m.recordedAt),
                            )
                            .toList(),
                        color: _bmiColor(chrono.last.bmi),
                        unit: 'BMI',
                      )
                    : _noData('Log height to calculate BMI'),
                chrono.any((m) => m.bodyFat != null)
                    ? _lineChart(
                        points: chrono
                            .where((m) => m.bodyFat != null)
                            .map((m) => m.bodyFat!)
                            .toList(),
                        labels: chrono
                            .where((m) => m.bodyFat != null)
                            .map(
                              (m) => DateFormat('dd/MM').format(m.recordedAt),
                            )
                            .toList(),
                        color: AppColors.neonOrange,
                        unit: '%',
                      )
                    : _noData('Log body fat % to see trend'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineChart({
    required List<double> points,
    required List<String> labels,
    required Color color,
    required String unit,
  }) {
    if (points.length < 2) {
      return _noData('Log more entries to see trend');
    }

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();
    final minY = (points.reduce((a, b) => a < b ? a : b) - 2);
    final maxY = (points.reduce((a, b) => a > b ? a : b) + 2);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (v, _) => Text(
                v.toStringAsFixed(1),
                style: TextStyle(color: AppColors.gray400, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: points.length > 6
                  ? (points.length / 4).ceilToDouble()
                  : 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    labels[i],
                    style: TextStyle(color: AppColors.gray400, fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, p1, p2, p3) => FlDotCirclePainter(
                radius: 4,
                color: color,
                strokeWidth: 2,
                strokeColor: AppColors.backgroundBlack,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.25),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                    '${s.y.toStringAsFixed(1)} $unit',
                    TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _noData(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.show_chart_rounded, color: AppColors.gray400, size: 36),
        const SizedBox(height: 8),
        Text(
          msg,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  // ─── History Card ──────────────────────────────────────────────────────────

  Widget _buildCard(BodyMetricsModel m, int idx, List<BodyMetricsModel> all) {
    final double? change = idx < all.length - 1
        ? m.weight - all[idx + 1].weight
        : null;

    return Dismissible(
      key: Key(m.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_rounded, color: AppColors.error),
      ),
      confirmDismiss: (_) async => await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          title: Text('Delete Entry', style: AppTextStyles.heading3),
          content: Text(
            'Remove this metrics entry?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('CANCEL', style: TextStyle(color: AppColors.gray400)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
            ),
          ],
        ),
      ),
      onDismissed: (_) async {
        await _service.deleteMetrics(m.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry deleted'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: idx == 0
                ? AppColors.neonLime.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: AppColors.gray400,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('EEE, dd MMM yyyy').format(m.recordedAt),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (idx == 0)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neonLime),
                    ),
                    child: Text(
                      'LATEST',
                      style: TextStyle(
                        color: AppColors.neonLime,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                if (idx > 0)
                  const Icon(
                    Icons.swipe_left_rounded,
                    size: 13,
                    color: AppColors.gray400,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _cardStat(
                    'Weight',
                    '${m.weight.toStringAsFixed(1)} kg',
                    AppColors.neonLime,
                    weightChange: change,
                  ),
                ),
                Expanded(
                  child: _cardStat(
                    'BMI',
                    m.bmi != null
                        ? '${m.bmi!.toStringAsFixed(1)} (${m.bmiCategory})'
                        : '— (no height)',
                    _bmiColor(m.bmi),
                  ),
                ),
                Expanded(
                  child: _cardStat(
                    'Body Fat',
                    m.bodyFat != null
                        ? '${m.bodyFat!.toStringAsFixed(1)}%'
                        : '—',
                    AppColors.neonOrange,
                  ),
                ),
              ],
            ),
            if (m.chest != null ||
                m.waist != null ||
                m.hips != null ||
                m.arms != null ||
                m.thighs != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (m.chest != null) _chip('Chest', m.chest!),
                    if (m.waist != null) _chip('Waist', m.waist!),
                    if (m.hips != null) _chip('Hips', m.hips!),
                    if (m.arms != null) _chip('Arms', m.arms!),
                    if (m.thighs != null) _chip('Thighs', m.thighs!),
                  ],
                ),
              ),
            if (m.notes != null && m.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      size: 13,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        m.notes!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardStat(
    String label,
    String value,
    Color color, {
    double? weightChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        if (weightChange != null)
          Row(
            children: [
              Icon(
                weightChange > 0
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 11,
                color: weightChange > 0 ? AppColors.error : AppColors.success,
              ),
              Text(
                '${weightChange.abs().toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: weightChange > 0 ? AppColors.error : AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _chip(String label, double value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.neonTeal.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.3)),
    ),
    child: Text(
      '$label: ${value.toStringAsFixed(1)} cm',
      style: TextStyle(
        color: AppColors.neonTeal,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  // ─── Empty / Error ─────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Column(
      children: [
        if (widget.healthProfile != null &&
            _isBPCritical(widget.healthProfile!))
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildBPWarningBanner(),
          ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonLime.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.monitor_weight_outlined,
                    size: 56,
                    color: AppColors.neonLime.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text('No Metrics Yet', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text(
                  'Start tracking to see your progress over time',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // BUG 2: already correct — passes [] as expected by _openSheet()
                ElevatedButton.icon(
                  onPressed: () => _openSheet([]),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'LOG FIRST ENTRY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().scale(),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String e) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 64,
          color: AppColors.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Something went wrong',
          style: AppTextStyles.heading3.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: 8),
        Text(
          e,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Color _bmiColor(double? bmi) {
    if (bmi == null) return AppColors.gray400;
    if (bmi < 18.5) return Colors.blueAccent;
    if (bmi < 25.0) return AppColors.success;
    if (bmi < 30.0) return AppColors.neonOrange;
    return AppColors.error;
  }
}

// ════════════════════════════════════════════════════════════════
// ADD METRICS BOTTOM SHEET
// ════════════════════════════════════════════════════════════════

class AddMetricsBottomSheet extends StatefulWidget {
  final String memberId;
  final BodyMetricsService service;
  final double? lastHeight;

  const AddMetricsBottomSheet({
    super.key,
    required this.memberId,
    required this.service,
    this.lastHeight,
  });

  @override
  State<AddMetricsBottomSheet> createState() => _AddMetricsBottomSheetState();
}

class _AddMetricsBottomSheetState extends State<AddMetricsBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _showMeasurements = false;
  DateTime _date = DateTime.now();

  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _thighsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.lastHeight != null) {
      _heightCtrl.text = widget.lastHeight!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _weightCtrl,
      _heightCtrl,
      _bodyFatCtrl,
      _chestCtrl,
      _waistCtrl,
      _hipsCtrl,
      _armsCtrl,
      _thighsCtrl,
      _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parse(String s) =>
      s.trim().isEmpty ? null : double.tryParse(s.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.service.addMetrics(
        BodyMetricsModel(
          id: '',
          memberId: widget.memberId,
          weight: double.parse(_weightCtrl.text.trim()),
          height: _parse(_heightCtrl.text),
          bodyFat: _parse(_bodyFatCtrl.text),
          chest: _parse(_chestCtrl.text),
          waist: _parse(_waistCtrl.text),
          hips: _parse(_hipsCtrl.text),
          arms: _parse(_armsCtrl.text),
          thighs: _parse(_thighsCtrl.text),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          recordedAt: _date,
        ),
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Metrics saved! Keep it up '),
            backgroundColor: AppColors.neonLime,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonLime,
            onPrimary: Colors.black,
            surface: AppColors.cardSurface,
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (p != null) setState(() => _date = p);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray400.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LOG METRICS', style: AppTextStyles.heading3),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withValues(alpha: 0.08)),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date picker
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundBlack,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.neonLime.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.neonLime,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('EEE, dd MMM yyyy').format(_date),
                                style: AppTextStyles.bodyMedium,
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppColors.neonLime,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _sectionLabel('MAIN METRICS'),
                      const SizedBox(height: 12),
                      _field(
                        _weightCtrl,
                        'Weight *',
                        'e.g. 70.5',
                        'kg',
                        Icons.monitor_weight_rounded,
                        AppColors.neonLime,
                        required: true,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _heightCtrl,
                        'Height (for BMI)',
                        'e.g. 170.0',
                        'cm',
                        Icons.height_rounded,
                        AppColors.neonTeal,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        _bodyFatCtrl,
                        'Body Fat',
                        'e.g. 18.5',
                        '%',
                        Icons.person_rounded,
                        AppColors.neonOrange,
                      ),
                      const SizedBox(height: 20),

                      // Measurements toggle
                      GestureDetector(
                        onTap: () => setState(
                          () => _showMeasurements = !_showMeasurements,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundBlack,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.neonTeal.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.straighten_rounded,
                                color: AppColors.neonTeal,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Body Measurements (Optional)',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const Spacer(),
                              Icon(
                                _showMeasurements
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: AppColors.neonTeal,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_showMeasurements) ...[
                        const SizedBox(height: 12),
                        _field(
                          _chestCtrl,
                          'Chest',
                          'e.g. 95.0',
                          'cm',
                          Icons.accessibility_new_rounded,
                          AppColors.neonTeal,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _waistCtrl,
                          'Waist',
                          'e.g. 80.0',
                          'cm',
                          Icons.accessibility_new_rounded,
                          AppColors.neonTeal,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _hipsCtrl,
                          'Hips',
                          'e.g. 95.0',
                          'cm',
                          Icons.accessibility_new_rounded,
                          AppColors.neonTeal,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                _armsCtrl,
                                'Arms',
                                'e.g. 35.0',
                                'cm',
                                Icons.fitness_center_rounded,
                                AppColors.neonTeal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _field(
                                _thighsCtrl,
                                'Thighs',
                                'e.g. 55.0',
                                'cm',
                                Icons.fitness_center_rounded,
                                AppColors.neonTeal,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),

                      _sectionLabel('NOTES (OPTIONAL)'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 2,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'e.g. After morning workout, fasted',
                          hintStyle: TextStyle(color: AppColors.gray400),
                          filled: true,
                          fillColor: AppColors.backgroundBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.neonLime.withValues(alpha: 0.4),
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                          prefixIcon: const Icon(
                            Icons.notes_rounded,
                            color: AppColors.gray400,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonLime,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            disabledBackgroundColor: AppColors.neonLime
                                .withValues(alpha: 0.4),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SAVE METRICS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: AppTextStyles.caption.copyWith(
      color: AppColors.gray400,
      letterSpacing: 2,
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    String unit,
    IconData icon,
    Color color, {
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: AppTextStyles.bodyMedium,
      validator: required
          ? (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Weight is required';
              }
              if (double.tryParse(v.trim()) == null) {
                return 'Enter a valid number';
              }
              return null;
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.gray400),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.gray400.withValues(alpha: 0.4)),
        filled: true,
        fillColor: AppColors.backgroundBlack,
        prefixIcon: Icon(icon, color: color, size: 18),
        suffixText: unit,
        suffixStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
