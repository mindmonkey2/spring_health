// lib/screens/member/trainer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/trainer_model.dart';
import '../../models/diet_plan_model.dart';
import '../../services/trainer_service.dart';

// ── Top-level colour / icon helpers ────────────────────────────────
Color specColor(String spec) {
  final s = spec.toLowerCase();
  if (s.contains('gym') || s.contains('weight') || s.contains('strength')) {
    return AppColors.neonLime;
  }
  if (s.contains('yoga')) return AppColors.neonTeal;
  if (s.contains('cardio')) return AppColors.neonOrange;
  if (s.contains('zumba') || s.contains('dance')) {
    return const Color(0xFFFF4081);
  }
  if (s.contains('cross') || s.contains('hiit')) return const Color(0xFFFF5252);
  return AppColors.gray400;
}

Color mealColor(String mealType) {
  switch (mealType.toLowerCase()) {
    case 'breakfast':
      return AppColors.warning;
    case 'lunch':
      return AppColors.neonLime;
    case 'dinner':
      return AppColors.neonTeal;
    case 'pre-workout':
      return AppColors.neonOrange;
    case 'post-workout':
      return const Color(0xFFAB47BC);
    case 'snack':
      return const Color(0xFFFF4081);
    default:
      return AppColors.gray400;
  }
}

IconData mealIcon(String mealType) {
  switch (mealType.toLowerCase()) {
    case 'breakfast':
      return Icons.free_breakfast_rounded;
    case 'lunch':
      return Icons.lunch_dining_rounded;
    case 'dinner':
      return Icons.dinner_dining_rounded;
    case 'pre-workout':
      return Icons.bolt_rounded;
    case 'post-workout':
      return Icons.fitness_center_rounded;
    case 'snack':
      return Icons.cookie_rounded;
    default:
      return Icons.restaurant_rounded;
  }
}

// Enum-based goal colour — exhaustive + compiler-checked
Color goalColor(DietGoal goal) {
  switch (goal) {
    case DietGoal.weightLoss:
      return AppColors.neonOrange;
    case DietGoal.muscleGain:
      return AppColors.neonLime;
    case DietGoal.bulking:
      return const Color(0xFF42A5F5);
    case DietGoal.cutting:
      return const Color(0xFFFF5252);
    case DietGoal.maintenance:
      return AppColors.neonTeal;
  }
}

// Private helper (was top-level formatWhatsApp — now _formatWa, still accessible within file)
String _formatWa(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('91') && digits.length == 12) return digits;
  if (digits.length == 10) return '91$digits';
  return digits;
}

// ── Trainer Screen ──────────────────────────────────────────────────
class TrainerScreen extends StatefulWidget {
  final String memberId;
  final String branch;

  const TrainerScreen({
    super.key,
    required this.memberId,
    required this.branch,
  });

  @override
  State<TrainerScreen> createState() => _TrainerScreenState();
}

class _TrainerScreenState extends State<TrainerScreen>
    with SingleTickerProviderStateMixin {
  final service = TrainerService();
  late final TabController tabController;

  final searchCtrl = TextEditingController();
  String searchQuery = '';
  String selectedSpec = 'All';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    searchCtrl.addListener(
      () => setState(() => searchQuery = searchCtrl.text.toLowerCase()),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  // ── URL Launcher ─────────────────────────────────────────────────
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Profile sheet ─────────────────────────────────────────────────
  void _showProfileSheet(TrainerModel trainer, bool isMyTrainer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TrainerProfileSheet(
        trainer: trainer,
        isMyTrainer: isMyTrainer,
        onLaunch: _launch,
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
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
          'TRAINERS',
          style: AppTextStyles.heading2.copyWith(letterSpacing: 2),
        ),
        bottom: TabBar(
          controller: tabController,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: AppColors.neonLime, width: 2),
          ),
          labelColor: AppColors.neonLime,
          unselectedLabelColor: AppColors.gray400,
          dividerColor: Colors.white12,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
          tabs: const [
            Tab(text: 'MY TRAINER'),
            Tab(text: 'GYM TRAINERS'),
          ],
        ),
      ),
      // Single outer stream — avoids double subscription
      body: StreamBuilder<TrainerModel?>(
        stream: service.getMyTrainerStream(widget.memberId),
        builder: (context, mySnap) {
          final myTrainer = mySnap.data;
          final loading = mySnap.connectionState == ConnectionState.waiting;
          return TabBarView(
            controller: tabController,
            children: [
              _buildMyTrainerTab(myTrainer, loading),
              _buildDirectoryTab(myTrainer?.id),
            ],
          );
        },
      ),
    );
  }

  // ── MY TRAINER TAB ────────────────────────────────────────────────
  Widget _buildMyTrainerTab(TrainerModel? trainer, bool loading) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.neonLime),
      );
    }
    if (trainer == null) return _buildNoTrainerState();

    return RefreshIndicator(
      color: AppColors.neonLime,
      backgroundColor: AppColors.cardSurface,
      onRefresh: () async {
        // Triggers stream re-listen; setState forces rebuild
        setState(() {});
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeroCard(
            trainer,
            true,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 16),
          _buildActionButtons(trainer).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(
                Icons.restaurant_rounded,
                color: AppColors.neonTeal,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'DIET PLAN',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neonTeal,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          StreamBuilder<DietPlanModel?>(
            stream: service.getDietPlanStream(widget.memberId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.neonTeal),
                  ),
                );
              }
              final plan = snap.data;
              return (plan == null
                      ? _buildNoDietPlanCard(trainer.name)
                      : _buildDietPlanSection(plan))
                  .animate()
                  .fadeIn(delay: 250.ms);
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Hero Card ─────────────────────────────────────────────────────
  Widget _buildHeroCard(TrainerModel trainer, bool isMyTrainer) {
    final sc = specColor(trainer.specialization);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [sc.withValues(alpha: 0.15), AppColors.cardSurface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sc.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Photo with online dot
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: sc, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: sc.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: sc.withValues(alpha: 0.15),
                      backgroundImage: trainer.photoUrl != null
                          ? NetworkImage(trainer.photoUrl!)
                          : null,
                      child: trainer.photoUrl == null
                          ? Text(
                              trainer.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: sc,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  if (trainer.isActive)
                    Positioned(
                      bottom: 3,
                      right: 3,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.neonLime,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardSurface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMyTrainer)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sc.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: sc),
                        ),
                        child: Text(
                          'YOUR TRAINER',
                          style: TextStyle(
                            color: sc,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    Text(
                      trainer.name,
                      style: AppTextStyles.heading2.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sc.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        trainer.specialization,
                        style: TextStyle(
                          color: sc,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          trainer.branch,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.gray400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 12),
          // Stats — member count is live from model (IMPROVEMENT NOTE:
          // in production, pipe a Stream<int> for assigned count)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem(
                trainer.experience,
                'Experience',
                Icons.schedule_rounded,
                sc,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _statItem(
                trainer.qualification.length > 12
                    ? '${trainer.qualification.substring(0, 12)}…'
                    : trainer.qualification,
                'Qualification',
                Icons.school_rounded,
                AppColors.neonTeal,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _statItem(
                '${trainer.assignedMembers.length}',
                'Members',
                Icons.group_rounded,
                AppColors.neonOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
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

  // ── Action Buttons ────────────────────────────────────────────────
  Widget _buildActionButtons(TrainerModel trainer) {
    return Row(
      children: [
        Expanded(
          child: _actionBtn(
            icon: Icons.call_rounded,
            label: 'CALL',
            color: AppColors.neonLime,
            onTap: () => _launch('tel:${trainer.phone}'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionBtn(
            icon: Icons.chat_rounded,
            label: 'WHATSAPP',
            color: AppColors.whatsApp,
            onTap: () => _launch('https://wa.me/${_formatWa(trainer.phone)}'),
          ),
        ),
        const SizedBox(width: 12),
        // MESSAGE button — honest label, no misleading "SOON" chip
        Expanded(
          child: _actionBtn(
            icon: Icons.message_rounded,
            label: 'MESSAGE',
            subLabel: 'Coming Soon',
            color: AppColors.gray400,
            isDisabled: true,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '📬 In-app messaging is planned for a future update!',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    String? subLabel,
    required Color color,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.cardSurface
              : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDisabled
                ? Colors.white.withValues(alpha: 0.05)
                : color.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isDisabled ? AppColors.gray400 : color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? AppColors.gray400 : color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            if (subLabel != null)
              Text(
                subLabel,
                style: const TextStyle(
                  color: AppColors.gray400,
                  fontSize: 8,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Diet Plan Section ─────────────────────────────────────────────
  Widget _buildDietPlanSection(DietPlanModel plan) {
    final gc = goalColor(plan.goal);
    final displayDate = plan.updatedAt ?? plan.assignedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Calorie ring + summary card ───────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gc.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              // Visual calorie ring
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: (plan.totalCalories / 3000).clamp(0.0, 1.0),
                      strokeWidth: 6,
                      backgroundColor: gc.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(gc),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${plan.totalCalories}',
                            style: TextStyle(
                              color: gc,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'kcal',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray400,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: gc.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: gc),
                          ),
                          child: Text(
                            plan.goal.label.toUpperCase(),
                            style: TextStyle(
                              color: gc,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${plan.trainerName}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Updated ${DateFormat('dd MMM yyyy').format(displayDate)}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 10,
                      ),
                    ),
                    if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        plan.notes!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Meal cards
        ...plan.meals.asMap().entries.map(
          (e) => _buildMealCard(e.value)
              .animate()
              .fadeIn(delay: (e.key * 80).ms)
              .slideX(begin: 0.05, end: 0),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealItem meal) {
    final color = mealColor(meal.mealType);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              mealIcon(meal.mealType),
                              color: color,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              meal.mealType.toUpperCase(),
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        if (meal.time.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              meal.time,
                              style: TextStyle(
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Food chips
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: meal.foods
                          .map(
                            (food) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundBlack,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                food,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    // Macros
                    Wrap(
                      spacing: 12,
                      children: [
                        _macro('🔥', '${meal.calories}', 'kcal', color),
                        if (meal.protein != null)
                          _macro(
                            '💪',
                            meal.protein!,
                            'prot',
                            AppColors.neonLime,
                          ),
                        if (meal.carbs != null)
                          _macro('🌾', meal.carbs!, 'carbs', AppColors.warning),
                        if (meal.fats != null)
                          _macro(
                            '🥑',
                            meal.fats!,
                            'fats',
                            AppColors.neonOrange,
                          ),
                      ],
                    ),
                    if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 12,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meal.notes!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.gray400,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macro(String emoji, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 10)),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray400,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ── No Diet Plan ──────────────────────────────────────────────────
  Widget _buildNoDietPlanCard(String trainerName) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonTeal.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Text('🥗', style: TextStyle(fontSize: 48))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.08, duration: 1200.ms),
          const SizedBox(height: 14),
          Text('No Diet Plan Yet', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            '$trainerName hasn\'t assigned a diet plan yet.\nCheck with them at the gym!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── No Trainer State ──────────────────────────────────────────────
  Widget _buildNoTrainerState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🏋️', style: TextStyle(fontSize: 72))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.1, duration: 1400.ms),
          const SizedBox(height: 24),
          Text('No Trainer Assigned', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Ask at the front desk or contact\ngym admin to get a trainer.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => tabController.animateTo(1),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.neonLime.withValues(alpha: 0.5),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            icon: const Icon(Icons.people_rounded, color: AppColors.neonLime),
            label: const Text(
              'BROWSE TRAINERS',
              style: TextStyle(color: AppColors.neonLime, letterSpacing: 1),
            ),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  // ── DIRECTORY TAB ─────────────────────────────────────────────────
  Widget _buildDirectoryTab(String? myTrainerId) {
    return StreamBuilder<List<TrainerModel>>(
      stream: service.getTrainersStream(widget.branch),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonLime),
          );
        }
        final trainers = snap.data ?? [];
        if (trainers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🤷', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('No Trainers Found', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text(
                  'No active trainers at ${widget.branch}.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.gray400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ).animate().fadeIn(),
          );
        }

        // Unique spec list for filter chips
        final specs = <String>[
          'All',
          ...trainers.map((t) => t.specialization).toSet(),
        ];

        // Local filter
        final filtered = trainers.where((t) {
          final matchSearch =
              searchQuery.isEmpty ||
              t.name.toLowerCase().contains(searchQuery) ||
              t.specialization.toLowerCase().contains(searchQuery);
          final matchSpec =
              selectedSpec == 'All' || t.specialization == selectedSpec;
          return matchSearch && matchSpec;
        }).toList();

        return Column(
          children: [
            // ── Search bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: searchCtrl,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or specialization...',
                  hintStyle: const TextStyle(color: AppColors.gray400),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.gray400,
                  ),
                  // IMPROVEMENT: show live result count in suffix
                  suffixIcon: searchQuery.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonLime.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${filtered.length}',
                                style: const TextStyle(
                                  color: AppColors.neonLime,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.gray400,
                              ),
                              onPressed: searchCtrl.clear,
                            ),
                          ],
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.neonLime.withValues(alpha: 0.5),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // ── Spec filter chips with clear-all ────────────────
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: specs.length + (selectedSpec != 'All' ? 1 : 0),
                itemBuilder: (ctx, i) {
                  // Leading "Clear" chip when a filter is active
                  if (selectedSpec != 'All' && i == 0) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedSpec = 'All'),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.clear_rounded,
                              size: 12,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final spec = specs[selectedSpec != 'All' ? i - 1 : i];
                  final isSelected = selectedSpec == spec;
                  final color = spec == 'All'
                      ? AppColors.neonLime
                      : specColor(spec);
                  return GestureDetector(
                    onTap: () => setState(() => selectedSpec = spec),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        spec,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.gray400,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Results count bar ─────────────────────────────────
            if (searchQuery.isNotEmpty || selectedSpec != 'All')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      '${filtered.length} trainer${filtered.length == 1 ? '' : 's'} found',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Trainer list ──────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            color: AppColors.gray400,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No trainers match your search',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) =>
                          _buildDirectoryCard(
                                filtered[i],
                                filtered[i].id == myTrainerId,
                              )
                              .animate()
                              .fadeIn(delay: (i * 60).ms)
                              .slideX(begin: 0.05, end: 0),
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Directory Card ────────────────────────────────────────────────
  Widget _buildDirectoryCard(TrainerModel trainer, bool isMyTrainer) {
    final sc = specColor(trainer.specialization);
    return GestureDetector(
      onTap: () => _showProfileSheet(trainer, isMyTrainer),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMyTrainer
                ? sc.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: sc, width: 2),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: sc.withValues(alpha: 0.15),
                backgroundImage: trainer.photoUrl != null
                    ? NetworkImage(trainer.photoUrl!)
                    : null,
                child: trainer.photoUrl == null
                    ? Text(
                        trainer.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: sc,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          trainer.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMyTrainer) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: sc,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MINE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 8,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sc.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: sc.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          trainer.specialization,
                          style: TextStyle(
                            color: sc,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${trainer.experience} exp',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${trainer.assignedMembers.length}',
                  style: AppTextStyles.heading3.copyWith(
                    color: sc,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'members',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray400,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.gray400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── TRAINER PROFILE BOTTOM SHEET ─────────────────────────────────────
class TrainerProfileSheet extends StatelessWidget {
  final TrainerModel trainer;
  final bool isMyTrainer;
  // FIX: pass launcher from parent so errors bubble up properly
  final Future<void> Function(String url) onLaunch;

  const TrainerProfileSheet({
    super.key,
    required this.trainer,
    required this.isMyTrainer,
    required this.onLaunch,
  });

  @override
  Widget build(BuildContext context) {
    final sc = specColor(trainer.specialization);
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray400.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Photo
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: sc, width: 3),
              boxShadow: [
                BoxShadow(color: sc.withValues(alpha: 0.3), blurRadius: 20),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: sc.withValues(alpha: 0.15),
              backgroundImage: trainer.photoUrl != null
                  ? NetworkImage(trainer.photoUrl!)
                  : null,
              child: trainer.photoUrl == null
                  ? Text(
                      trainer.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: sc,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          if (isMyTrainer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: sc.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sc),
              ),
              child: Text(
                'YOUR TRAINER',
                style: TextStyle(
                  color: sc,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            trainer.name,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: sc.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sc.withValues(alpha: 0.5)),
            ),
            child: Text(
              trainer.specialization,
              style: TextStyle(
                color: sc,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trainer.branch,
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _sheetStat(trainer.experience, 'Experience', AppColors.neonLime),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _sheetStat(
                trainer.qualification.length > 14
                    ? '${trainer.qualification.substring(0, 14)}…'
                    : trainer.qualification,
                'Qualification',
                AppColors.neonTeal,
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              _sheetStat(
                '${trainer.assignedMembers.length} Members',
                'Training',
                AppColors.neonOrange,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons — errors now handled via parent's _launch
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => onLaunch('tel:${trainer.phone}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.call_rounded),
                  label: const Text(
                    'CALL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      onLaunch('https://wa.me/${_formatWa(trainer.phone)}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.whatsApp,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text(
                    'WHATSAPP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CLOSE',
                style: TextStyle(color: AppColors.gray400, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sheetStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
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
}
