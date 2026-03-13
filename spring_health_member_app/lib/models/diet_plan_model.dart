import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════
// MEAL ITEM
// ══════════════════════════════════════════════════════════════

class MealItem {
  final String mealType; // Breakfast | Lunch | Dinner | Pre-Workout | Post-Workout | Snack
  final String time;
  final List<String> foods;  // ✅ FIX 1: typed List<String>
  final int calories;
  final String? protein;
  final String? carbs;
  final String? fats;
  final String? notes;

  const MealItem({
    required this.mealType,
    required this.time,
    required this.foods,
    required this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.notes,
  });

  // ✅ FIX 3: fully typed Map<String, dynamic>
  factory MealItem.fromMap(Map<String, dynamic> map) => MealItem(
    mealType:  map['mealType']  as String? ?? '',
    time:      map['time']      as String? ?? '',
    // ✅ FIX 1: safe cast — Firestore list items become String
    foods:     (map['foods'] as List<dynamic>? ?? [])
    .map((f) => f.toString())
    .toList(),
    calories:  (map['calories'] as num?)?.toInt() ?? 0,
    protein:   map['protein']  as String?,
    carbs:     map['carbs']    as String?,
    fats:      map['fats']     as String?,
    notes:     map['notes']    as String?,
  );

  Map<String, dynamic> toMap() => {   // ✅ FIX 3: typed return
    'mealType': mealType,
    'time':     time,
    'foods':    foods,
    'calories': calories,
    if (protein != null) 'protein': protein,
      if (carbs   != null) 'carbs':   carbs,
        if (fats    != null) 'fats':    fats,
          if (notes   != null) 'notes':   notes,
  };

    // ✅ FIX 12: copyWith for admin form editing
    MealItem copyWith({
      String?       mealType,
      String?       time,
      List<String>? foods,
      int?          calories,
      String?       protein,
      String?       carbs,
      String?       fats,
      String?       notes,
    }) =>
    MealItem(
      mealType: mealType ?? this.mealType,
      time:     time     ?? this.time,
      foods:    foods    ?? this.foods,
      calories: calories ?? this.calories,
      protein:  protein  ?? this.protein,
      carbs:    carbs    ?? this.carbs,
      fats:     fats     ?? this.fats,
      notes:    notes    ?? this.notes,
    );

    // ✅ FIX 11: computed calories getter for validation
    // (calories field is still manual — this is just a helper label)
    String get macroSummary {
      final parts = <String>[];
      if (protein != null) parts.add('P: $protein');
      if (carbs   != null) parts.add('C: $carbs');
      if (fats    != null) parts.add('F: $fats');
      return parts.isEmpty ? '$calories kcal' : '${parts.join(' · ')} · $calories kcal';
    }

    // ✅ FIX 13
    @override
    bool operator ==(Object other) =>
    identical(this, other) ||
    other is MealItem &&
    other.mealType == mealType &&
    other.time     == time     &&
    other.calories == calories;

    @override
    int get hashCode => Object.hash(mealType, time, calories);

    @override
    String toString() =>
    'MealItem(mealType: $mealType, time: $time, calories: $calories)';
}

// ══════════════════════════════════════════════════════════════
// DIET PLAN GOAL — type-safe enum
// ══════════════════════════════════════════════════════════════

enum DietGoal {
  weightLoss   ('Weight Loss'),
  muscleGain   ('Muscle Gain'),
  bulking      ('Bulking'),
  cutting      ('Cutting'),
  maintenance  ('Maintenance');

  const DietGoal(this.label);
  final String label;

  static DietGoal fromString(String? value) {
    return DietGoal.values.firstWhere(
      (g) => g.label == value || g.name == value,
      orElse: () => DietGoal.maintenance,
    );
  }
}

// ══════════════════════════════════════════════════════════════
// DIET PLAN MODEL
// ══════════════════════════════════════════════════════════════

class DietPlanModel {
  // ✅ FIX 4: id field — required for update/delete from admin
  final String id;

  // ✅ FIX 5: title — shows in admin plan list
  final String title;

  // ✅ FIX 9: nullable memberId — null means it's a template
  final String? memberId;

  final String trainerId;
  final String trainerName;

  // ✅ FIX 6: branch — admin app is multi-branch
  final String branch;

  final DateTime assignedAt;
  final DateTime? updatedAt;

  // ✅ FIX 10: isTemplate — distinguishes reusable templates from personal plans
  final bool isTemplate;

  // ✅ using DietGoal enum now
  final DietGoal goal;

  final int totalCalories;

  // ✅ FIX 2: typed List<MealItem>
  final List<MealItem> meals;

  final String? notes;
  final bool isActive;

  const DietPlanModel({
    required this.id,
    required this.title,
    this.memberId,
    required this.trainerId,
    required this.trainerName,
    required this.branch,
    required this.assignedAt,
    this.updatedAt,
    this.isTemplate = false,
    required this.goal,
    required this.totalCalories,
    required this.meals,
    this.notes,
    this.isActive = true,
  });

  // ✅ FIX 7: proper DocumentSnapshot factory
  factory DietPlanModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? {};
    return DietPlanModel(
      id:           doc.id,                                        // ✅ FIX 4
      title:        map['title']        as String? ?? 'Diet Plan', // ✅ FIX 5
      memberId:     map['memberId']     as String?,                // ✅ FIX 9
      trainerId:    map['trainerId']    as String? ?? '',
      trainerName:  map['trainerName']  as String? ?? '',
      branch:       map['branch']       as String? ?? '',          // ✅ FIX 6
      assignedAt:   (map['assignedAt']  as Timestamp?)?.toDate()  ?? DateTime.now(),
      updatedAt:    (map['updatedAt']   as Timestamp?)?.toDate(),
      isTemplate:   map['isTemplate']   as bool? ?? false,         // ✅ FIX 10
      goal:         DietGoal.fromString(map['goal'] as String?),
      totalCalories: (map['totalCalories'] as num?)?.toInt() ?? 0,
      // ✅ FIX 8: safe cast with null guard
      meals: (map['meals'] as List<dynamic>? ?? [])
      .whereType<Map<String, dynamic>>()
      .map(MealItem.fromMap)
      .toList(),
      notes:    map['notes']    as String?,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  // ✅ FIX 3: typed Map<String, dynamic>
  Map<String, dynamic> toMap() => {
    'title':          title,
    if (memberId != null) 'memberId': memberId,
      'trainerId':      trainerId,
      'trainerName':    trainerName,
      'branch':         branch,
      'assignedAt':     Timestamp.fromDate(assignedAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
        'isTemplate':     isTemplate,
        'goal':           goal.label,
        'totalCalories':  totalCalories,
        'meals':          meals.map((m) => m.toMap()).toList(),
        if (notes != null) 'notes': notes,
          'isActive':       isActive,
  };

  // ✅ FIX 11: computed total from meals (for validation in admin form)
  int get computedCalories =>
  meals.fold(0, (total, m) => total + m.calories);

  bool get calorieMismatch => computedCalories != totalCalories;

  // ✅ FIX 12: copyWith — needed for admin edit screen
  DietPlanModel copyWith({
    String?         id,
    String?         title,
    Object?         memberId   = _sentinel,
    String?         trainerId,
    String?         trainerName,
    String?         branch,
    DateTime?       assignedAt,
    Object?         updatedAt  = _sentinel,
    bool?           isTemplate,
    DietGoal?       goal,
    int?            totalCalories,
    List<MealItem>? meals,
    Object?         notes      = _sentinel,
    bool?           isActive,
  }) =>
  DietPlanModel(
    id:            id           ?? this.id,
    title:         title        ?? this.title,
    memberId:      memberId     == _sentinel ? this.memberId    : memberId    as String?,
    trainerId:     trainerId    ?? this.trainerId,
    trainerName:   trainerName  ?? this.trainerName,
    branch:        branch       ?? this.branch,
    assignedAt:    assignedAt   ?? this.assignedAt,
    updatedAt:     updatedAt    == _sentinel ? this.updatedAt   : updatedAt   as DateTime?,
    isTemplate:    isTemplate   ?? this.isTemplate,
    goal:          goal         ?? this.goal,
    totalCalories: totalCalories ?? this.totalCalories,
    meals:         meals        ?? this.meals,
    notes:         notes        == _sentinel ? this.notes      : notes        as String?,
    isActive:      isActive     ?? this.isActive,
  );

  // ✅ FIX 13
  @override
  bool operator ==(Object other) =>
  identical(this, other) ||
  other is DietPlanModel &&
  other.id       == id       &&
  other.memberId == memberId &&
  other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, memberId, isActive);

  @override
  String toString() =>
  'DietPlanModel(id: $id, title: $title, memberId: $memberId, '
  'goal: ${goal.label}, meals: ${meals.length}, '
  'calories: $totalCalories, isTemplate: $isTemplate)';
}

// Sentinel for nullable copyWith fields
const Object _sentinel = Object();
