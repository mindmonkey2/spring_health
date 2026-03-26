import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/health_profile_model.dart';
import '../../models/body_metrics_log_model.dart';
import '../../models/fitness_test_model.dart';
import '../../services/health_profile_service.dart';

class HealthProfileScreen extends StatefulWidget {
  final String memberId;
  const HealthProfileScreen({super.key, required this.memberId});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen>
    with SingleTickerProviderStateMixin {
  final _service = HealthProfileService();
  late TabController _tabController;

  bool _isLoading = true;
  List<BodyMetricsLogModel> _logs = [];
  FitnessTestModel? _latestTest;

  // Controllers for Tab 1 (Metrics)
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _armsCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _bpSysCtrl = TextEditingController();
  final _bpDiaCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();

  // State for Tab 1 Dropdowns/Chips
  String? _bloodGroup;
  String? _dietaryPreference;
  List<String> _medicalConditions = [];
  List<String> _jointRestrictions = [];
  String? _fitnessGoal;
  double? _bmi;
  String _bpCategory = 'Normal';

  // Controllers for Tab 2 (Fitness Tests)
  final _pushupsCtrl = TextEditingController();
  final _pullupsCtrl = TextEditingController();
  final _squatsCtrl = TextEditingController();
  final _plankCtrl = TextEditingController();
  final _squat1rmCtrl = TextEditingController();
  final _deadlift1rmCtrl = TextEditingController();
  final _benchpress1rmCtrl = TextEditingController();
  String _overallLevel = 'beginner';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _setupListeners();
  }

  void _setupListeners() {
    void updateBmi() {
      final w = double.tryParse(_weightCtrl.text);
      final h = double.tryParse(_heightCtrl.text);
      if (w != null && h != null && h > 0) {
        setState(() {
          _bmi = w / ((h / 100) * (h / 100));
        });
      }
    }

    _weightCtrl.addListener(updateBmi);
    _heightCtrl.addListener(updateBmi);

    void updateBpCat() {
      final s = int.tryParse(_bpSysCtrl.text);
      final d = int.tryParse(_bpDiaCtrl.text);
      if (s != null && d != null) {
        setState(() {
          _bpCategory = HealthProfileModel.bpCategory(s, d);
        });
      }
    }

    _bpSysCtrl.addListener(updateBpCat);
    _bpDiaCtrl.addListener(updateBpCat);

    void updateLevel() {
      final pu = int.tryParse(_pushupsCtrl.text);
      final pll = int.tryParse(_pullupsCtrl.text);
      final plk = double.tryParse(_plankCtrl.text);
      setState(() {
        _overallLevel = FitnessTestModel.deriveOverallLevel(
          pushups: pu,
          pullups: pll,
          plank: plk,
        );
      });
    }

    _pushupsCtrl.addListener(updateLevel);
    _pullupsCtrl.addListener(updateLevel);
    _plankCtrl.addListener(updateLevel);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final profile = await _service.getHealthProfile(widget.memberId);
    final logs = await _service.getMetricsHistory(widget.memberId);
    final latestTest = await _service.getLatestFitnessTest(widget.memberId);

    if (profile != null) {
      _weightCtrl.text = profile.weightKg?.toString() ?? '';
      _heightCtrl.text = profile.heightCm?.toString() ?? '';
      _bodyFatCtrl.text = profile.bodyFatPct?.toString() ?? '';
      _waistCtrl.text = profile.waistCm?.toString() ?? '';
      _chestCtrl.text = profile.chestCm?.toString() ?? '';
      _armsCtrl.text = profile.armCm?.toString() ?? '';
      _hipsCtrl.text = profile.hipCm?.toString() ?? '';
      _bpSysCtrl.text = profile.bpSystolic?.toString() ?? '';
      _bpDiaCtrl.text = profile.bpDiastolic?.toString() ?? '';
      _hrCtrl.text = profile.restingHeartRate?.toString() ?? '';

      _bloodGroup = profile.bloodGroup;
      _dietaryPreference = profile.dietaryPreference;
      _medicalConditions = List.from(profile.medicalConditions);
      _jointRestrictions = List.from(profile.jointRestrictions);
      _fitnessGoal = profile.fitnessGoal;
      _bmi = profile.bmi;

      if (profile.bpSystolic != null && profile.bpDiastolic != null) {
        _bpCategory = HealthProfileModel.bpCategory(
          profile.bpSystolic!,
          profile.bpDiastolic!,
        );
      }
    }

    if (mounted) {
      setState(() {
        _logs = logs;
        _latestTest = latestTest;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _bodyFatCtrl.dispose();
    _waistCtrl.dispose();
    _chestCtrl.dispose();
    _armsCtrl.dispose();
    _hipsCtrl.dispose();
    _bpSysCtrl.dispose();
    _bpDiaCtrl.dispose();
    _hrCtrl.dispose();

    _pushupsCtrl.dispose();
    _pullupsCtrl.dispose();
    _squatsCtrl.dispose();
    _plankCtrl.dispose();
    _squat1rmCtrl.dispose();
    _deadlift1rmCtrl.dispose();
    _benchpress1rmCtrl.dispose();
    super.dispose();
  }

  // ─── SAVE METRICS ───────────────────────────────────────────────

  Future<void> _saveMetrics() async {
    final w = double.tryParse(_weightCtrl.text);
    final h = double.tryParse(_heightCtrl.text);
    final bf = double.tryParse(_bodyFatCtrl.text);
    final wa = double.tryParse(_waistCtrl.text);
    final c = double.tryParse(_chestCtrl.text);
    final a = double.tryParse(_armsCtrl.text);
    final hip = double.tryParse(_hipsCtrl.text);
    final bps = int.tryParse(_bpSysCtrl.text);
    final bpd = int.tryParse(_bpDiaCtrl.text);
    final hr = int.tryParse(_hrCtrl.text);

    final newProfile = HealthProfileModel(
      id: widget.memberId,
      weightKg: w,
      heightCm: h,
      bodyFatPct: bf,
      waistCm: wa,
      chestCm: c,
      armCm: a,
      hipCm: hip,
      bpSystolic: bps,
      bpDiastolic: bpd,
      restingHeartRate: hr,
      bloodGroup: _bloodGroup,
      fitnessGoal: _fitnessGoal,
      fitnessLevel: _overallLevel,
      jointRestrictions: _jointRestrictions,
      medicalConditions: _medicalConditions,
      dietaryPreference: _dietaryPreference,
      lastUpdated: DateTime.now(),
    );

    final log = BodyMetricsLogModel(
      id: '',
      memberId: widget.memberId,
      weightKg: w,
      bodyFatPct: bf,
      waistCm: wa,
      chestCm: c,
      armCm: a,
      bpSystolic: bps,
      bpDiastolic: bpd,
      restingHeartRate: hr,
      loggedAt: DateTime.now(),
    );

    await _service.saveHealthProfile(newProfile);
    await _service.logBodyMetrics(widget.memberId, log);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Health profile updated')));
      _loadData();
    }
  }

  // ─── SAVE FITNESS TEST ──────────────────────────────────────────

  Future<void> _saveFitnessTest() async {
    final pu = int.tryParse(_pushupsCtrl.text);
    final pll = int.tryParse(_pullupsCtrl.text);
    final sq = int.tryParse(_squatsCtrl.text);
    final plk = double.tryParse(_plankCtrl.text);
    final sq1rm = double.tryParse(_squat1rmCtrl.text);
    final dl1rm = double.tryParse(_deadlift1rmCtrl.text);
    final bp1rm = double.tryParse(_benchpress1rmCtrl.text);

    final test = FitnessTestModel(
      id: '',
      memberId: widget.memberId,
      pushupsMax: pu,
      pullupsMax: pll,
      squatsMax: sq,
      plankSeconds: plk,
      squat1rmKg: sq1rm,
      deadlift1rmKg: dl1rm,
      benchpress1rmKg: bp1rm,
      overallLevel: _overallLevel,
      testedAt: DateTime.now(),
      nextTestDue: DateTime.now().add(const Duration(days: 30)),
    );

    await _service.saveFitnessTest(test);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitness test results saved')),
      );
      _loadData();

      _pushupsCtrl.clear();
      _pullupsCtrl.clear();
      _squatsCtrl.clear();
      _plankCtrl.clear();
      _squat1rmCtrl.clear();
      _deadlift1rmCtrl.clear();
      _benchpress1rmCtrl.clear();
    }
  }

  // ─── UI BUILDERS ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        title: Text('Health Profile & AI Goals', style: AppTextStyles.heading2),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.neonLime,
          labelColor: AppColors.neonLime,
          unselectedLabelColor: AppColors.gray400,
          tabs: const [
            Tab(text: 'My Metrics'),
            Tab(text: 'Fitness Tests'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonLime),
            )
          : TabBarView(
              controller: _tabController,
              children: [_buildMetricsTab(), _buildFitnessTestsTab()],
            ),
    );
  }

  // ===============================================================
  // TAB 1: MY METRICS
  // ===============================================================
  Widget _buildMetricsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildBodyMeasurementsCard(),
        const SizedBox(height: 16),
        _buildCircumferencesCard(),
        const SizedBox(height: 16),
        _buildVitalSignsCard(),
        const SizedBox(height: 16),
        _buildHealthBackgroundCard(),
        const SizedBox(height: 16),
        _buildFitnessGoalCard(),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonLime,
            foregroundColor: AppColors.backgroundBlack,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveMetrics,
          child: Text(
            'Save Profile',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.backgroundBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildTrendCharts(),
      ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    Color borderColor = AppColors.neonLime,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isNumeric = true,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          labelStyle: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBodyMeasurementsCard() {
    Color bmiColor = AppColors.gray400;
    if (_bmi != null) {
      if (_bmi! < 18.5) {
        bmiColor = AppColors.neonOrange;
      } else if (_bmi! >= 18.5 && _bmi! < 25) {
        bmiColor = AppColors.neonLime;
      } else if (_bmi! >= 25 && _bmi! < 30) {
        bmiColor = AppColors.neonTeal;
      } else {
        bmiColor = AppColors.error;
      }
    }

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Body Measurements', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Weight (kg)', _weightCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Height (cm)', _heightCtrl)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField('Body Fat %', _bodyFatCtrl)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: bmiColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BMI:',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray400,
                        ),
                      ),
                      Text(
                        _bmi != null ? _bmi!.toStringAsFixed(1) : '-',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: bmiColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircumferencesCard() {
    return _buildGlassCard(
      borderColor: AppColors.neonTeal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Body Circumferences', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField('Waist (cm)', _waistCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Chest (cm)', _chestCtrl)),
            ],
          ),
          Row(
            children: [
              Expanded(child: _buildTextField('Arms (cm)', _armsCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField('Hips (cm)', _hipsCtrl)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsCard() {
    Color bpColor = AppColors.neonLime;
    bool isWarning = false;
    bool isCrisis = false;
    if (_bpCategory == 'Normal') {
      bpColor = AppColors.neonLime;
    } else if (_bpCategory == 'Elevated') {
      bpColor = AppColors.neonTeal;
    } else if (_bpCategory == 'Stage 1 Hypertension') {
      bpColor = AppColors.neonOrange;
    } else if (_bpCategory == 'Hypertensive Crisis') {
      bpColor = AppColors.error;
      isWarning = true;
      isCrisis = true;
    } else {
      bpColor = AppColors.error;
      isWarning = true;
    }

    return Column(
      children: [
        _buildGlassCard(
          borderColor: AppColors.error,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vital Signs', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Systolic BP', _bpSysCtrl)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Text('/'),
                  ),
                  Expanded(child: _buildTextField('Diastolic BP', _bpDiaCtrl)),
                ],
              ),
              _buildTextField('Resting Heart Rate (bpm)', _hrCtrl),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: bpColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: bpColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monitor_heart_rounded, color: bpColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _bpCategory,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: bpColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate(target: isCrisis ? 1 : 0).shimmer(duration: 1000.ms),
            ],
          ),
        ),
        if (isWarning)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "⚠️ Your blood pressure reading is in the high range. Please consult a doctor before starting any intense exercise. We've noted this in your fitness profile.",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
      ],
    );
  }

  Widget _buildHealthBackgroundCard() {
    return _buildGlassCard(
      borderColor: AppColors.neonOrange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health Background', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          // Blood Group
          DropdownButtonFormField<String>(
            initialValue: _bloodGroup,
            dropdownColor: AppColors.surfaceDark,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Blood Group',
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppColors.gray400,
              ),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                .toList(),
            onChanged: (v) => setState(() => _bloodGroup = v),
          ),
          const SizedBox(height: 16),
          // Dietary Preference
          Text(
            'Dietary Preference',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['vegetarian', 'non_vegetarian', 'vegan', 'eggetarian']
                .map((diet) {
                  final isSel = _dietaryPreference == diet;
                  return ChoiceChip(
                    label: Text(
                      diet.replaceAll('_', ' ').toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: isSel
                            ? AppColors.backgroundBlack
                            : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.neonLime,
                    backgroundColor: AppColors.surfaceDark,
                    onSelected: (sel) {
                      if (sel) {
                        setState(() => _dietaryPreference = diet);
                      }
                    },
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 16),
          // Medical Conditions
          Text(
            'Medical Conditions',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                [
                  'Hypertension',
                  'Diabetes',
                  'Asthma',
                  'Heart Condition',
                  'Joint Issues',
                  'Other',
                  'None',
                ].map((cond) {
                  final isSel = _medicalConditions.contains(cond);
                  return FilterChip(
                    label: Text(
                      cond,
                      style: AppTextStyles.caption.copyWith(
                        color: isSel
                            ? AppColors.backgroundBlack
                            : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.neonOrange,
                    backgroundColor: AppColors.surfaceDark,
                    onSelected: (sel) {
                      setState(() {
                        if (cond == 'None') {
                          _medicalConditions = ['None'];
                        } else {
                          _medicalConditions.remove('None');
                          if (sel) {
                            _medicalConditions.add(cond);
                          } else {
                            _medicalConditions.remove(cond);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          // Joint Restrictions
          Text(
            'Joint Restrictions',
            style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                [
                  'None',
                  'Lower Back',
                  'Left Knee',
                  'Right Knee',
                  'Left Shoulder',
                  'Right Shoulder',
                  'Left Ankle',
                  'Right Ankle',
                ].map((rest) {
                  final isSel = _jointRestrictions.contains(rest);
                  return FilterChip(
                    label: Text(
                      rest,
                      style: AppTextStyles.caption.copyWith(
                        color: isSel
                            ? AppColors.backgroundBlack
                            : AppColors.textPrimary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.neonTeal,
                    backgroundColor: AppColors.surfaceDark,
                    onSelected: (sel) {
                      setState(() {
                        if (rest == 'None') {
                          _jointRestrictions = ['None'];
                        } else {
                          _jointRestrictions.remove('None');
                          if (sel) {
                            _jointRestrictions.add(rest);
                          } else {
                            _jointRestrictions.remove(rest);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalCard() {
    final goals = [
      {'val': 'weight_loss', 'icon': '🎯', 'label': 'Weight Loss'},
      {'val': 'muscle_gain', 'icon': '💪', 'label': 'Muscle Gain'},
      {'val': 'strength', 'icon': '🏋️', 'label': 'Strength'},
      {'val': 'endurance', 'icon': '🏃', 'label': 'Endurance'},
      {
        'val': 'body_recomposition',
        'icon': '⚖️',
        'label': 'Body Recomposition',
      },
      {'val': 'general_fitness', 'icon': '🌿', 'label': 'General Fitness'},
      {
        'val': 'athletic_performance',
        'icon': '⚡',
        'label': 'Athletic Performance',
      },
      {'val': 'flexibility', 'icon': '🧘', 'label': 'Flexibility'},
      {'val': 'stress_relief', 'icon': '😌', 'label': 'Stress Relief'},
      {
        'val': 'health_maintenance',
        'icon': '❤️',
        'label': 'Health Maintenance',
      },
    ];

    return _buildGlassCard(
      borderColor: AppColors.turquoise,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fitness Goal', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final g = goals[index];
              final isSel = _fitnessGoal == g['val'];
              return InkWell(
                onTap: () => setState(() => _fitnessGoal = g['val']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.neonLime.withValues(alpha: 0.2)
                        : AppColors.surfaceDark,
                    border: Border.all(
                      color: isSel ? AppColors.neonLime : AppColors.gray600,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(g['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          g['label']!,
                          style: AppTextStyles.caption.copyWith(
                            color: isSel
                                ? AppColors.neonLime
                                : AppColors.textPrimary,
                            fontWeight: isSel
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts() {
    if (_logs.length < 3) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Log your metrics regularly to see your progress trends",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final sortedLogs = List<BodyMetricsLogModel>.from(_logs)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    final recentLogs = sortedLogs.length > 8
        ? sortedLogs.sublist(sortedLogs.length - 8)
        : sortedLogs;

    List<FlSpot> weightSpots = [];
    List<FlSpot> bpSysSpots = [];
    List<FlSpot> bfSpots = [];

    for (int i = 0; i < recentLogs.length; i++) {
      final log = recentLogs[i];
      if (log.weightKg != null)
        weightSpots.add(FlSpot(i.toDouble(), log.weightKg!));
      if (log.bpSystolic != null)
        bpSysSpots.add(FlSpot(i.toDouble(), log.bpSystolic!.toDouble()));
      if (log.bodyFatPct != null)
        bfSpots.add(FlSpot(i.toDouble(), log.bodyFatPct!));
    }

    Widget buildChart(String title, List<FlSpot> spots, Color color) {
      if (spots.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyLarge),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Trends', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          buildChart('Weight (kg)', weightSpots, AppColors.neonLime),
          buildChart('Systolic BP', bpSysSpots, AppColors.neonOrange),
          buildChart('Body Fat %', bfSpots, AppColors.neonTeal),
        ],
      ),
    );
  }

  Widget _buildPastResultRow(String label, num? pastVal, num? currentVal) {
    if (pastVal == null) return const SizedBox.shrink();

    Widget deltaWidget = const SizedBox.shrink();
    if (currentVal != null) {
      final diff = currentVal - pastVal;
      if (diff > 0) {
        deltaWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_drop_up_rounded,
              color: AppColors.neonLime,
              size: 20,
            ),
            Text(
              '+${diff.toStringAsFixed(diff is int ? 0 : 1)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.neonLime),
            ),
          ],
        );
      } else if (diff < 0) {
        deltaWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.error,
              size: 20,
            ),
            Text(
              diff.toStringAsFixed(diff is int ? 0 : 1),
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],
        );
      } else {
        deltaWidget = Text(
          ' -',
          style: AppTextStyles.caption.copyWith(color: AppColors.gray400),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          Row(
            children: [
              Text(
                pastVal.toStringAsFixed(pastVal is int ? 0 : 1),
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: deltaWidget,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TAB 2: FITNESS TESTS
  // ===============================================================
  Widget _buildFitnessTestsTab() {
    Color levelColor = AppColors.neonOrange;
    if (_overallLevel == 'intermediate') levelColor = AppColors.neonTeal;
    if (_overallLevel == 'advanced') levelColor = AppColors.neonLime;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGlassCard(
          child: Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                color: AppColors.neonLime,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  "Test your current fitness level. Results help your AI coach calibrate your workout intensity and exercise selection.",
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_latestTest != null)
          _buildGlassCard(
            borderColor: AppColors.turquoise,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Last Test Results', style: AppTextStyles.heading3),
                    Text(
                      DateFormat('dd MMM yyyy').format(_latestTest!.testedAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Level: ${_latestTest!.overallLevel?.toUpperCase()}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.turquoise,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPastResultRow(
                  'Max Pushups',
                  _latestTest!.pushupsMax,
                  int.tryParse(_pushupsCtrl.text),
                ),
                _buildPastResultRow(
                  'Max Pullups',
                  _latestTest!.pullupsMax,
                  int.tryParse(_pullupsCtrl.text),
                ),
                _buildPastResultRow(
                  'Max Squats (60s)',
                  _latestTest!.squatsMax,
                  int.tryParse(_squatsCtrl.text),
                ),
                _buildPastResultRow(
                  'Plank Hold (sec)',
                  _latestTest!.plankSeconds,
                  double.tryParse(_plankCtrl.text),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New Test Entry', style: AppTextStyles.heading3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: levelColor),
                    ),
                    child: Text(
                      _overallLevel.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Max Pushups', _pushupsCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField('Max Pullups', _pullupsCtrl)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Max Squats (60s)', _squatsCtrl),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField('Plank Hold (sec)', _plankCtrl),
                  ),
                ],
              ),
              const Divider(color: AppColors.gray600, height: 32),
              Text('Estimated 1RM (Optional)', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              _buildTextField(
                'Squat (kg)',
                _squat1rmCtrl,
                helperText: 'Your estimated 1-rep max for squat',
              ),
              _buildTextField('Deadlift (kg)', _deadlift1rmCtrl),
              _buildTextField('Bench Press (kg)', _benchpress1rmCtrl),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonLime,
            foregroundColor: AppColors.backgroundBlack,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _saveFitnessTest,
          child: Text(
            'Save Test Results',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.backgroundBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ].animate(interval: 50.ms).fadeIn().slideY(begin: 0.1),
    );
  }
}
