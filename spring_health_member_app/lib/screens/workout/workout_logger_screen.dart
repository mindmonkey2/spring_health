import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/workout_model.dart';
import '../../models/gamification_model.dart';
import '../../services/workout_service.dart';
import '../../services/gamification_service.dart';
import '../../services/weekly_war_service.dart';
import '../../services/member_service.dart';
import '../../widgets/rpe_rating_sheet.dart';

class WorkoutLoggerScreen extends StatefulWidget {
  final String memberId;
  final String? initialExercise;
  final List<Map<String, dynamic>>? preloadedExercises;

  const WorkoutLoggerScreen({
    super.key,
    required this.memberId,
    this.initialExercise,
    this.preloadedExercises,
  });

  @override
  State<WorkoutLoggerScreen> createState() => // ✅ FIX: generic
      _WorkoutLoggerScreenState();
}

class _WorkoutLoggerScreenState extends State<WorkoutLoggerScreen>
    with SingleTickerProviderStateMixin {
  // ✅ for live timer
  final _workoutService = WorkoutService();
  final _gamService = GamificationService();
  final _weeklyWarService = WeeklyWarService.instance;
  final _memberService = MemberService();
  final _uuid = const Uuid();

  final _titleController = TextEditingController(text: 'Morning Workout');
  final _notesController = TextEditingController();
  final List<WorkoutExercise> _exercises = [];
  final DateTime _startTime = DateTime.now();

  bool _isSaving = false;
  bool _showNotes = false; // ✅ toggle notes section

  // ✅ FIX: Per-set controllers keyed by exerciseId+setIndex to avoid cursor jump
  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};

  // ✅ Live timer
  late final Stream<int> _timerStream;

  final Map<String, List<String>> _exerciseLibrary = {
    'Chest': [
      'Bench Press',
      'Incline Bench Press',
      'Decline Bench Press',
      'Push Ups',
      'Cable Flyes',
      'Dumbbell Flyes',
      'Chest Dips',
    ],
    'Back': [
      'Pull Ups',
      'Lat Pulldown',
      'Seated Cable Row',
      'Bent Over Row',
      'Deadlift',
      'T-Bar Row',
      'Single Arm Row',
    ],
    'Legs': [
      'Squats',
      'Leg Press',
      'Romanian Deadlift',
      'Leg Curl',
      'Leg Extension',
      'Calf Raises',
      'Lunges',
      'Hack Squat',
    ],
    'Shoulders': [
      'Overhead Press',
      'Lateral Raises',
      'Front Raises',
      'Rear Delt Flyes',
      'Arnold Press',
      'Upright Row',
      'Shrugs',
    ],
    'Arms': [
      'Barbell Curl',
      'Dumbbell Curl',
      'Hammer Curl',
      'Preacher Curl',
      'Tricep Pushdown',
      'Skull Crushers',
      'Dips',
      'Close Grip Bench',
    ],
    'Core': [
      'Plank',
      'Crunches',
      'Leg Raises',
      'Russian Twists',
      'Ab Wheel',
      'Cable Crunch',
      'Side Plank',
      'Mountain Climbers',
    ],
    'Cardio': [
      'Treadmill',
      'Cycling',
      'Jump Rope',
      'Rowing Machine',
      'Stair Climber',
      'Elliptical',
      'HIIT Sprints',
    ],
  };

  @override
  void initState() {
    super.initState();
    // ✅ Timer ticks every second — keeps stats bar live
    _timerStream = Stream.periodic(const Duration(seconds: 1), (tick) => tick);
    if (widget.initialExercise != null) {
      _exercises.add(
        WorkoutExercise(
          id: _uuid.v4(),
          name: widget.initialExercise!,
          category: 'War',
          sets: [ExerciseSet(setNumber: 1, weight: 0, reps: 0)],
        ),
      );
    } else if (widget.preloadedExercises != null &&
        widget.preloadedExercises!.isNotEmpty) {
      for (final exMap in widget.preloadedExercises!) {
        final name = exMap['name'] as String? ?? 'Exercise';
        final setsCount = exMap['sets'] as int? ?? 1;
        final targetRepsStr = exMap['reps'] as String? ?? '0';
        int targetReps = 0;
        final parts = targetRepsStr.split('-');
        if (parts.isNotEmpty) {
          targetReps =
              int.tryParse(parts.last.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        }

        final sets = List.generate(
          setsCount,
          (index) =>
              ExerciseSet(setNumber: index + 1, weight: 0, reps: targetReps),
        );

        _exercises.add(
          WorkoutExercise(
            id: _uuid.v4(),
            name: name,
            category: 'AI Coach',
            sets: sets,
            notes: exMap['coachingCue'] as String?,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    // Dispose all set controllers
    for (final c in _weightControllers.values) {
      c.dispose();
    }
    for (final c in _repsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ─────────────────────────────────────
  // COMPUTED PROPS
  // ─────────────────────────────────────
  int get _durationMinutes => DateTime.now().difference(_startTime).inMinutes;

  int get _totalVolume =>
      _exercises.fold(0, (total, e) => total + e.totalVolume);

  int get _totalSets => _exercises.fold(0, (total, e) => total + e.sets.length);

  // ✅ Estimated calories: ~5 cal/min + 0.05 * volume
  int get _estimatedCalories =>
      (_durationMinutes * 5 + _totalVolume * 0.05).toInt();

  // ✅ Stable controller keys
  String _weightKey(String exerciseId, int setIndex) =>
      '${exerciseId}_w_$setIndex';
  String _repsKey(String exerciseId, int setIndex) =>
      '${exerciseId}_r_$setIndex';

  TextEditingController _getWeightController(
    String exerciseId,
    int setIndex,
    double currentWeight,
  ) {
    final key = _weightKey(exerciseId, setIndex);
    return _weightControllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: currentWeight > 0 ? currentWeight.toString() : '',
      ),
    );
  }

  TextEditingController _getRepsController(
    String exerciseId,
    int setIndex,
    int currentReps,
  ) {
    final key = _repsKey(exerciseId, setIndex);
    return _repsControllers.putIfAbsent(
      key,
      () => TextEditingController(
        text: currentReps > 0 ? currentReps.toString() : '',
      ),
    );
  }

  void _removeSetControllers(String exerciseId, int setIndex) {
    _weightControllers.remove(_weightKey(exerciseId, setIndex))?.dispose();
    _repsControllers.remove(_repsKey(exerciseId, setIndex))?.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _confirmDiscard,
        ),
        title: TextField(
          controller: _titleController,
          style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Workout Name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          // ✅ Notes toggle
          IconButton(
            onPressed: () => setState(() => _showNotes = !_showNotes),
            icon: Icon(
              Icons.notes_rounded,
              color: _showNotes ? AppColors.neonTeal : AppColors.gray400,
            ),
            tooltip: 'Add Notes',
          ),
          TextButton(
            onPressed: _isSaving ? null : _saveWorkout,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.neonLime,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'FINISH',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Live Stats Bar — rebuilds every second
          StreamBuilder<int>(
            stream: _timerStream,
            builder: (context, _) => _buildStatsBar(),
          ),

          // ✅ Notes input — collapsible
          if (_showNotes) _buildNotesSection(),

          // Exercise List
          Expanded(
            child: _exercises.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        _exercises.length +
                        (widget.preloadedExercises != null &&
                                widget.preloadedExercises!.isNotEmpty
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (widget.preloadedExercises != null &&
                          widget.preloadedExercises!.isNotEmpty) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.neonLime.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.neonLime.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.smart_toy_rounded,
                                    color: AppColors.neonLime,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    ' AI Plan loaded — modify as needed',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.neonLime,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return _buildExerciseCard(index - 1);
                      }
                      return _buildExerciseCard(index);
                    },
                  ),
          ),

          _buildBottomActions(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // STATS BAR
  // ─────────────────────────────────────
  Widget _buildStatsBar() {
    final duration = DateTime.now().difference(_startTime);
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    final timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip(
            Icons.timer_rounded,
            timeStr, // ✅ Live MM:SS
            'Time',
            AppColors.neonTeal,
          ),
          _buildStatDivider(),
          _buildStatChip(
            Icons.fitness_center_rounded,
            '$_totalSets',
            'Sets',
            AppColors.neonLime,
          ),
          _buildStatDivider(),
          _buildStatChip(
            Icons.monitor_weight_rounded,
            '${_totalVolume}kg',
            'Volume',
            AppColors.neonOrange,
          ),
          _buildStatDivider(),
          _buildStatChip(
            Icons.local_fire_department_rounded,
            '~$_estimatedCalories', // ✅ Calories estimate
            'Cal',
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 3),
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
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() => Container(
    width: 1,
    height: 36,
    color: Colors.white.withValues(alpha: 0.08),
  );

  // ─────────────────────────────────────
  // NOTES SECTION
  // ─────────────────────────────────────
  Widget _buildNotesSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: AppColors.cardSurface,
      child: TextField(
        controller: _notesController,
        maxLines: 2,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText:
              'Add workout notes (e.g. felt strong today, PR on bench...)',
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.gray600),
          filled: true,
          fillColor: AppColors.backgroundBlack,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12),
          prefixIcon: Icon(
            Icons.notes_rounded,
            color: AppColors.neonTeal,
            size: 18,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.2, end: 0);
  }

  // ─────────────────────────────────────
  // EXERCISE CARD
  // ─────────────────────────────────────
  Widget _buildExerciseCard(int exerciseIndex) {
    final exercise = _exercises[exerciseIndex];
    final categoryColor = _getCategoryColor(exercise.category);

    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: categoryColor.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        exercise.category.toUpperCase(),
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // ✅ Volume badge per exercise
                    if (exercise.totalVolume > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${exercise.totalVolume}kg',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: () => _removeExercise(exerciseIndex),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Sets Table Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTableHeader('SET', 36),
                    _buildTableHeader('KG', 80),
                    _buildTableHeader('REPS', 80),
                    _buildTableHeader('VOL', 80),
                    const SizedBox(width: 28),
                  ],
                ),
              ),
              const Divider(color: Colors.white10, height: 12),

              // Set Rows
              ...List.generate(
                exercise.sets.length,
                (setIndex) => _buildSetRow(exerciseIndex, setIndex),
              ),

              // Add Set
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _addSet(exerciseIndex),
                    icon: Icon(
                      Icons.add_rounded,
                      color: categoryColor,
                      size: 18,
                    ),
                    label: Text(
                      'ADD SET',
                      style: TextStyle(
                        color: categoryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: categoryColor.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (exerciseIndex * 80).ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTableHeader(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.gray600,
          letterSpacing: 1,
          fontSize: 10,
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // SET ROW — stable controllers
  // ─────────────────────────────────────
  Widget _buildSetRow(int exerciseIndex, int setIndex) {
    final exercise = _exercises[exerciseIndex];
    final set = exercise.sets[setIndex];

    // ✅ FIX: stable controllers — no new controller on rebuild
    final weightController = _getWeightController(
      exercise.id,
      setIndex,
      set.weight,
    );
    final repsController = _getRepsController(exercise.id, setIndex, set.reps);

    final volume = (set.weight * set.reps).toInt();
    final isCompleted = set.weight > 0 && set.reps > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Set number with completion indicator
          SizedBox(
            width: 36,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.neonLime.withValues(alpha: 0.15)
                    : AppColors.backgroundBlack,
                borderRadius: BorderRadius.circular(6),
                border: isCompleted
                    ? Border.all(
                        color: AppColors.neonLime.withValues(alpha: 0.4),
                        width: 1,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '${setIndex + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: isCompleted ? AppColors.neonLime : AppColors.gray400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Weight input
          SizedBox(
            width: 80,
            child: _buildNumberInput(weightController, 'kg', (val) {
              final parsed = double.tryParse(val) ?? 0;
              setState(() {
                _exercises[exerciseIndex].sets[setIndex] = ExerciseSet(
                  setNumber: set.setNumber,
                  weight: parsed,
                  reps: set.reps,
                  isCompleted: set.isCompleted,
                );
              });
            }),
          ),

          // Reps input
          SizedBox(
            width: 80,
            child: _buildNumberInput(repsController, 'reps', (val) {
              final parsed = int.tryParse(val) ?? 0;
              setState(() {
                _exercises[exerciseIndex].sets[setIndex] = ExerciseSet(
                  setNumber: set.setNumber,
                  weight: set.weight,
                  reps: parsed,
                  isCompleted: set.isCompleted,
                );
              });
            }, isInt: true),
          ),

          // Volume
          SizedBox(
            width: 80,
            child: Text(
              volume > 0 ? '${volume}kg' : '-',
              style: AppTextStyles.caption.copyWith(
                color: volume > 0 ? AppColors.neonLime : AppColors.gray600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Delete set
          GestureDetector(
            onTap: () => _removeSet(exerciseIndex, setIndex),
            child: Icon(
              Icons.remove_circle_outline_rounded,
              size: 20,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(
    TextEditingController controller,
    String hint,
    ValueChanged<String> onChanged, {
    bool isInt = false,
  }) {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
        inputFormatters: [
          if (isInt)
            FilteringTextInputFormatter.digitsOnly
          else
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.caption.copyWith(color: AppColors.gray600),
          filled: true,
          fillColor: AppColors.backgroundBlack,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // BOTTOM ACTIONS
  // ─────────────────────────────────────
  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _showExercisePicker,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'ADD EXERCISE',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonLime,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // EXERCISE PICKER
  // ─────────────────────────────────────
  void _showExercisePicker() {
    String selectedCategory = 'Chest';
    String searchQuery = '';
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final exercises = (_exerciseLibrary[selectedCategory] ?? [])
              .where((e) => e.toLowerCase().contains(searchQuery.toLowerCase()))
              .toList();

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ADD EXERCISE',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.neonLime,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search exercises...',
                      hintStyle: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.gray400,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category chips
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: _exerciseLibrary.keys.map((cat) {
                      final isSelected = cat == selectedCategory;
                      final color = _getCategoryColor(cat);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setModalState(() => selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withValues(alpha: 0.2)
                                  : AppColors.backgroundBlack,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? color : Colors.white10,
                              ),
                            ),
                            child: Text(
                              cat,
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
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10),

                // Exercise list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final name = exercises[index];
                      final color = _getCategoryColor(selectedCategory);
                      return ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _addExercise(name, selectedCategory);
                        },
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getCategoryIcon(selectedCategory),
                            color: color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          selectedCategory,
                          style: AppTextStyles.caption.copyWith(color: color),
                        ),
                        trailing: Icon(
                          Icons.add_circle_rounded,
                          color: color,
                          size: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────
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
            'No Exercises Yet',
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap ADD EXERCISE to start logging',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
          ),
          const SizedBox(height: 32),
          // ✅ Quick-add chips for common exercises
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['Bench Press', 'Squats', 'Deadlift', 'Pull Ups']
                .map(
                  (name) => GestureDetector(
                    onTap: () {
                      final category = name == 'Squats' || name == 'Deadlift'
                          ? 'Legs'
                          : name == 'Pull Ups'
                          ? 'Back'
                          : 'Chest';
                      _addExercise(name, category);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neonLime.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '+ $name',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neonLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  // ─────────────────────────────────────
  // WORKOUT SUMMARY BOTTOM SHEET
  // ─────────────────────────────────────
  void _showWorkoutSummary(
    WorkoutLog workout,
    List<BadgeDefinition> newBadges,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: AppColors.neonLime,
              size: 56,
            ).animate().scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
              duration: 800.ms,
            ),
            const SizedBox(height: 12),
            Text(
              'WORKOUT COMPLETE! ',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.neonLime,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),

            // Stats summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryChip(
                  '${workout.durationMinutes}m',
                  'Duration',
                  Icons.timer_rounded,
                  AppColors.neonTeal,
                ),
                _buildSummaryChip(
                  '${workout.exercises.length}',
                  'Exercises',
                  Icons.fitness_center_rounded,
                  AppColors.neonLime,
                ),
                _buildSummaryChip(
                  '${workout.totalVolume}kg',
                  'Volume',
                  Icons.monitor_weight_rounded,
                  AppColors.neonOrange,
                ),
                _buildSummaryChip(
                  '$_estimatedCalories',
                  'Cal',
                  Icons.local_fire_department_rounded,
                  Colors.redAccent,
                ),
              ],
            ),

            // ✅ XP earned
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.neonLime.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonLime.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: AppColors.neonLime, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+${XpSource.workoutLogged} XP Earned!',
                    style: TextStyle(
                      color: AppColors.neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // ✅ New badges
            if (newBadges.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                ' NEW BADGE${newBadges.length > 1 ? 'S' : ''} UNLOCKED!',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.amber,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: newBadges
                    .take(3)
                    .map(
                      (b) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: b.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: b.color, width: 1.5),
                        ),
                        child: Icon(b.icon, color: b.color, size: 22),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close summary
                  Navigator.pop(context, true); // return to caller
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'DONE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
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
  // LOGIC METHODS
  // ─────────────────────────────────────
  void _addExercise(String name, String category) {
    setState(() {
      _exercises.add(
        WorkoutExercise(
          id: _uuid.v4(),
          name: name,
          category: category,
          sets: [ExerciseSet(setNumber: 1, weight: 0, reps: 0)],
        ),
      );
    });
    HapticFeedback.lightImpact();
  }

  void _removeExercise(int index) {
    // Clean up controllers for this exercise
    final exerciseId = _exercises[index].id;
    final setCount = _exercises[index].sets.length;
    for (var i = 0; i < setCount; i++) {
      _removeSetControllers(exerciseId, i);
    }
    setState(() => _exercises.removeAt(index));
    HapticFeedback.lightImpact();
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final sets = _exercises[exerciseIndex].sets;
      final lastSet = sets.isNotEmpty ? sets.last : null;
      sets.add(
        ExerciseSet(
          setNumber: sets.length + 1,
          weight: lastSet?.weight ?? 0,
          reps: lastSet?.reps ?? 0,
        ),
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    if (_exercises[exerciseIndex].sets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 1 set required. Delete exercise instead.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final exerciseId = _exercises[exerciseIndex].id;
    _removeSetControllers(exerciseId, setIndex);
    setState(() => _exercises[exerciseIndex].sets.removeAt(setIndex));
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one exercise before finishing!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final workout = WorkoutLog(
      id: '',
      memberId: widget.memberId,
      title: _titleController.text.trim().isEmpty
          ? 'Workout ${DateFormat('dd MMM').format(DateTime.now())}'
          : _titleController.text.trim(),
      date: _startTime,
      durationMinutes: _durationMinutes,
      exercises: _exercises,
      notes: _notesController.text.trim(),
      totalVolume: _totalVolume,
      totalSets: _totalSets,
      caloriesBurned: _estimatedCalories, // ✅ calories now set
    );

    try {
      final savedDocRef = await _workoutService.saveWorkout(workout);

      // ✅ Record to Weekly War
      final member = await _memberService.getMemberData(widget.memberId);
      if (member != null) {
        final Map<String, int> exerciseReps = {};
        for (final ex in workout.exercises) {
          int totalReps = 0;
          for (final set in ex.sets) {
            if (set.isCompleted) totalReps += set.reps;
          }
          if (totalReps > 0) {
            exerciseReps.update(
              ex.name,
              (existing) => existing + totalReps,
              ifAbsent: () => totalReps,
            );
          }
        }
        if (exerciseReps.isNotEmpty) {
          await _weeklyWarService.recordWorkoutEntries(
            widget.memberId,
            member.branch,
            exerciseReps,
          );
        }
      }

      // ✅ Award XP + check badges
      final badges = await _gamService.awardXp(
        widget.memberId,
        'Workout Logged: ${workout.title}',
        XpSource.workoutLogged,
        isWorkout: true,
        workoutVolumeKg: _totalVolume,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      final sessionId = savedDocRef.id; // capture the saved doc ID
      final selectedMuscleGroups = workout.exercises
          .map((e) => e.category)
          .toSet()
          .toList();
      if (mounted) {
        await showModalBottomSheet(
          context: context,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (_) => RpeRatingSheet(
            sessionId: sessionId,
            muscleGroups: selectedMuscleGroups,
          ),
        );
      }

      // ✅ Show summary instead of just popping
      _showWorkoutSummary(workout, badges);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmDiscard() {
    if (_exercises.isEmpty) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
        ),
        title: Text('Discard Workout?', style: AppTextStyles.heading3),
        content: Text(
          'All logged exercises will be lost.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('KEEP', style: TextStyle(color: AppColors.neonLime)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('DISCARD'),
          ),
        ],
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
