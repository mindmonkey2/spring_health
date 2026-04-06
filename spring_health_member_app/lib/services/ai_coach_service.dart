import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import '../services/wearable_snapshot_service.dart';
import '../services/health_profile_service.dart';
import '../services/member_service.dart';
import '../models/health_profile_model.dart'; // need to import for static methods if any
import 'rpe_service.dart';

class AiCoachService {
  final FirebaseFirestore _db;
  late final GenerativeModel _model;

  AiCoachService._internal({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash-preview-04-17',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4,
        maxOutputTokens: 3000,
      ),
    );
  }

  static final AiCoachService instance = AiCoachService._internal();

  factory AiCoachService({FirebaseFirestore? db}) {
    return AiCoachService._internal(db: db);
  }

  Future<Map<String, dynamic>> _buildMemberContext(String memberId) async {
    final context = <String, dynamic>{};

    // 1. HealthProfile
    final profileService = HealthProfileService(db: _db);
    final healthProfile = await profileService.getHealthProfile(memberId);
    if (healthProfile != null) {
      // NOTE: HealthProfileModel in this project does not have 'age' and 'gender'.
      // We will default to 'Unknown' in context for Gemini, since they are omitted from the model.
      context['age'] = 'Unknown';
      context['gender'] = 'Unknown';
      context['heightCm'] = healthProfile.heightCm;
      context['weightKg'] = healthProfile.weightKg;
      context['bmi'] = healthProfile.bmi;
      context['fitnessGoal'] = healthProfile.fitnessGoal;
      context['fitnessLevel'] = healthProfile.fitnessLevel;
      context['jointRestrictions'] = healthProfile.jointRestrictions;
      context['medicalConditions'] = healthProfile.medicalConditions;
      context['dietaryPreference'] = healthProfile.dietaryPreference;

      String bpCategory = 'Unknown';
      if (healthProfile.bpSystolic != null &&
          healthProfile.bpDiastolic != null) {
        bpCategory = HealthProfileModel.bpCategory(
          healthProfile.bpSystolic!,
          healthProfile.bpDiastolic!,
        );
      }

      context['health'] = {
        'bpSystolic': healthProfile.bpSystolic,
        'bpDiastolic': healthProfile.bpDiastolic,
        'bpCategory': bpCategory,
        'bloodGroup': healthProfile.bloodGroup,
      };
    }

    // 2. FitnessTests
    final testsSnapshot = await _db
        .collection('fitnessTests')
        .doc(memberId)
        .collection('tests')
        .orderBy('testedAt', descending: true)
        .limit(1)
        .get();

    if (testsSnapshot.docs.isNotEmpty) {
      final latestTest = testsSnapshot.docs.first.data();
      context['fitnessTests'] = {
        'pushupsMax': latestTest['pushupsMax'],
        'pullupsMax': latestTest['pullupsMax'],
        'plankSeconds': latestTest['plankSeconds'],
        'squat1rmKg': latestTest['squat1rmKg'],
        'deadlift1rmKg': latestTest['deadlift1rmKg'],
        'benchpress1rmKg': latestTest['benchpress1rmKg'],
        'overallLevel': latestTest['overallLevel'],
        'testedAt': latestTest['testedAt'],
      };
    }

    // 3. Wearables
    final wearableService = WearableSnapshotService(db: _db);
    final snapshots = await wearableService.getLatestSnapshots(
      memberId,
      days: 7,
    );

    if (snapshots.isNotEmpty) {
      final today = snapshots.first;

      double sumSteps = 0;
      double sumSleep = 0;
      double sumDeepSleep = 0;
      double sumRHR = 0;
      int rhrCount = 0;
      double sumHRV = 0;
      int hrvCount = 0;

      for (final s in snapshots) {
        sumSteps += s.steps;
        sumSleep += s.totalSleepMinutes;
        sumDeepSleep += s.deepSleepMinutes;
        if (s.restingHeartRate != null) {
          sumRHR += s.restingHeartRate!;
          rhrCount++;
        }
        if (s.heartRateVariability != null) {
          sumHRV += s.heartRateVariability!;
          hrvCount++;
        }
      }

      int days = snapshots.length;

      String hrvTrend = 'stable';
      if (snapshots.length >= 2 &&
          snapshots.first.heartRateVariability != null &&
          snapshots.last.heartRateVariability != null) {
        final first = snapshots.first.heartRateVariability!;
        final last = snapshots.last.heartRateVariability!;
        if (first < last - 5) {
          hrvTrend = 'declining';
        } else if (first > last + 5) {
          hrvTrend = 'improving';
        }
      }

      String weightTrend = 'stable';
      if (snapshots.length >= 2 &&
          snapshots.first.weightKg != null &&
          snapshots.last.weightKg != null) {
        final first = snapshots.first.weightKg!;
        final last = snapshots.last.weightKg!;
        if (first < last - 0.5) {
          weightTrend = 'losing';
        } else if (first > last + 0.5) {
          weightTrend = 'gaining';
        }
      }

      context['wearables'] = {
        'today': today.toMap(),
        'sevenDayAvgSteps': (sumSteps / days).round(),
        'sevenDayAvgSleepMinutes': (sumSleep / days).round(),
        'sevenDayAvgDeepSleepMinutes': (sumDeepSleep / days).round(),
        'sevenDayAvgRHR': rhrCount > 0 ? (sumRHR / rhrCount).round() : null,
        'sevenDayAvgHRV': hrvCount > 0 ? (sumHRV / hrvCount).round() : null,
        'todayRecoveryStatus': today.recoveryStatus,
        'todaySleepQuality': today.sleepQuality,
        'hrvTrend': hrvTrend,
        'weightTrend': weightTrend,
      };
    } else {
      context['wearables'] = null;
    }

    // 4. Member
    final memberService = MemberService();
    final member = await memberService.getMemberData(memberId);
    if (member != null) {
      context['branchName'] = member.branch;
      context['plan'] = member.plan;
      context['joiningDate'] = member.startDate.toString();
    }

    return context;
  }

  void _checkSafetyGate(Map<String, dynamic> context) {
    if (context['health'] == null) return;
    final bpSystolic = context['health']['bpSystolic'] as num?;
    final bpDiastolic = context['health']['bpDiastolic'] as num?;

    if (bpSystolic != null && bpDiastolic != null) {
      if (bpSystolic > 180 || bpDiastolic > 120) {
        throw Exception('medical_hold_bp_crisis');
      }
    }

    if (context['wearables'] != null && context['wearables']['today'] != null) {
      final today = context['wearables']['today'];
      final irregularHeartRateEvent =
          today['irregularHeartRateEvent'] as bool? ?? false;
      final bodyTemperature = today['bodyTemperature'] as num?;

      if (irregularHeartRateEvent) {
        throw Exception('medical_hold_cardiac_event');
      }

      if (bodyTemperature != null && bodyTemperature > 37.5) {
        throw Exception('medical_hold_fever');
      }
    }
  }

  String _buildWorkoutPrompt(Map<String, dynamic> context) {
    final age = context['age'] ?? 'Unknown';
    final gender = context['gender'] ?? 'Unknown';
    final heightCm = context['heightCm'] ?? 'Unknown';
    final weightKg = context['weightKg'] ?? 'Unknown';
    final bmi = context['bmi'] ?? 'Unknown';
    final branchName = context['branchName'] ?? 'Unknown';
    final joiningDate = context['joiningDate'] ?? 'Unknown';

    final fitnessGoal = context['fitnessGoal'] ?? 'General Fitness';
    final fitnessLevel = context['fitnessLevel'] ?? 'Beginner';

    final tests = context['fitnessTests'] ?? {};
    final pushupsMax = tests['pushupsMax'] ?? 'Unknown';
    final pullupsMax = tests['pullupsMax'] ?? 'Unknown';
    final plankSeconds = tests['plankSeconds'] ?? 'Unknown';
    final squat1rmKg = tests['squat1rmKg'] ?? 'Unknown';
    final deadlift1rmKg = tests['deadlift1rmKg'] ?? 'Unknown';
    final benchpress1rmKg = tests['benchpress1rmKg'] ?? 'Unknown';

    final wearables = context['wearables'] ?? {};
    final today = wearables['today'] ?? {};
    final recoveryStatus = wearables['todayRecoveryStatus'] ?? 'Unknown';
    final totalSleepMinutes = today['totalSleepMinutes'] ?? 0;
    final deepSleepMinutes = today['deepSleepMinutes'] ?? 0;
    final remSleepMinutes = today['remSleepMinutes'] ?? 0;
    final sleepQuality = wearables['todaySleepQuality'] ?? 'Unknown';
    final restingHeartRate = today['restingHeartRate'] ?? 'Unknown';
    final heartRateVariability = today['heartRateVariability'] ?? 'Unknown';
    final steps = today['steps'] ?? 0;
    final activeCaloriesBurned = today['activeCaloriesBurned'] ?? 0;
    final bodyTemperature = today['bodyTemperature'] ?? 'Unknown';

    final hrvTrend = wearables['hrvTrend'] ?? 'stable';
    final weightTrend = wearables['weightTrend'] ?? 'stable';
    final sevenDayAvgSteps = wearables['sevenDayAvgSteps'] ?? 0;
    final sevenDayAvgSleepMinutes = wearables['sevenDayAvgSleepMinutes'] ?? 0;
    final sevenDayAvgDeepSleepMinutes =
        wearables['sevenDayAvgDeepSleepMinutes'] ?? 0;
    final sevenDayAvgRHR = wearables['sevenDayAvgRHR'] ?? 'Unknown';

    final health = context['health'] ?? {};
    final bpSystolic = health['bpSystolic'] ?? 'Unknown';
    final bpDiastolic = health['bpDiastolic'] ?? 'Unknown';
    final bpCategory = health['bpCategory'] ?? 'Unknown';

    final bloodOxygen = today['bloodOxygen'] ?? 'Unknown';
    final bloodGlucoseMgDl = today['bloodGlucoseMgDl'] ?? 'Unknown';

    final rawMedicalConditions = context['medicalConditions'];
    final medicalConditions =
        (rawMedicalConditions is List && rawMedicalConditions.isNotEmpty)
        ? rawMedicalConditions.join(', ')
        : 'None';
    final rawJointRestrictions = context['jointRestrictions'];
    final jointRestrictions =
        (rawJointRestrictions is List && rawJointRestrictions.isNotEmpty)
        ? rawJointRestrictions.join(', ')
        : 'None';
    final jointsList = (rawJointRestrictions is List)
        ? rawJointRestrictions
        : [];

    String prompt =
        """
You are an expert certified personal trainer and exercise physiologist
with deep knowledge of sports medicine and rehabilitation.
Generate a personalized 7-day workout plan for this gym member.
Respond ONLY with valid JSON — no text, no markdown, no explanation
outside the JSON object.

═══ MEMBER IDENTITY ═══
Age: $age | Gender: $gender
Height: ${heightCm}cm | Weight: ${weightKg}kg | BMI: $bmi
Gym: Spring Health Studio, $branchName branch, Warangal, India
Member since: $joiningDate

═══ FITNESS GOAL & LEVEL ═══
Primary Goal: $fitnessGoal
Fitness Level: $fitnessLevel
Available: 4 sessions/week, ~60 minutes each
Fitness Test Results: Pushups $pushupsMax, Pullups $pullupsMax, Plank ${plankSeconds}s,
  Squat 1RM ${squat1rmKg}kg, Deadlift 1RM ${deadlift1rmKg}kg, Bench ${benchpress1rmKg}kg

═══ TODAY'S RECOVERY STATE (from wearables) ═══
Recovery Status: $recoveryStatus
Sleep Last Night: $totalSleepMinutes min total,
  $deepSleepMinutes min deep, $remSleepMinutes min REM,
  Quality: $sleepQuality
Resting Heart Rate: $restingHeartRate bpm
Heart Rate Variability: $heartRateVariability ms
""";

    if (hrvTrend == 'declining') {
      prompt +=
          "HRV trending DOWN over 7 days — possible overtraining, reduce volume this week\n";
    }

    prompt +=
        """
Steps Today So Far: $steps
Active Calories: $activeCaloriesBurned kcal
Body Temperature: $bodyTemperature°C
""";

    if (recoveryStatus == 'fatigued') {
      prompt +=
          "IMPORTANT: Member is fatigued today. Day 1 must be light — reduce volume by 30%, no maximal effort sets.\n";
    }

    if (recoveryStatus == 'sick') {
      prompt +=
          "IMPORTANT: Body temperature elevated. Day 1 must be complete rest or very light walking only.\n";
    }

    prompt +=
        """

═══ 7-DAY WEARABLE TRENDS ═══
Avg Daily Steps (7 days): $sevenDayAvgSteps
Avg Sleep (7 days): $sevenDayAvgSleepMinutes min
Avg Deep Sleep (7 days): $sevenDayAvgDeepSleepMinutes min
Avg Resting HR (7 days): $sevenDayAvgRHR bpm
HRV Trend: $hrvTrend
Weight Trend: $weightTrend

═══ CARDIOVASCULAR / HEALTH FLAGS ═══
Blood Pressure: $bpSystolic/$bpDiastolic mmHg
  → Category: $bpCategory
""";

    if (bpCategory.toString().contains('Stage 1') ||
        bpCategory.toString().contains('Stage 2') ||
        bpCategory.toString().contains('Elevated')) {
      prompt +=
          "BP PROTOCOL: Keep all sets at RPE ≤ 7/10. Include minimum 10-min aerobic warm-up. Avoid Valsalva maneuver (breath-holding during heavy lifts). Cue proper breathing on every exercise. Add BP check reminder before session.\n";
    }

    prompt += "Blood Oxygen (SpO2): $bloodOxygen%\n";
    if (bloodOxygen != 'Unknown' && (bloodOxygen as num) < 95) {
      prompt +=
          "FLAG: Low SpO2 — avoid breath-holding exercises, monitor breathing during session.\n";
    }

    if (bloodGlucoseMgDl != 'Unknown') {
      prompt += "Blood Glucose: $bloodGlucoseMgDl mg/dL\n";
      if ((bloodGlucoseMgDl as num) > 250) {
        prompt += "Do not prescribe high-intensity exercise today.\n";
      }
    }

    prompt +=
        """

Medical Conditions: $medicalConditions
Joint Restrictions: $jointRestrictions
""";

    if (jointsList.isNotEmpty) {
      prompt +=
          "For each restriction, substitute exercises that do not directly load the affected joint.\n";
    }

    final rpeContext = context['rpeContext'] as String? ?? '';
    if (rpeContext.isNotEmpty) {
      prompt += "\n$rpeContext\n";
    }

    prompt +=
        """

═══ EQUIPMENT AT $branchName BRANCH ═══
Standard commercial gym: barbells, dumbbells 20-40kg range, cable machines, lat pulldown, leg press, chest press machine, treadmills, stationary bikes

═══ RULES FOR THIS PLAN ═══
1. Day 7 = active recovery or full rest
2. Include warm-up (5-10 min) and cool-down (5 min) in every session
3. Each exercise must have: sets, reps/duration, rest seconds, one coaching cue sentence, and primary muscle groups
4. Only use equipment listed above
5. Progressive overload: each session that targets same muscles should be slightly harder than the previous one
6. Rest days should include mobility or light walking — not pure couch rest (unless recoveryStatus == 'sick')
7. coachNote must reference at least one specific wearable metric (e.g., mention their sleep quality, HRV, or step count)

═══ RESPOND WITH EXACTLY THIS JSON STRUCTURE ═══
{
  "weeklyPlan": [
    {
      "day": 1,
      "sessionType": "string e.g. Upper Body Strength",
      "estimatedMinutes": 60,
      "isRestDay": false,
      "exercises": [
        {
          "name": "string",
          "sets": 3,
          "reps": "10",
          "restSeconds": 90,
          "coachingCue": "string — one actionable sentence",
          "muscleGroups": ["string"]
        }
      ]
    }
  ],
  "weeklyFocus": "string — 1 sentence describing this week's theme",
  "coachNote": "string — 2-3 personalized sentences referencing member's specific wearable data",
  "bpNote": "string or null — populated if BP is elevated",
  "recoveryNote": "string or null — populated if HRV low or sleep poor"
}
""";

    return prompt;
  }

  String _buildDietPrompt(Map<String, dynamic> context) {
    final age = context['age'] ?? 'Unknown';
    final gender = context['gender'] ?? 'Unknown';
    final weightKg = context['weightKg'] ?? 'Unknown';
    final bmi = context['bmi'] ?? 'Unknown';
    final fitnessGoal = context['fitnessGoal'] ?? 'General Fitness';
    final dietaryPreference = context['dietaryPreference'] ?? 'None';

    final rawMedicalConditions = context['medicalConditions'];
    final medicalConditions =
        (rawMedicalConditions is List && rawMedicalConditions.isNotEmpty)
        ? rawMedicalConditions.join(', ')
        : 'None';

    final wearables = context['wearables'] ?? {};
    final today = wearables['today'] ?? {};
    final basalCaloriesBurned = today['basalCaloriesBurned'] ?? 'Unknown';
    final activeCaloriesBurned = today['activeCaloriesBurned'] ?? 0;
    final totalDailyCalories = today['totalDailyCalories'] ?? 'Unknown';
    final weightTrend = wearables['weightTrend'] ?? 'stable';

    final health = context['health'] ?? {};
    final bpSystolic = health['bpSystolic'] ?? 'Unknown';
    final bpDiastolic = health['bpDiastolic'] ?? 'Unknown';
    final bpCategory = health['bpCategory'] ?? 'Unknown';

    final bloodGlucoseMgDl = today['bloodGlucoseMgDl'] ?? 'Unknown';
    final waterLitres = today['waterLitres'] ?? 0.0;
    final bodyFatPercentage = today['bodyFatPercentage'] ?? 'Unknown';

    String prompt =
        """
You are an expert sports nutritionist and dietitian with deep knowledge
of Indian dietary patterns and ICMR nutritional guidelines.
Generate a personalized daily diet plan for this gym member.
Respond ONLY with valid JSON — no text outside the JSON.

═══ MEMBER PROFILE ═══
Age: $age | Gender: $gender | Weight: ${weightKg}kg
BMI: $bmi | Body Fat: $bodyFatPercentage%
Goal: $fitnessGoal
Dietary Preference: $dietaryPreference
Medical Conditions: $medicalConditions

═══ CALORIE CALCULATION BASE ═══
Basal Calories (from device): $basalCaloriesBurned kcal
Active Calories (today): $activeCaloriesBurned kcal
Total Daily Burn Estimate: $totalDailyCalories kcal
Weight Trend (7 days): $weightTrend
""";

    if (fitnessGoal.toString().toLowerCase().contains('loss')) {
      prompt += "Target deficit of 300-400 kcal/day\n";
    } else if (fitnessGoal.toString().toLowerCase().contains('gain') ||
        fitnessGoal.toString().toLowerCase().contains('muscle')) {
      prompt += "Target surplus of 200-300 kcal/day\n";
    } else {
      prompt += "Maintain calories, shift to high protein\n";
    }

    prompt +=
        """

═══ HEALTH-SPECIFIC DIET FLAGS ═══
Blood Pressure: $bpSystolic/$bpDiastolic → $bpCategory
""";

    if (bpCategory.toString().contains('Stage 1') ||
        bpCategory.toString().contains('Stage 2') ||
        bpCategory.toString().contains('Elevated') ||
        bpCategory.toString().contains('Hypertension')) {
      prompt += """
Apply DASH diet principles:
  - Limit sodium to 1,500-2,000mg/day
  - Emphasize potassium-rich foods (banana, spinach, dal)
  - Increase magnesium and calcium sources
  - Reduce processed and packaged foods
""";
    }

    prompt += "Blood Glucose: $bloodGlucoseMgDl mg/dL\n";
    if (medicalConditions.toLowerCase().contains('diabetes') ||
        medicalConditions.toLowerCase().contains('diabetic')) {
      prompt += """
  - Low GI foods only (prefer whole grains over refined)
  - Avoid simple sugars and white rice in large portions
  - Small frequent meals preferred
  - Post-workout carbs only from low-GI sources
""";
    }

    prompt +=
        """

Hydration (logged today): ${waterLitres}L
Hydration target: $weightKg × 0.035 + workout adjustment litres

═══ DIETARY PREFERENCE ═══
""";

    if (dietaryPreference.toString().toLowerCase() == 'vegetarian') {
      prompt +=
          "No meat or fish. Eggs optional if eggetarian. Protein sources: paneer, dal, rajma, chana, soya, curd, milk, tofu, seeds, nuts\n";
    } else if (dietaryPreference.toString().toLowerCase() == 'non_vegetarian' ||
        dietaryPreference.toString().toLowerCase() == 'non-vegetarian') {
      prompt +=
          "Include chicken, eggs, fish as primary protein sources. Use Indian cooking methods (grilled, curry, tandoor).\n";
    } else if (dietaryPreference.toString().toLowerCase() == 'vegan') {
      prompt +=
          "No animal products. Use soy milk, tofu, tempeh, legumes, seeds, nuts for protein.\n";
    }

    prompt += """

═══ INDIAN FOOD CONTEXT ═══
Use Indian foods exclusively or predominantly:
  Breakfast options: poha, upma, idli, dosa, paratha (multigrain), oats, eggs, banana, sprouts, curd
  Lunch options: dal, sabzi, roti (2-3), rice, salad, curd
  Dinner: lighter than lunch, dal/sabzi with 1-2 roti or brown rice
  Snacks: fruits, roasted chana, makhana, nuts, sprouts, chaas

═══ RESPOND WITH EXACTLY THIS JSON ═══
{
  "dailyTargets": {
    "calories": 2200,
    "proteinG": 140,
    "carbsG": 260,
    "fatG": 65,
    "fiberG": 35,
    "waterLitres": 3.0
  },
  "meals": [
    {
      "mealName": "Breakfast",
      "timing": "7:00 AM – 8:00 AM",
      "foods": [
        {
          "name": "string",
          "quantity": "string e.g. 2 medium",
          "approxCalories": 150,
          "proteinG": 6
        }
      ],
      "totalCalories": 450,
      "mealNote": "string or null — optional tip for this meal"
    }
  ],
  "hydrationLitres": 3.0,
  "nutritionNotes": "string — 2-3 sentences of personalized advice",
  "bpDietNote": "string or null — DASH guidance if HTN",
  "glucoseNote": "string or null — low GI guidance if diabetic",
  "supplementNote": "string or null — basic supplement suggestions e.g. protein powder if protein target is hard to hit from food alone"
}
""";

    return prompt;
  }

  Future<Map<String, dynamic>> generateWorkoutPlan(String memberId) async {
    // 1. Check cache
    final doc = await _db
        .collection('aiPlans')
        .doc(memberId)
        .collection('current')
        .doc('plan')
        .get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final generatedAt = data['generatedAt'] as Timestamp?;
      if (generatedAt != null &&
          DateTime.now().difference(generatedAt.toDate()).inHours < 24) {
        return data;
      }
    }

    // 2. Build context
    final context = await _buildMemberContext(memberId);

    final recentRpe = await RpeService.instance.getRecentRpe(limit: 5);
    String rpeContext = '';
    if (recentRpe.isNotEmpty) {
      final values = recentRpe.map((e) => e['rpe'] as int).toList();
      final avg = values.reduce((a, b) => a + b) / values.length;
      if (avg <= 2.0) {
        rpeContext =
            'The member has rated recent sessions as very easy (average RPE ${avg.toStringAsFixed(1)}/5). Increase workout volume and intensity by approximately 10 percent. Add one extra set per exercise where appropriate.';
      } else if (avg <= 3.5) {
        rpeContext =
            'The member has rated recent sessions at a comfortable level (average RPE ${avg.toStringAsFixed(1)}/5). Maintain current intensity and volume.';
      } else {
        rpeContext =
            'The member has rated recent sessions as difficult (average RPE ${avg.toStringAsFixed(1)}/5). Reduce total volume by 10 to 15 percent. Shorten sessions if needed and add one additional rest day this week.';
      }
    }
    context['rpeContext'] = rpeContext;

    // 3. Safety gate
    try {
      _checkSafetyGate(context);
    } catch (e) {
      final errorCode = e.toString().replaceAll('Exception: ', '');
      await _db
          .collection('aiPlans')
          .doc(memberId)
          .collection('current')
          .doc('plan')
          .set({'status': errorCode, 'generatedAt': Timestamp.now()});
      throw Exception('Safety gate failed: $errorCode');
    }

    // 4. Prompt
    final prompt = _buildWorkoutPrompt(context);

    // 5. Call Gemini
    final response = await _model.generateContent([Content.text(prompt)]);
    final jsonString = response.text ?? '';

    // 6. Parse and validate
    Map<String, dynamic> plan;
    try {
      plan = jsonDecode(jsonString);
      if (plan['weeklyPlan'] == null ||
          (plan['weeklyPlan'] as List).length != 7) {
        throw Exception('invalid_plan_structure');
      }
    } catch (e) {
      throw Exception('AjAX returned an invalid plan. Please try again.');
    }

    // 7. Write to Firestore
    final planData = {
      ...plan,
      'memberId': memberId,
      'status': 'active',
      'generatedAt': Timestamp.now(),
      'basedOn': {
        'goal': context['fitnessGoal'],
        'fitnessLevel': context['fitnessLevel'],
        'bpSystolic': context['health']?['bpSystolic'],
        'bpDiastolic': context['health']?['bpDiastolic'],
        'recoveryStatus': context['wearables']?['todayRecoveryStatus'],
        'sleepQuality': context['wearables']?['todaySleepQuality'],
        'todaySteps': context['wearables']?['today']['steps'],
        'todayHRV': context['wearables']?['today']['heartRateVariability'],
      },
    };

    await _db
        .collection('aiPlans')
        .doc(memberId)
        .collection('current')
        .doc('plan')
        .set(planData);

    return planData;
  }

  Future<Map<String, dynamic>> generateDietPlan(String memberId) async {
    // 1. Check cache
    final doc = await _db
        .collection('dietPlans')
        .doc(memberId)
        .collection('current')
        .doc('plan')
        .get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final generatedAt = data['generatedAt'] as Timestamp?;
      if (generatedAt != null &&
          DateTime.now().difference(generatedAt.toDate()).inHours < 24) {
        return data;
      }
    }

    // 2. Build context
    final context = await _buildMemberContext(memberId);

    // 3. Safety gate
    try {
      _checkSafetyGate(context);
    } catch (e) {
      final errorCode = e.toString().replaceAll('Exception: ', '');
      await _db
          .collection('dietPlans')
          .doc(memberId)
          .collection('current')
          .doc('plan')
          .set({'status': errorCode, 'generatedAt': Timestamp.now()});
      throw Exception('Safety gate failed: $errorCode');
    }

    // 4. Prompt
    final prompt = _buildDietPrompt(context);

    // 5. Call Gemini
    final response = await _model.generateContent([Content.text(prompt)]);
    final jsonString = response.text ?? '';

    // 6. Parse and validate
    Map<String, dynamic> plan;
    try {
      plan = jsonDecode(jsonString);
    } catch (e) {
      throw Exception('AjAX returned an invalid plan. Please try again.');
    }

    // 7. Write to Firestore
    final planData = {
      ...plan,
      'memberId': memberId,
      'status': 'active',
      'generatedAt': Timestamp.now(),
    };

    await _db
        .collection('dietPlans')
        .doc(memberId)
        .collection('current')
        .doc('plan')
        .set(planData);

    return planData;
  }

  Future<Map<String, dynamic>?> getCachedWorkoutPlan(String memberId) async {
    try {
      final doc = await _db
          .collection('aiPlans')
          .doc(memberId)
          .collection('current')
          .doc('plan')
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint(' Error getting cached workout plan: \$e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCachedDietPlan(String memberId) async {
    try {
      final doc = await _db
          .collection('dietPlans')
          .doc(memberId)
          .collection('current')
          .doc('plan')
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint(' Error getting cached diet plan: \$e');
      return null;
    }
  }

  Future<void> syncWearablesAndGenerate(String memberId) async {
    await WearableSnapshotService(db: _db).syncTodaySnapshot(memberId);
    await generateWorkoutPlan(memberId);
  }
}
