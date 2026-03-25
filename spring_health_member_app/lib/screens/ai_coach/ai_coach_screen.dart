import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wearable_snapshot_model.dart';
import '../../services/wearable_snapshot_service.dart';
import '../../services/ai_coach_service.dart';
import '../../widgets/ai_loading_overlay.dart';
import '../workout/workout_logger_screen.dart';
import '../health/health_profile_screen.dart';

class AiCoachScreen extends StatefulWidget {
  final String memberId;

  const AiCoachScreen({super.key, required this.memberId});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final _wearableService = WearableSnapshotService.instance;
  final _aiCoachService = AiCoachService();

  WearableSnapshotModel? _todaySnapshot;
  bool _isLoadingWearable = true;

  Map<String, dynamic>? _cachedWorkoutPlan;
  bool _isLoadingWorkoutPlan = true;

  Map<String, dynamic>? _cachedDietPlan;
  bool _isLoadingDietPlan = true;

  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _cooldownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    _loadWearableData();
    _loadWorkoutPlan();
    _loadDietPlan();
  }

  Future<void> _loadWearableData() async {
    setState(() => _isLoadingWearable = true);
    try {
      final snapshot = await _wearableService.getTodaySnapshot(widget.memberId);
      if (mounted) {
        setState(() {
          _todaySnapshot = snapshot;
          _isLoadingWearable = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading wearable data: $e');
      if (mounted) setState(() => _isLoadingWearable = false);
    }
  }

  Future<void> _syncWearable() async {
    setState(() => _isLoadingWearable = true);
    try {
      await _wearableService.syncTodaySnapshot(widget.memberId);
      await _loadWearableData();
    } catch (e) {
      debugPrint('Error syncing wearable data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync wearable data')),
        );
        setState(() => _isLoadingWearable = false);
      }
    }
  }

  Future<void> _loadWorkoutPlan() async {
    setState(() => _isLoadingWorkoutPlan = true);
    try {
      final plan = await _aiCoachService.getCachedWorkoutPlan(widget.memberId);
      if (mounted) {
        setState(() {
          _cachedWorkoutPlan = plan;
          _isLoadingWorkoutPlan = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading workout plan: $e');
      if (mounted) setState(() => _isLoadingWorkoutPlan = false);
    }
  }

  Future<void> _loadDietPlan() async {
    setState(() => _isLoadingDietPlan = true);
    try {
      final plan = await _aiCoachService.getCachedDietPlan(widget.memberId);
      if (mounted) {
        setState(() {
          _cachedDietPlan = plan;
          _isLoadingDietPlan = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading diet plan: $e');
      if (mounted) setState(() => _isLoadingDietPlan = false);
    }
  }

  Future<void> _generateWorkoutPlan() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Generate a new plan?'),
        content: const Text(
          'This will replace your current 7-day plan '
          'with a freshly generated one.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppColors.neonLime),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    AiLoadingOverlay.show(context, message: '🤖 Your AI coach is building\nyour plan...');

    try {
      await _aiCoachService.generateWorkoutPlan(widget.memberId);
      if (mounted) {
        AiLoadingOverlay.hide(context);
        _loadWorkoutPlan();
      }
    } catch (e) {
      if (mounted) {
        AiLoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _generateDietPlan() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('Regenerate Diet Plan?', style: AppTextStyles.heading3),
        content: Text(
          'Generate a new diet plan? This will replace your current plan.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonLime),
            child: const Text('Confirm', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (!mounted) return;
    AiLoadingOverlay.show(context, message: '🥗 Crafting your meal plan...');

    try {
      await _aiCoachService.generateDietPlan(widget.memberId);
      if (mounted) {
        AiLoadingOverlay.hide(context);
        _loadDietPlan();
      }
    } catch (e) {
      if (mounted) {
        AiLoadingOverlay.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundBlack,
          title: Text(
            'AI Personal Trainer',
            style: AppTextStyles.heading2,
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.neonLime,
            labelColor: AppColors.neonLime,
            unselectedLabelColor: AppColors.gray400,
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Week'),
              Tab(text: 'Diet'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTodayTab(_cachedWorkoutPlan),
            _buildWeekTab(),
            _buildDietTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDietTab() {
    if (_isLoadingDietPlan) {
      return const Center(child: CircularProgressIndicator(color: AppColors.neonLime));
    }

    if (_cachedDietPlan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu_rounded, color: AppColors.neonTeal, size: 56),
              const SizedBox(height: 16),
              Text('No diet plan yet', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              Text(
                'Your AI nutritionist will build a personalised '
                '5-meal Indian meal plan based on your goals, '
                'body metrics, and dietary preference.',
                style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _generateDietPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Get My AI Diet Plan', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final plan = _cachedDietPlan!;
    final targets = plan['dailyTargets'] as Map<String, dynamic>? ?? {};
    final meals = plan['meals'] as List<dynamic>? ?? [];

    final nutritionNotes = plan['nutritionNotes'] as String?;
    final bpDietNote = plan['bpDietNote'] as String?;
    final glucoseNote = plan['glucoseNote'] as String?;
    final supplementNote = plan['supplementNote'] as String?;

    return RefreshIndicator(
      color: AppColors.neonLime,
      backgroundColor: AppColors.surfaceDark,
      onRefresh: _loadDietPlan,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDailyTargetsCard(targets),
            const SizedBox(height: 24),
            ...meals.map((m) => _buildMealCard(m as Map<String, dynamic>)),
            const SizedBox(height: 16),
            if (nutritionNotes != null || bpDietNote != null || glucoseNote != null || supplementNote != null)
              _buildDietNotesSection(nutritionNotes, bpDietNote, glucoseNote, supplementNote),
            const SizedBox(height: 24),
            _buildDietActionButtons(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    final mealName = meal['mealName'] as String? ?? 'Meal';
    final timing = meal['timing'] as String? ?? '';
    final totalCalories = meal['totalCalories'] as int? ?? 0;
    final mealNote = meal['mealNote'] as String?;
    final foods = meal['foods'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '🍽️ $mealName',
                    style: AppTextStyles.heading3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  timing,
                  style: AppTextStyles.caption.copyWith(color: AppColors.neonLime),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...foods.map((f) {
                  final food = f as Map<String, dynamic>;
                  final name = food['name'] as String? ?? '';
                  final qty = food['quantity'] as String? ?? '';
                  final cal = food['approxCalories'] as int? ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.gray400)),
                        Expanded(
                          child: Text(
                            '$name — $qty',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                          ),
                        ),
                        Text('~$cal kcal', style: AppTextStyles.caption.copyWith(color: AppColors.gray400)),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Total: ~$totalCalories kcal',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neonLime, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (mealNote != null && mealNote.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 '),
                      Expanded(
                        child: Text(
                          mealNote,
                          style: AppTextStyles.caption.copyWith(color: AppColors.gray400, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietNotesSection(String? notes, String? bpNote, String? glucoseNote, String? suppNote) {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.neonLime),
              const SizedBox(width: 8),
              Text('Nutrition Coach Notes', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          if (notes != null) ...[
            Text(notes, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
            const SizedBox(height: 16),
          ],
          if (bpNote != null) ...[
            _buildNoteChip(Icons.favorite_border, bpNote, const Color(0xFFFF9800)),
            const SizedBox(height: 8),
          ],
          if (glucoseNote != null) ...[
            _buildNoteChip(Icons.water_drop_outlined, glucoseNote, Colors.yellow),
            const SizedBox(height: 8),
          ],
          if (suppNote != null) ...[
            _buildNoteChip(Icons.medication_liquid, suppNote, Colors.blue),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.caption.copyWith(color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTargetsCard(Map<String, dynamic> targets) {
    final calories = targets['calories'] as int? ?? 0;
    final protein = targets['proteinG'] as int? ?? 0;
    final carbs = targets['carbsG'] as int? ?? 0;
    final fat = targets['fatG'] as int? ?? 0;
    final waterLitres = targets['waterLitres'] as double? ?? 0.0;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: AppColors.neonLime),
              const SizedBox(width: 8),
              Text('Daily Targets', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroMacro('🔥 Calories', '$calories kcal'),
              _buildMacroMacro('💪 Protein', '${protein}g'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroMacro('🌾 Carbs', '${carbs}g'),
              _buildMacroMacro('🥑 Fat', '${fat}g'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Drink ${waterLitres.toStringAsFixed(1)}L water today',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMacroProgressBars(),
        ],
      ),
    );
  }

  Widget _buildMacroMacro(String title, String value) {
    return Row(
      children: [
        Text('$title: ', style: AppTextStyles.caption.copyWith(color: AppColors.gray400)),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMacroProgressBars() {
    return Column(
      children: [
        _buildProgressBar(AppColors.neonLime, 0.0), // Always 0% as logging happens elsewhere
        const SizedBox(height: 8),
        _buildProgressBar(Colors.blue, 0.0),
        const SizedBox(height: 8),
        _buildProgressBar(Colors.orange, 0.0),
        const SizedBox(height: 8),
        _buildProgressBar(Colors.purple, 0.0),
      ],
    );
  }

  Widget _buildProgressBar(Color color, double progress) {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: progress * MediaQuery.of(context).size.width, // Assuming parent is constrained
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildDietActionButtons() {
    final generatedAt = _cachedDietPlan?['generatedAt'] as Timestamp?;
    bool canRegenerate = true;
    String regenText = 'Regenerate Diet Plan';

    if (generatedAt != null) {
      final generated = generatedAt.toDate();
      final diff = generated.add(const Duration(hours: 24)).difference(DateTime.now());
      if (!diff.isNegative) {
        canRegenerate = false;
        final h = diff.inHours;
        final m = diff.inMinutes.remainder(60);
        regenText = 'Regenerate in ${h}h ${m}m';
      }
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: canRegenerate ? _generateDietPlan : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: canRegenerate ? AppColors.neonLime : AppColors.gray600),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          regenText,
          style: AppTextStyles.button.copyWith(color: canRegenerate ? AppColors.neonLime : AppColors.gray600),
        ),
      ),
    );
  }

  Widget _buildTodayTab(Map<String, dynamic>? plan) {
    if (plan == null) {
      return RefreshIndicator(
        color: AppColors.neonLime,
        backgroundColor: AppColors.surfaceDark,
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecoveryStatusCard(plan),
              const SizedBox(height: 24),
              _buildActionButtons(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      );
    }

    final status = plan['status'] as String? ?? 'active';

    if (status.startsWith('medicalhold')) {
      return RefreshIndicator(
        color: AppColors.neonLime,
        backgroundColor: AppColors.surfaceDark,
        onRefresh: _loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecoveryStatusCard(plan),
              const SizedBox(height: 24),
              _buildMedicalHoldCard(status),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonLime,
      backgroundColor: AppColors.surfaceDark,
      onRefresh: _loadAllData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecoveryStatusCard(plan),
            const SizedBox(height: 24),
            _buildCoachNoteCard(plan),
            const SizedBox(height: 24),
            _buildTodayWorkoutSection(plan),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalHoldCard(String status) {
    if (status == 'medicalhold:bpcrisis') {
      return _buildAlertCard(
        title: '⚠️ High Blood Pressure Alert',
        message: 'Your BP reading requires medical clearance before exercise. Please consult a doctor before your next session.',
        color: AppColors.error,
        isPulsing: false,
      );
    }
    if (status == 'medicalhold:fever') {
      return _buildAlertCard(
        title: '🤒 Rest Today',
        message: 'Your body temperature is elevated. Complete rest is recommended. Stay hydrated and recover fully.',
        color: const Color(0xFFFF9800), // neonOrange
        isPulsing: false,
      );
    }
    if (status == 'medicalhold:cardiacevent') {
      return _buildAlertCard(
        title: '⚠️ Cardiac Alert Detected',
        message: 'An irregular heart rate event was detected. Please consult a doctor before resuming exercise.',
        color: AppColors.error,
        isPulsing: true,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildWeekTab() {
    if (_isLoadingWorkoutPlan) {
      return const Center(child: CircularProgressIndicator(color: AppColors.neonLime));
    }

    if (_cachedWorkoutPlan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.smart_toy_rounded, color: AppColors.neonLime, size: 80),
              const SizedBox(height: 24),
              Text('No workout plan yet', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              Text(
                'Generate your first AI personalized workout plan based on your goals and health data.',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _generateWorkoutPlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Generate Plan', style: AppTextStyles.button),
              ),
            ],
          ),
        ),
      );
    }

    final plan = _cachedWorkoutPlan!;
    final weeklyFocus = plan['weeklyFocus'] as String? ?? 'Build strength and improve conditioning';
    final generatedAt = plan['generatedAt'] as Timestamp?;
    final weeklyPlan = plan['weeklyPlan'] as List<dynamic>? ?? [];

    int currentDayIndex = 0;
    if (generatedAt != null) {
      final daysSince = DateTime.now().difference(generatedAt.toDate()).inDays;
      currentDayIndex = daysSince.clamp(0, 6);
    }

    return RefreshIndicator(
      color: AppColors.neonLime,
      backgroundColor: AppColors.surfaceDark,
      onRefresh: _loadWorkoutPlan,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This Week\'s Focus', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Text(
                    weeklyFocus,
                    style: AppTextStyles.heading3.copyWith(color: AppColors.neonLime, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(weeklyPlan.length, (index) {
              final dayPlan = weeklyPlan[index] as Map<String, dynamic>;
              final isToday = index == currentDayIndex;
              return _buildDayExpandableCard(index + 1, dayPlan, isToday);
            }),
            const SizedBox(height: 24),
            if (generatedAt != null)
              Center(
                child: Text(
                  'Plan generated ${_getTimeAgo(generatedAt.toDate())}',
                  style: AppTextStyles.caption,
                ),
              ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildDayExpandableCard(int dayNumber, Map<String, dynamic> dayPlan, bool isToday) {
    final sessionType = dayPlan['sessionType'] as String? ?? 'Workout';
    final estimatedMinutes = dayPlan['estimatedMinutes'] as int? ?? 0;
    final isRestDay = dayPlan['isRestDay'] as bool? ?? false;
    final exercises = dayPlan['exercises'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.neonLime : Colors.white.withValues(alpha: 0.05),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: isToday ? AppColors.neonLime : AppColors.gray400,
          collapsedIconColor: AppColors.gray400,
          title: Row(
            children: [
              Text(
                'Day $dayNumber',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isToday ? AppColors.neonLime : AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  sessionType,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Text(
            isRestDay ? 'Rest' : '${estimatedMinutes}m',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: isRestDay
                  ? Center(
                      child: Text(
                        'Active Recovery Day',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: exercises.map((e) => _buildExerciseCard(e as Map<String, dynamic>)).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'just now';
  }

  // --- Reused widgets from Today tab ---

  Widget _buildRecoveryStatusCard(Map<String, dynamic>? plan) {
    if (_isLoadingWearable) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.neonLime),
        ),
      );
    }

    if (_todaySnapshot == null) {
      return _buildGlassCard(
        child: Column(
          children: [
            const Icon(Icons.watch_rounded, color: AppColors.gray400, size: 48),
            const SizedBox(height: 16),
            Text(
              'Sync your wearable to see recovery data',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _syncWearable,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Sync Now'),
            ),
          ],
        ),
      );
    }

    final s = _todaySnapshot!;

    Color chipColor;
    String chipText;
    bool isPulsing = false;

    switch (s.recoveryStatus) {
      case 'fully_recovered':
        chipColor = AppColors.neonLime;
        chipText = '🟢 Fully Recovered';
        break;
      case 'recovered':
        chipColor = AppColors.neonLime;
        chipText = '✅ Recovered';
        break;
      case 'moderate':
        chipColor = const Color(0xFFFF9800);
        chipText = '🟡 Moderate';
        break;
      case 'fatigued':
        chipColor = AppColors.error;
        chipText = '🔴 Fatigued';
        break;
      case 'sick':
        chipColor = AppColors.error;
        chipText = '🤒 Rest Today';
        isPulsing = true;
        break;
      case 'cardiac_flag':
        chipColor = AppColors.error;
        chipText = '⚠️ Cardiac Alert';
        isPulsing = true;
        break;
      default:
        chipColor = AppColors.gray600;
        chipText = '📡 No Wearable Data';
    }

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor),
      ),
      child: Text(
        chipText,
        style: AppTextStyles.bodyLarge.copyWith(color: chipColor, fontWeight: FontWeight.bold),
      ),
    );

    if (isPulsing) {
      chip = chip.animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.5, end: 1.0);
    }

    return _buildGlassCard(
      child: Column(
        children: [
          chip,
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMetricTile('💤 Sleep', '${s.totalSleepMinutes} min', s.sleepQuality),
              _buildMetricTile('❤️ Resting HR', s.restingHeartRate != null ? '${s.restingHeartRate!.toInt()} bpm' : '—', null),
              _buildMetricTile('📊 HRV', s.heartRateVariability != null ? '${s.heartRateVariability!.toInt()} ms' : '—', null),
              _buildMetricTile('👣 Steps', '${s.steps}', 'today'),
              _buildMetricTile('🔥 Active Cal', '${s.activeCaloriesBurned.toInt()} kcal', null),
              _buildMetricTile('🌡️ Temp', s.bodyTemperature != null ? '${s.bodyTemperature!.toStringAsFixed(1)}°C' : '—', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, String? subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(width: 4),
              Text('($subtitle)', style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCoachNoteCard(Map<String, dynamic> plan) {
    final coachNote = plan['coachNote'] as String?;
    final bpNote = plan['bpNote'] as String?;
    final recoveryNote = plan['recoveryNote'] as String?;

    if (coachNote == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.neonLime, width: 4)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: AppColors.neonLime),
              const SizedBox(width: 8),
              Text('Your AI Coach', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 12),
          Text(coachNote, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
          const SizedBox(height: 12),
          if (bpNote != null)
            Chip(
              label: Text(bpNote),
              backgroundColor: const Color(0xFFFF9800).withValues(alpha: 0.2), // AppColors.neonOrange
              labelStyle: const TextStyle(color: Color(0xFFFF9800)),
              avatar: const Icon(Icons.favorite_rounded,
                           color: Color(0xFFFF9800), size: 14),
            ),
          if (recoveryNote != null)
            Chip(
              label: Text(recoveryNote),
              backgroundColor: Colors.yellow.withValues(alpha: 0.15),
              labelStyle: TextStyle(color: Colors.yellow.shade700),
              avatar: Icon(Icons.bedtime_rounded,
                           color: Colors.yellow.shade700, size: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({required String title, required String message, required Color color, required bool isPulsing}) {
    Widget card = Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading3.copyWith(color: color)),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
        ],
      ),
    );

    if (isPulsing) {
      return card.animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.7, end: 1.0);
    }
    return card;
  }

  Widget _buildTodayWorkoutSection(Map<String, dynamic> plan) {
    final weeklyPlan = plan['weeklyPlan'] as List<dynamic>? ?? [];
    if (weeklyPlan.isEmpty) return const SizedBox.shrink();

    final generatedAt = (plan['generatedAt'] as Timestamp).toDate();
    final daysSince = DateTime.now().difference(generatedAt).inDays;
    final todayIndex = daysSince.clamp(0, 6);
    final todayPlan = weeklyPlan[todayIndex] as Map<String, dynamic>;

    final sessionType = todayPlan['sessionType'] as String? ?? 'Workout';
    final estimatedMinutes = todayPlan['estimatedMinutes'] as int? ?? 0;
    final isRestDay = todayPlan['isRestDay'] as bool? ?? false;
    final exercises = todayPlan['exercises'] as List<dynamic>? ?? [];

    if (isRestDay) {
      return _buildGlassCard(
        child: Column(
          children: [
            const Icon(Icons.self_improvement_rounded, color: AppColors.neonTeal, size: 48),
            const SizedBox(height: 16),
            Text('Active Recovery Day', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text(
              'Light stretching, walking, or yoga recommended today.\nYour muscles are rebuilding — rest is part of the plan.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Session', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(sessionType, style: AppTextStyles.heading3),
                  Text('~${estimatedMinutes}m', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neonLime)),
                ],
              ),
            ],
          ),
        ),
        if (exercises.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...exercises.map((e) => _buildExerciseCard(e as Map<String, dynamic>)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutLoggerScreen(
                      memberId: widget.memberId,
                      preloadedExercises: List<Map<String, dynamic>>.from(exercises),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Start Today\'s Workout', style: AppTextStyles.button),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final name = exercise['name'] as String? ?? 'Exercise';
    final sets = exercise['sets'] as int? ?? 0;
    final reps = exercise['reps'] as String? ?? '0';
    final rest = exercise['restSeconds'] as int? ?? 60;
    final coachingCue = exercise['coachingCue'] as String?;
    final targetMuscles = (exercise['targetMuscles'] as List<dynamic>? ?? []).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.neonLime, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('$sets sets × $reps', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
              const Spacer(),
              Text('Rest: ${rest}s', style: AppTextStyles.caption),
            ],
          ),
          if (coachingCue != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 '),
                Expanded(child: Text(coachingCue, style: AppTextStyles.caption.copyWith(color: AppColors.gray400))),
              ],
            ),
          ],
          if (targetMuscles.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎯 '),
                Expanded(child: Text(targetMuscles, style: AppTextStyles.caption.copyWith(color: AppColors.gray400))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final generatedAt = _cachedWorkoutPlan?['generatedAt'] as Timestamp?;
    bool canRegenerate = true;
    String regenText = 'Regenerate Plan';

    if (generatedAt != null) {
      final generated = generatedAt.toDate();
      final diff = generated.add(const Duration(hours: 24)).difference(DateTime.now());
      if (!diff.isNegative) {
        canRegenerate = false;
        final h = diff.inHours;
        final m = diff.inMinutes.remainder(60);
        regenText = 'Regenerate in ${h}h ${m}m';
      }
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: canRegenerate ? _generateWorkoutPlan : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: canRegenerate ? AppColors.neonLime : AppColors.gray600),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              regenText,
              style: AppTextStyles.button.copyWith(color: canRegenerate ? AppColors.neonLime : AppColors.gray600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HealthProfileScreen(memberId: widget.memberId)),
            );
          },
          icon: const Icon(Icons.fitness_center, color: AppColors.gray400, size: 20),
          label: Text('Update your metrics for better AI recommendations', style: AppTextStyles.caption, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
