import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/ai_plan_model.dart';
import '../../services/ai_coach_service.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ai_loading_overlay.dart';

class DietPlanScreen extends StatefulWidget {
  const DietPlanScreen({super.key});

  @override
  State<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  AiDietPlanModel? _plan;
  bool _loading = true;
  bool _generating = false;
  String? _error;
  Timer? _cooldownTimer;
  Duration _cooldownRemaining = Duration.zero;

  final Map<int, bool> _expandedMeals = {};

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  String get _authUid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _loadPlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final planDoc = await FirebaseFirestore.instance
          .collection('dietPlans')
          .doc(_authUid)
          .get();

      if (planDoc.exists && planDoc.data() != null) {
        _plan = AiDietPlanModel.fromMap(planDoc.data()!, planDoc.id);
        _startCooldownTimer();
      } else {
        _plan = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    if (_plan == null) return;

    final cooldownEnd =
        _plan!.generatedAt.toDate().add(const Duration(hours: 24));
    final remaining = cooldownEnd.difference(DateTime.now());

    if (remaining.isNegative) {
      _cooldownRemaining = Duration.zero;
      return;
    }

    _cooldownRemaining = remaining;
    _cooldownTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final r = cooldownEnd.difference(DateTime.now());
      if (mounted) {
        setState(
            () => _cooldownRemaining = r.isNegative ? Duration.zero : r);
        if (r.isNegative) _cooldownTimer?.cancel();
      }
    });
  }

  bool get _canGenerate => _cooldownRemaining == Duration.zero;

  String get _cooldownLabel {
    final h = _cooldownRemaining.inHours;
    final m = _cooldownRemaining.inMinutes.remainder(60);
    return 'Refresh in ${h}h ${m}m';
  }

  Future<void> _onGenerateTapped() async {
    if (!_canGenerate) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          _plan == null ? 'Generate Diet Plan?' : 'Refresh Diet Plan?',
          style: const TextStyle(color: AppColors.neonLime),
        ),
        content: Text(
          _plan == null
              ? 'Gemini AI will generate a personalised 5-meal Indian diet plan based on your health profile and goals.'
              : 'Your current plan will be replaced. A new plan costs one 24h cooldown slot.',
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Generate 🤖',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _generating = true);
    try {
      await AiCoachService.instance.generateDietPlan(_authUid);
      await _loadPlan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generation failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.backgroundBlack,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundBlack,
            elevation: 0,
            title: const Text(
              'My Diet Plan',
              style: TextStyle(
                  color: AppColors.neonLime, fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: AppColors.neonLime),
          ),
          body: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.neonLime))
              : _error != null
                  ? _buildErrorState()
                  : _plan == null
                      ? _buildEmptyState()
                      : _buildPlanContent(),
        ),
        if (_generating)
          const AiLoadingOverlay(message: 'Generating your diet plan...'),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: Colors.white60),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime),
            onPressed: _loadPlan,
            child: const Text('Retry',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu,
                    color: AppColors.neonLime, size: 64)
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            const Text(
              'No diet plan yet',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate a personalised 5-meal Indian diet plan powered by Gemini AI.',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
              onPressed: _onGenerateTapped,
              icon: const Icon(Icons.auto_awesome, color: Colors.black),
              label: const Text(
                'Generate My Diet Plan',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanContent() {
    final plan = _plan!;
    return RefreshIndicator(
      color: AppColors.neonLime,
      onRefresh: _loadPlan,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDailyTargetsCard(plan.dailyTargets),
          const SizedBox(height: 16),
          _buildMealsSection(plan.meals),
          const SizedBox(height: 16),
          _buildNotesSection(plan),
          const SizedBox(height: 16),
          _buildHydrationCard(plan.hydrationLitres),
          const SizedBox(height: 20),
          _buildGenerateButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDailyTargetsCard(Map<String, dynamic> targets) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glassDecoration(borderColor: AppColors.neonLime),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Targets',
            style: TextStyle(
                color: AppColors.neonLime,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _targetTile('Calories',
                  '${targets['calories'] ?? '--'}', 'kcal', AppColors.neonLime),
              _targetTile('Protein',
                  '${targets['protein'] ?? '--'}', 'g', AppColors.neonTeal),
              _targetTile('Carbs',
                  '${targets['carbs'] ?? '--'}', 'g', AppColors.neonOrange),
              _targetTile('Fat', '${targets['fat'] ?? '--'}', 'g',
                  const Color(0xFFCE93D8)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _targetTile(
      String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(unit,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 10)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsSection(List<Map<String, dynamic>> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Text(
            'Meal Plan',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        ...meals.asMap().entries.map((e) => _buildMealCard(e.key, e.value)),
      ],
    );
  }

  Widget _buildMealCard(int index, Map<String, dynamic> meal) {
    final isExpanded = _expandedMeals[index] ?? false;
    final name = meal['name'] as String? ??
        meal['mealType'] as String? ??
        'Meal ${index + 1}';
    final timing =
        meal['timing'] as String? ?? meal['time'] as String? ?? '';
    final totalKcal = meal['totalKcal'] ?? meal['calories'] ?? 0;
    final rawItems = meal['items'] as List<dynamic>? ??
        meal['foods'] as List<dynamic>? ??
        [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _glassDecoration(
          borderColor: AppColors.neonTeal.withValues(alpha: 0.4)),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () =>
                setState(() => _expandedMeals[index] = !isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        if (timing.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonTeal
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppColors.neonTeal
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              timing,
                              style: const TextStyle(
                                  color: AppColors.neonTeal,
                                  fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$totalKcal kcal',
                      style: const TextStyle(
                          color: AppColors.neonLime,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.white60,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Column(
                children:
                    rawItems.map((item) => _buildFoodItem(item)).toList(),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(
        delay: Duration(milliseconds: 60 * index), duration: 350.ms);
  }

  Widget _buildFoodItem(dynamic item) {
    String displayName;
    String quantity = '';
    String kcal = '';

    if (item is Map<String, dynamic>) {
      displayName = item['name'] as String? ?? item.toString();
      quantity = item['quantity'] as String? ?? '';
      final k = item['kcal'] ?? item['calories'];
      kcal = k != null ? '$k kcal' : '';
    } else {
      displayName = item.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record,
              color: AppColors.neonTeal, size: 8),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              quantity.isNotEmpty ? '$displayName  · $quantity' : displayName,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          if (kcal.isNotEmpty)
            Text(
              kcal,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AiDietPlanModel plan) {
    final chips = <Widget>[];

    if (plan.nutritionNotes.isNotEmpty) {
      chips.add(_noteChip(plan.nutritionNotes, AppColors.neonLime));
    }
    if (plan.bpDietNote != null) {
      chips.add(_noteChip(
          'DASH Diet: ${plan.bpDietNote!}', const Color(0xFFFF8A80)));
    }
    if (plan.glucoseNote != null) {
      chips.add(_noteChip(
          'Blood Sugar: ${plan.glucoseNote!}', AppColors.neonTeal));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _glassDecoration(
          borderColor: AppColors.neonOrange.withValues(alpha: 0.3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Notes',
            style: TextStyle(
                color: AppColors.neonOrange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  Widget _noteChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _buildHydrationCard(double litres) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _glassDecoration(
          borderColor: const Color(0xFF40C4FF).withValues(alpha: 0.4)),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: Color(0xFF40C4FF), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hydration Target',
                  style: TextStyle(
                      color: Color(0xFF40C4FF),
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Drink at least ${litres.toStringAsFixed(1)} litres of water today',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
          Text(
            '${litres.toStringAsFixed(1)}L',
            style: const TextStyle(
                color: Color(0xFF40C4FF),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _canGenerate ? AppColors.neonLime : const Color(0xFF1A1A1A),
          foregroundColor: _canGenerate ? Colors.black : Colors.white60,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _canGenerate ? _onGenerateTapped : null,
        icon: Icon(
            _canGenerate ? Icons.auto_awesome : Icons.timer_outlined),
        label: Text(
          _canGenerate ? 'Refresh Plan 🤖' : _cooldownLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _glassDecoration({required Color borderColor}) {
    return BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor, width: 1),
    );
  }
}
