import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/health_service.dart';
import '../../../models/fitness_stats_model.dart';

class StatsOverviewWidget extends StatefulWidget {
  final String memberId;

  const StatsOverviewWidget({super.key, required this.memberId});

  @override
  State<StatsOverviewWidget> createState() => _StatsOverviewWidgetState();
}

class _StatsOverviewWidgetState extends State<StatsOverviewWidget> {
  final _healthService = HealthService();

  FitnessStats _stats = FitnessStats.empty();
  HealthPermissionStatus _permStatus = HealthPermissionStatus.notDetermined;
  bool _isLoading = true;
  bool _isConnecting = false;

  // Daily goals
  static const int _stepGoal = 8000;
  static const int _calorieGoal = 500;
  static const double _distGoal = 5.0; // km
  static const int _bpmGoal = 120; // moderate activity zone

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final status = await _healthService.checkPermissionStatus();

    if (!mounted) return;
    setState(() => _permStatus = status);

    if (status == HealthPermissionStatus.granted) {
      await _loadStats();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final stats = await _healthService.getTodayStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
      // Sync to Firestore in background
      _healthService.syncTodayToFirestore(widget.memberId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stats = FitnessStats.empty();
        _isLoading = false;
      });
    }
  }

  Future<void> _connectHealthConnect() async {
    if (_isConnecting) return;
    setState(() => _isConnecting = true);

    final granted = await _healthService.requestPermissions();

    if (!mounted) return;
    setState(() => _isConnecting = false);

    if (granted) {
      setState(() => _permStatus = HealthPermissionStatus.granted);
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Check Health Connect synced! Your real stats are live.',
            ),
            backgroundColor: AppColors.neonTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      setState(() => _permStatus = HealthPermissionStatus.denied);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please grant Health Connect permissions to sync your stats.',
            ),
            backgroundColor: AppColors.neonOrange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OPEN SETTINGS',
              textColor: Colors.white,
              onPressed: () => _healthService.openHealthConnectSettings(),
            ),
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Health Connect not available on device
    if (_permStatus == HealthPermissionStatus.unavailable) {
      return _buildUnavailableCard();
    }

    // Not yet connected — show connect card
    if (_permStatus != HealthPermissionStatus.granted) {
      return _buildConnectCard();
    }

    // Loading real data
    if (_isLoading) {
      return _buildLoadingState();
    }

    // Connected — show real (or zero) stats
    return _buildStatsGrid();
  }

  // ── Stats Grid ────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return Column(
      children: [
        // Top row: Steps + Calories
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'STEPS',
                value: _stats.isRealData ? _formatNumber(_stats.steps) : '0',
                subValue: '/ ${_formatNumber(_stepGoal)}',
                icon: Icons.directions_walk_rounded,
                color: AppColors.neonTeal,
                progress: _stats.stepProgress(goal: _stepGoal),
                delay: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'KCAL',
                value: _stats.isRealData ? '${_stats.calories}' : '0',
                subValue: '/ $_calorieGoal',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.neonOrange,
                progress: _stats.calorieProgress(goal: _calorieGoal),
                delay: 200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row: Distance + Heart Rate
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'KM',
                value: _stats.isRealData
                    ? _stats.distance.toStringAsFixed(1)
                    : '0.0',
                subValue: '/ ${_distGoal.toStringAsFixed(0)} km',
                icon: Icons.route_rounded,
                color: AppColors.neonLime,
                progress: (_stats.distance / _distGoal).clamp(0.0, 1.0),
                delay: 300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'BPM',
                value: _stats.isRealData && _stats.heartRate > 0
                    ? '${_stats.heartRate}'
                    : '--',
                subValue: _stats.maxHeartRate > 0
                    ? 'max ${_stats.maxHeartRate}'
                    : 'avg',
                icon: Icons.favorite_rounded,
                color: Colors.redAccent,
                progress: _stats.heartRate > 0
                    ? (_stats.heartRate / _bpmGoal).clamp(0.0, 1.0)
                    : 0.0,
                delay: 400,
              ),
            ),
          ],
        ),
        // "Not synced" hint if data is empty
        if (!_stats.isRealData) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _loadStats,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sync_rounded,
                  size: 14,
                  color: AppColors.neonTeal.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 6),
                Text(
                  'TAP TO SYNC TODAY\'S DATA',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.neonTeal.withValues(alpha: 0.7),
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ],
    );
  }

  // ── Connect Card ──────────────────────────────────────────────────────────

  Widget _buildConnectCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.neonTeal.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonTeal.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon
          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.neonTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.neonTeal.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: AppColors.neonTeal,
                  size: 30,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.06, 1.06),
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          Text(
            'Connect Health Connect',
            style: AppTextStyles.heading3.copyWith(color: AppColors.neonTeal),
          ),
          const SizedBox(height: 8),
          Text(
            'Sync your real steps, calories and heart rate automatically.\nWorks with Apple Watch, Wear OS, Mi Band & Fitbit.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Connect Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isConnecting ? null : _connectHealthConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonTeal,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.neonTeal.withValues(
                  alpha: 0.5,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _isConnecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.monitor_heart_rounded, size: 20),
              label: Text(
                _isConnecting ? 'CONNECTING...' : 'CONNECT NOW',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          // Show "Open Settings" if previously denied
          if (_permStatus == HealthPermissionStatus.denied) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _healthService.openHealthConnectSettings(),
              icon: Icon(
                Icons.settings_rounded,
                size: 14,
                color: AppColors.gray400,
              ),
              label: Text(
                'Open Health Connect Settings',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  // ── Loading State ─────────────────────────────────────────────────────────

  Widget _buildLoadingState() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(delay: 0)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonCard(delay: 100)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(delay: 200)),
            const SizedBox(width: 12),
            Expanded(child: _buildSkeletonCard(delay: 300)),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeletonCard({required int delay}) {
    return Container(
          height: 110,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.neonTeal.withValues(alpha: 0.4),
              strokeWidth: 2,
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.04))
        .animate()
        .fadeIn(delay: delay.ms);
  }

  // ── Unavailable Card ──────────────────────────────────────────────────────

  Widget _buildUnavailableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray800),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.gray400,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Connect Not Available',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Install Health Connect from the Play Store to sync your fitness data.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────────────────

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subValue,
    required IconData icon,
    required Color color,
    required double progress,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              SizedBox(
                height: 24,
                width: 24,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progress),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, val, child) => CircularProgressIndicator(
                    value: val,
                    strokeWidth: 3,
                    backgroundColor: AppColors.gray800,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: AppTextStyles.heading2.copyWith(fontSize: 26)),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(color: AppColors.gray600),
              children: [
                TextSpan(text: '$subValue '),
                TextSpan(
                  text: label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2, end: 0);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return '$n';
  }
}
