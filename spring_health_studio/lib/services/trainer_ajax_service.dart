import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/member_model.dart';

class TrainerAjaxService {
  static Future<void> generateSessionPlans({
    required String sessionId,
    required MemberModel member,
    required int memberAge,
    required bool isFirstSession,
    required Map<String, dynamic> trainerContext,
    required Map<String, dynamic> bodyMetricsContext,
    required Map<String, dynamic>? goalContext,
    required Map<String, dynamic>? flexibilityContext,
    required Map<String, dynamic>? wearableData,
    required Map<String, dynamic>? lastSession,
    required Map<String, dynamic>? memberIntelligence,
    required List<String> availableEquipment,
  }) async {

    // 1. Pre-compute Prompt Variables
    final maxHr = 220 - memberAge;
    final safeHrMin = (maxHr * 0.5).round();
    final safeHrMax = (maxHr * 0.85).round();

    final foundationStr = isFirstSession
        ? 'FIRST SESSION - Foundation Mode. Be gentle. Prioritize form, mobility, and establishing baseline. No heavy lifts.'
        : '';

    // Goal Construction
    String goalStr = 'Goal: General fitness';
    if (goalContext != null) {
      final goal = goalContext['primaryGoal'] ?? 'general';
      final paceAlert = goalContext['currentPace'] == 'behind'
          ? 'PACE ALERT: Member is behind their goal. Increase training volume appropriately. Prioritize goal-aligned exercises.'
          : goalContext['currentPace'] == 'ahead'
              ? 'Member is ahead of goal. Maintain current approach. Consider progressive challenge.'
              : '';

      String goalSpecifics = '';
      if (goal == 'weight_loss') goalSpecifics = 'Caloric deficit of 500kcal/day needed. Prioritize HIIT, compound movements, and calorie-burning exercises.';
      if (goal == 'muscle_gain') goalSpecifics = 'Caloric surplus of 250kcal/day needed. Prioritize compound lifts, progressive overload, adequate rest between sets.';
      if (goal == 'strength') goalSpecifics = 'Prioritize low-rep, high-weight compound lifts. Longer rest periods (2-3 min). Focus on the specific lift target.';
      if (goal == 'endurance') goalSpecifics = 'Include cardiovascular elements. Higher rep ranges. Circuit-style training.';
      if (goal == 'flexibility') goalSpecifics = 'Embed extensive mobility work. Yoga-style movements. Hold stretches 30-60 seconds.';

      goalStr = '''
  Primary Goal: ${goalContext['primaryGoal']}
  Current: ${goalContext['currentValue']} ${goalContext['unit']}
  Target: ${goalContext['targetValue']} ${goalContext['unit']}
  Deadline: ${goalContext['weeksRemaining']} weeks remaining
  Weekly rate needed: ${goalContext['weeklyRateNeeded']} ${goalContext['unit']}/week
  Current pace: ${goalContext['currentPace']}
  $paceAlert
  Daily caloric target: ${goalContext['dailyCaloricTarget'] ?? 'unknown'} kcal
  $goalSpecifics''';
    }

    // Flexibility Construction
    String flexibilityStr = 'Flexibility data not yet assessed.';
    if (flexibilityContext != null) {
      final tightAreas = (flexibilityContext['tightAreas'] as List?)?.join(', ') ?? 'none';
      flexibilityStr = '''
  Overall Flexibility Score: ${flexibilityContext['score']}/100
  Tight areas (score 1-2): $tightAreas
  RULES:
  - For each tight area, include 1 dedicated mobility/stretch exercise per session until score improves above 2.
  - Label mobility exercises clearly so trainer knows which are for flexibility work.
  - Tight hips -> include hip flexor drills
  - Tight shoulders -> include band pull-aparts
  - Tight thoracic -> include thoracic extensions
  - Poor ankle mobility -> avoid deep barbell squats, use goblet squats or leg press instead.
  - Poor overhead mobility -> avoid overhead press, use landmine press instead.''';
    }

    // Last Session Construction
    String lastSessionStr = 'No previous session recorded.';
    if (lastSession != null) {
      lastSessionStr = '''
  Date: ${lastSession['date']}
  Exercises: ${lastSession['summary']}
  Duration: ${lastSession['duration']} min · RPE: ${lastSession['rpe']}/10
  Trainer notes: ${lastSession['trainerNotes'] ?? 'none'}
  Progressive overload: if any exercise repeats, suggest +2.5-5% weight for medium/high plan.''';
    }

    // Intelligence Construction
    String intelStr = 'First session - no history yet.';
    if (memberIntelligence != null) {
      intelStr = '''
  Strong lifts: ${memberIntelligence['strongLifts']}
  Needs work: ${memberIntelligence['weakLifts']}
  Always avoid: ${memberIntelligence['avoidedExercises']}
  Injury history: ${memberIntelligence['injuryHistory']}
  Last 3 trainer observations: ${memberIntelligence['observations']}
  Total sessions: ${memberIntelligence['totalSessionsLogged']}''';
    }

    // Readiness & Observations Setup
    final readiness = trainerContext['readinessScore'] ?? 50;
    final sorenessList = trainerContext['soreness'] as List? ?? [];
    final hasInjury = trainerContext['hasInjury'] ?? false;
    final injuryNote = trainerContext['injuryNote'] ?? '';

    // 2. Assemble the Master Prompt
    final prompt = '''
You are AjAX, an AI personal trainer at an Indian gym.
Generate 3 workout plans (low/medium/high intensity)
for an in-person gym session happening right now.

- MEMBER PROFILE -
Name: ${member.name}
Age: $memberAge years
Estimated Max Heart Rate: $maxHr bpm
Safe HR Zone: $safeHrMin-$safeHrMax bpm
Membership: ${member.category}
$foundationStr

- GOAL & TARGET -
$goalStr

- FLEXIBILITY PROFILE -
$flexibilityStr

- BODY METRICS -
Weight: ${bodyMetricsContext['weightKg'] ?? 'unknown'} kg
BMI: ${bodyMetricsContext['bmi'] ?? 'unknown'} (${bodyMetricsContext['bmiStatus'] ?? 'unknown'})
Body Fat %: ${bodyMetricsContext['bodyFatPct'] ?? 'not tracked'}
Weight trend (last 4 check-ins): ${(bodyMetricsContext['weightTrend'] as List?)?.join(' -> ') ?? 'unknown'} kg
BMR: ${bodyMetricsContext['bmr'] ?? 'unknown'} kcal/day
TDEE: ${bodyMetricsContext['tdee'] ?? 'unknown'} kcal/day
Daily caloric target: ${bodyMetricsContext['caloricTarget'] ?? 'unknown'} kcal

- TODAY'S READINESS -
Readiness Score: $readiness/100
Sleep: ${trainerContext['sleepHours'] ?? 'unknown'} hours
HRV: ${wearableData?['hrv'] ?? 'unknown'} ms
Resting HR: ${wearableData?['restingHR'] ?? 'unknown'} bpm
Steps yesterday: ${wearableData?['steps'] ?? 'unknown'}
Duration rule:
  score < 40:  cap 35 min, reduce volume 30%
  score 40-70: 40-50 min standard volume
  score > 70:  50-60 min full volume

- TRAINER OBSERVATIONS -
Energy: ${trainerContext['energyLevel'] ?? 3}/5
Sore: ${sorenessList.isEmpty ? 'none' : sorenessList.join(', ')}
Injury: ${hasInjury ? injuryNote : 'none'}

- LAST SESSION -
$lastSessionStr

- MEMBER INTELLIGENCE -
$intelStr

- AVAILABLE EQUIPMENT TODAY -
${availableEquipment.join(', ')}
CRITICAL: Only program exercises using this equipment. No substitutions with unlisted items.

- HARD CONSTRAINTS -
- NEVER program exercises for sore areas: ${sorenessList.join(', ')}
${hasInjury ? '- NEVER include exercises involving: $injuryNote. No exceptions ever.' : ''}
- Age $memberAge: older members >45 need longer rest, lower joint impact exercises.
${isFirstSession ? '- No 1-rep maxes, no heavy compound lifts. Foundation session.' : ''}
- Kcal estimate = weightKg x MET x minutes/60 (dynamic - never guess fixed numbers)
- Indian gym context: use exercise names common in Indian gyms.

- DIET NOTE FOR TODAY -
Based on goal and caloric target, include ONE practical Indian meal suggestion for:
  - Post-workout (within 30 minutes)
  - Dinner tonight
  (Keep brief. Full diet plan is in AiCoachScreen.)

Respond ONLY with valid JSON. No markdown.
No explanation outside JSON. Exact structure:
{
  "isFoundationSession": bool,
  "nextWeighInDays": int,
  "sessionFocus": "String",
  "goalInsight": "String",
  "postWorkoutMeal": "String",
  "dinnerSuggestion": "String",
  "low": {
    "label": "String",
    "estimatedMinutes": int,
    "estimatedCalories": int,
    "reasoning": "String",
    "exercises": [
      {
        "name": "String",
        "sets": int,
        "reps": int,
        "weightKg": double,
        "unit": "reps",
        "restSeconds": int,
        "isMobilityWork": bool,
        "notes": "String"
      }
    ]
  },
  "medium": { "same structure as low" },
  "high": { "same structure as low" }
}
''';

    // 3. Model Configuration & Execution
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-1.5-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4,
      ),
    );

    try {
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw Exception('AjAX returned an empty response.');
      }

      // 4. Parse & Update Firestore
      final decoded = jsonDecode(response.text!);

      await FirebaseFirestore.instance
          .collection('trainingSessions')
          .doc(sessionId)
          .update({
        'plans': {
          'low': decoded['low'],
          'medium': decoded['medium'],
          'high': decoded['high'],
        },
        'sessionFocus': decoded['sessionFocus'],
        'goalInsight': decoded['goalInsight'],
        'postWorkoutMeal': decoded['postWorkoutMeal'],
        'dinnerSuggestion': decoded['dinnerSuggestion'],
        'isFoundationSession': decoded['isFoundationSession'],
        'nextWeighInDate': Timestamp.fromDate(
            DateTime.now().add(Duration(days: decoded['nextWeighInDays'] ?? 7))),
        'status': 'warmup',
      });

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Ajax Generation Error: \$e');
      }
      rethrow;
    }
  }
}
