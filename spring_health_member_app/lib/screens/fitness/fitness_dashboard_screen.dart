import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firebase_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/fitness_stats_model.dart';
import 'widgets/fitness_chart_widget.dart';
import '../workout/workout_history_screen.dart';
import '../../services/health_service.dart';
import 'health_permission_screen.dart';
import 'live_session_screen.dart';

class FitnessDashboardScreen extends StatefulWidget {
  final String? memberId;
  const FitnessDashboardScreen({super.key, this.memberId});

  @override
  State<FitnessDashboardScreen> createState() => _FitnessDashboardScreenState();
}

class _FitnessDashboardScreenState extends State<FitnessDashboardScreen> {
  // ── State ──────────────────────────────────────────────────────────────────
  FitnessStats todayStats = FitnessStats.empty();
  List<FitnessStats> weeklyData = FitnessStats.emptyWeek();
  List<WorkoutSession> recentWorkouts = [];

  bool isConnected = false;
  bool isLoading = true;
  bool _hasHealthPermission = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  Stream<QuerySnapshot>? _sessionStream;

  @override
  void initState() {
    super.initState();
    FirebaseAuthService.instance.getCurrentMemberId().then((id) {
      if (mounted) {
        setState(() {
          final authUid = FirebaseAuthService.instance.currentUser?.uid;
          if (authUid != null) {
            _sessionStream = FirebaseFirestore.instance
                .collection('sessions')
                .where('memberAuthUid', isEqualTo: authUid)
                .where('status', whereNotIn: ['complete', 'cancelled'])
                .orderBy('status')
                .orderBy('createdAt', descending: true)
                .limit(1)
                .snapshots();
          }
        });
      }
    });
    _checkAndLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ── Permission check → load ────────────────────────────────────────────────

  Future<void> _checkAndLoad() async {
    setState(() => isLoading = true);

    final status = await HealthService.instance.checkPermissionStatus();
    final hasPerms = status == HealthPermissionStatus.granted;

    if (!mounted) return;
    setState(() {
      _hasHealthPermission = hasPerms;
      isConnected = hasPerms;
    });

    if (hasPerms) {
      await _loadRealData();
    } else {
      _loadEmptyData();
    }
  }

  // ── Real data from HealthKit / Health Connect ──────────────────────────────

  Future<void> _loadRealData() async {
    setState(() => isLoading = true);
    try {
      final today = await HealthService.instance.getTodayStats();
      final weekly = await HealthService.instance.getWeeklyStats();

      // Firestore sync — fires-and-forgets, won't block UI
      if (widget.memberId != null) {
        HealthService.instance
            .saveToFirestore(widget.memberId!, today)
            .ignore();
      }

      if (!mounted) return;
      setState(() {
        todayStats = today;
        weeklyData = weekly;
        recentWorkouts = []; // Loaded from Firestore via WorkoutHistoryScreen
        isConnected = true;
        _hasHealthPermission = true;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('[FitnessDashboard] _loadRealData error: $e');
      if (!mounted) return;
      _loadEmptyData();
    }
  }

  // ── Empty data (not connected / error) ────────────────────────────────────

  void _loadEmptyData() {
    if (!mounted) return;
    setState(() {
      todayStats = FitnessStats.empty();
      weeklyData = FitnessStats.emptyWeek();
      recentWorkouts = [];
      isLoading = false;
    });
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────

  Future<void> _handleRefresh() async {
    setState(() => isLoading = true);

    if (_hasHealthPermission) {
      await _loadRealData();
    } else {
      await _checkAndLoad();
    }

    if (!mounted) return;

    // Only show "Synced!" if we actually got real data
    final didSync = _hasHealthPermission && todayStats.isRealData;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          didSync
              ? (todayStats.steps == 0)
                    ? '0 steps found. Ensure Samsung Health/Google Fit is syncing data to Health Connect.'
                    : 'Check Synced from Health Connect!'
              : _hasHealthPermission
              ? ' Connected but no data yet — check Samsung Health sharing'
              : 'Connect Health Connect to sync your stats.',
        ),
        backgroundColor: didSync
            ? (todayStats.steps == 0
                  ? AppColors.neonOrange
                  : AppColors.neonTeal)
            : AppColors.neonOrange,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: (didSync && todayStats.steps == 0) ? 5 : 3),
      ),
    );
  }

  // ── Connect device dialog ──────────────────────────────────────────────────

  void _showConnectDeviceDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: HealthPermissionScreen(
          onPermissionGranted: () {
            Navigator.pop(context);
            _loadRealData();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Energy Connected to '
                  '${Platform.isIOS ? "Apple Health" : "Health Connect"}! '
                  'Loading your real data…',
                ),
                backgroundColor: AppColors.neonTeal,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getWorkoutIconAsset(String type) {
    final t = type.toLowerCase();
    if (t.contains('upper') || t.contains('power')) {
      return 'assets/icons/dumbbell_3d.png';
    }
    if (t.contains('cardio') || t.contains('run')) {
      return 'assets/icons/running_shoe_3d.png';
    }
    if (t.contains('yoga')) return 'assets/icons/yoga_3d.png';
    if (t.contains('leg')) return 'assets/icons/dumbbell_3d.png';
    return 'assets/icons/fire_3d.png';
  }

  Color _getWorkoutColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('power') || t.contains('strength')) {
      return Colors.purpleAccent;
    }
    if (t.contains('cardio')) return AppColors.neonTeal;
    if (t.contains('yoga')) return Colors.blueAccent;
    if (t.contains('leg')) return AppColors.neonLime;
    return AppColors.neonOrange;
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_sessionStream != null) {
      return StreamBuilder<QuerySnapshot>(
        stream: _sessionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.backgroundBlack,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.neonLime),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            final doc = snapshot.data!.docs.first;
            final status = (doc.data() as Map<String, dynamic>)['status'] as String? ?? '';
            if (status != 'complete' && status != 'cancelled') {
              return LiveSessionScreen(sessionId: doc.id, memberId: widget.memberId ?? '');
            }
          }
          return _buildDashboard(context);
        },
      );
    }
    return _buildDashboard(context);
  }

  Widget _buildDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        title: Text(
          'DASHBOARD',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        backgroundColor: AppColors.backgroundBlack,
        elevation: 0,
        actions: [
          // Real-data source badge
          if (_hasHealthPermission)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonTeal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.neonTeal.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Platform.isIOS
                        ? Icons.favorite_rounded
                        : Icons.monitor_heart_rounded,
                    color: AppColors.neonTeal,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Platform.isIOS ? 'HEALTH' : 'CONNECT',
                    style: const TextStyle(
                      color: AppColors.neonTeal,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

          // Refresh button
          IconButton(
            onPressed: isLoading ? null : _handleRefresh,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonLime,
                    ),
                  )
                : const Icon(Icons.refresh_rounded, color: AppColors.neonLime),
          ),

          // Sync/connect button
          IconButton(
            onPressed: _showConnectDeviceDialog,
            icon: Icon(
              isConnected ? Icons.sync_rounded : Icons.sync_disabled,
              color: isConnected ? AppColors.neonTeal : AppColors.gray400,
            ),
            tooltip: isConnected ? 'Connected' : 'Connect device',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.neonLime,
        backgroundColor: AppColors.cardSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── MY WORKOUTS button ────────────────────────────────
              if (widget.memberId != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            WorkoutHistoryScreen(memberId: widget.memberId!),
                      ),
                    ),
                    icon: const Icon(Icons.fitness_center_rounded),
                    label: const Text(
                      'MY WORKOUTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonLime,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Chart ─────────────────────────────────────────────
              const FitnessChartWidget()
                  .animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 32),

              // ── Today's stats header ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TODAY'S STATS", style: AppTextStyles.heading3),
                  // Live / Empty badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: todayStats.isRealData
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.gray800,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: todayStats.isRealData
                            ? AppColors.success.withValues(alpha: 0.5)
                            : AppColors.gray600.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      todayStats.isRealData ? ' LIVE' : ' NOT SYNCED',
                      style: TextStyle(
                        color: todayStats.isRealData
                            ? AppColors.success
                            : AppColors.gray600,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 16),

              // ── Hero stats card ────────────────────────────────────
              _buildTodayStatsCard().animate().fadeIn(delay: 200.ms).scale(),
              const SizedBox(height: 32),

              // ── Weekly Goals ───────────────────────────────────────
              Text(
                'WEEKLY GOALS',
                style: AppTextStyles.heading3,
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 16),

              _buildGoalRow(
                'Running',
                weeklyData
                    .fold(0.0, (t, s) => t + s.distance)
                    .toStringAsFixed(1),
                'km',
                weeklyData.fold(0.0, (t, s) => t + s.distance) /
                    WeeklyGoal.defaults.runningKm,
                AppColors.neonTeal,
                'assets/icons/running_shoe_3d.png',
                delay: 300,
              ),
              const SizedBox(height: 16),

              _buildGoalRow(
                'Calories',
                weeklyData.fold(0, (t, s) => t + s.calories).toString(),
                'kcal',
                weeklyData.fold(0, (t, s) => t + s.calories) /
                    WeeklyGoal.defaults.caloriesKcal,
                AppColors.neonOrange,
                'assets/icons/fire_3d.png',
                delay: 400,
              ),
              const SizedBox(height: 16),

              _buildGoalRow(
                'Active Time',
                (weeklyData.fold(0, (t, s) => t + s.activeMinutes) / 60)
                    .toStringAsFixed(1),
                'hrs',
                (weeklyData.fold(0, (t, s) => t + s.activeMinutes) / 60) /
                    WeeklyGoal.defaults.activeHours,
                AppColors.neonLime,
                'assets/icons/dumbbell_3d.png',
                delay: 500,
              ),
              const SizedBox(height: 32),

              // ── Recent Workouts ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECENT WORKOUTS', style: AppTextStyles.heading3),
                  TextButton(
                    onPressed: widget.memberId != null
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutHistoryScreen(
                                memberId: widget.memberId!,
                              ),
                            ),
                          )
                        : null,
                    child: Text(
                      'VIEW ALL',
                      style: AppTextStyles.link.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 16),

              // Show empty state if no workouts
              if (recentWorkouts.isEmpty)
                _buildEmptyWorkouts()
              else
                ...recentWorkouts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final workout = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < recentWorkouts.length - 1 ? 12 : 0,
                    ),
                    child: _buildWorkoutItem(
                      workout.type,
                      '${workout.duration} min • ${workout.notes ?? "Workout"}',
                      _getWorkoutColor(workout.type),
                      _getWorkoutIconAsset(workout.type),
                      timeago.format(workout.startTime, locale: 'en_short'),
                      workout.caloriesBurned,
                      delay: 700 + (index * 100),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // ── Connect device CTA (only if NOT connected) ─────────
              if (!isConnected)
                _buildConnectCTA().animate().fadeIn(delay: 900.ms).scale(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Today's Stats Card ─────────────────────────────────────────────────────

  Widget _buildTodayStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonLime.withValues(alpha: 0.2),
            AppColors.neonTeal.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neonLime.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (todayStats.steps == 0 && !todayStats.isRealData)
                        ? '--'
                        : todayStats.steps.toString(),
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 48,
                      color: AppColors.neonLime,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'STEPS',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.gray400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.neonOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todayStats.calories == 0
                          ? '-- cal'
                          : '${todayStats.calories} cal',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildQuickStat(
                Icons.directions_walk_rounded,
                todayStats.distance == 0
                    ? '-- km'
                    : '${todayStats.distance.toStringAsFixed(1)} km',
                AppColors.neonTeal,
              ),
              const SizedBox(width: 20),
              _buildBpmStat(),
              const SizedBox(width: 20),
              _buildQuickStat(
                Icons.timer_rounded,
                todayStats.activeMinutes == 0
                    ? '-- min'
                    : '${todayStats.activeMinutes} min',
                AppColors.neonOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBpmStat() {
    final bpmText = todayStats.heartRate == 0
        ? '-- bpm'
        : '${todayStats.heartRate} bpm';
    final w = Row(
      children: [
        const Icon(Icons.favorite_rounded, size: 16, color: Colors.redAccent),
        const SizedBox(width: 6),
        Text(
          bpmText,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    if (!todayStats.isRealData || todayStats.heartRate == 0) return w;
    try {
      return w
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(
            begin: 1.0,
            end: 1.08,
            duration: 700.ms,
            curve: Curves.easeInOut,
          );
    } catch (e) {
      return w; // Fallback gracefully if animation fails
    }
  }

  Widget _buildQuickStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Empty Workouts ─────────────────────────────────────────────────────────

  Widget _buildEmptyWorkouts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 40,
            color: AppColors.gray600,
          ),
          const SizedBox(height: 12),
          Text(
            'No workouts logged yet',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 6),
          Text(
            'Log your first workout to see it here.',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  // ── Weekly Goal Row ────────────────────────────────────────────────────────

  Widget _buildGoalRow(
    String label,
    String value,
    String unit,
    double progress,
    Color color,
    String iconPath, {
    required int delay,
  }) {
    final clamped = progress.clamp(0.0, 1.0);
    final pct = (clamped * 100).toInt();

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildIconOrAsset(iconPath, color),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: AppTextStyles.heading3.copyWith(color: color),
                        ),
                        TextSpan(
                          text: ' $unit',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$pct%',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              backgroundColor: AppColors.gray800,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }

  // ── Connect device CTA ─────────────────────────────────────────────────────

  Widget _buildConnectCTA() {
    final platformName = Platform.isIOS ? 'Apple Health' : 'Health Connect';
    final platformIcon = Platform.isIOS
        ? Icons.favorite_rounded
        : Icons.monitor_heart_rounded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neonTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(platformIcon, size: 48, color: AppColors.neonTeal),
          const SizedBox(height: 16),
          Text(
            'Connect $platformName',
            style: AppTextStyles.heading3.copyWith(color: AppColors.neonTeal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sync your real steps, calories and heart rate automatically. '
            'Works with Apple Watch, Wear OS, Mi Band & Fitbit.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showConnectDeviceDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonTeal,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(platformIcon, size: 18),
              label: const Text(
                'CONNECT NOW',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Asset / icon helpers ───────────────────────────────────────────────────

  Widget _buildIconOrAsset(String iconPath, Color color) {
    return Image.asset(
      iconPath,
      height: 32,
      width: 32,
      errorBuilder: (context, error, stackTrace) =>
          _getFallbackIcon(iconPath, color),
    ).animate().scale(duration: 1.seconds, curve: Curves.elasticOut);
  }

  Widget _getFallbackIcon(String iconPath, Color color) {
    if (iconPath.contains('calendar')) {
      return Icon(
        Icons.calendar_today_rounded,
        color: color,
        size: 28,
      ); // ← return, not child:
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        size: 20,
        color: color,
      ), // ← Icons.fitness_center_rounded, not icon
    );
  }

  // ── Workout item card ──────────────────────────────────────────────────────

  Widget _buildWorkoutItem(
    String title,
    String subtitle,
    Color color,
    String iconAsset,
    String timeAgoStr,
    int calories, {
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(iconAsset, width: 24, height: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.gray600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeAgoStr.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 12,
                      color: AppColors.neonOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$calories cal',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.gray600),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
