import 'package:firebase_ai/firebase_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
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
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.4,
      ),
    );

    int maxHeartRate = 220 - memberAge;
    int safeZoneLow = (maxHeartRate * 0.5).round();
    int safeZoneHigh = (maxHeartRate * 0.85).round();

    String prompt = 'You are AjAX, an AI personal trainer at an Indian gym.\n'
        'Generate 3 workout plans for intensity levels low, medium, and high for a live in-person gym session.\n\n'
        'MEMBER PROFILE\n'
        'Name: ${member.name}\n'
        'Age: $memberAge years\n'
        'Estimated max heart rate: $maxHeartRate bpm\n'
        'Safe HR zone: $safeZoneLow to $safeZoneHigh bpm\n'
        'Membership: ${member.category}\n';

    if (isFirstSession) {
      prompt += 'FIRST SESSION -- Foundation Mode. Be gentle. '
          'Prioritize form, mobility, and baseline. '
          'No heavy compound lifts.\n';
    }

    if (goalContext != null) {
      prompt += '\nGOAL AND TARGET\n'
          'Primary goal: ${goalContext['primaryGoal']}\n'
          'Current: ${goalContext['currentValue']} ${goalContext['unit']}\n'
          'Target: ${goalContext['targetValue']} ${goalContext['unit']}\n'
          'Deadline: ${goalContext['weeksRemaining']} weeks remaining\n'
          'Weekly rate needed: ${goalContext['weeklyRateNeeded']} ${goalContext['unit']}/week\n'
          'Current pace: ${goalContext['currentPace']}\n';

      if (goalContext['currentPace'] == 'behind') {
        prompt += 'PACE ALERT: Member is behind goal. '
            'Increase training volume appropriately.\n';
      }

      prompt += 'Daily caloric target: ${goalContext['dailyCaloricTarget']} kcal\n';

      String goalType = goalContext['primaryGoal'].toString().toLowerCase();
      if (goalType.contains('weight_loss') || goalType.contains('weight loss')) {
        prompt += 'Prioritize HIIT and compound movements.\n';
      } else if (goalType.contains('muscle_gain') || goalType.contains('muscle gain')) {
        prompt += 'Prioritize compound lifts, progressive overload.\n';
      } else if (goalType.contains('strength')) {
        prompt += 'Low-rep high-weight focus. Long rest periods.\n';
      } else if (goalType.contains('endurance')) {
        prompt += 'Include cardiovascular elements, higher rep ranges.\n';
      } else if (goalType.contains('flexibility')) {
        prompt += 'Embed extensive mobility work and stretch holds.\n';
      }
    } else {
      prompt += '\nGoal: General fitness\n';
    }

    if (flexibilityContext != null) {
      List<dynamic> tightAreas = flexibilityContext['tightAreas'] ?? [];
      prompt += '\nFLEXIBILITY PROFILE\n'
          'Overall score: ${flexibilityContext['overallScore']}/100\n'
          'Tight areas: ${tightAreas.join(', ')}\n'
          'For each tight area include 1 dedicated mobility exercise.\n'
          'Tight hips: include hip flexor drills.\n'
          'Tight shoulders: include band pull-aparts.\n'
          'Poor ankle mobility: avoid deep barbell squats, use goblet squats or leg press instead.\n'
          'Poor overhead mobility: avoid overhead press, use landmine press instead.\n';
    } else {
      prompt += '\nFLEXIBILITY: Not yet assessed.\n';
    }

    List<dynamic> weightEntries = bodyMetricsContext['weightEntries'] ?? [];
    List<String> weightTrend = [];
    if (weightEntries.isNotEmpty) {
      int count = weightEntries.length > 4 ? 4 : weightEntries.length;
      for (int i = 0; i < count; i++) {
        weightTrend.add(weightEntries[i]['weightKg'].toString());
      }
    }

    prompt += '\nBODY METRICS\n'
        'Weight: ${bodyMetricsContext['weightKg'] ?? 'unknown'} kg\n'
        'BMI: ${bodyMetricsContext['bmi'] ?? 'unknown'}\n'
        'Body fat: ${bodyMetricsContext['bodyFatPercentage'] ?? 'not tracked'}%\n'
        'Weight trend (last 4): ${weightTrend.isNotEmpty ? weightTrend.join(' to ') : 'no data'} kg\n'
        'BMR: ${bodyMetricsContext['bmr'] ?? 'unknown'} kcal/day\n'
        'TDEE: ${bodyMetricsContext['tdee'] ?? 'unknown'} kcal/day\n';

    int readinessScore = (trainerContext['readinessScore'] as num?)?.toInt() ?? 75;

    prompt += '\nTODAY READINESS\n'
        'Score: $readinessScore/100\n'
        'Sleep: ${wearableData?['sleepHours'] ?? 'unknown'} hours\n'
        'HRV: ${wearableData?['hrv'] ?? 'unknown'} ms\n'
        'Resting HR: ${wearableData?['restingHR'] ?? 'unknown'} bpm\n'
        'Duration: ';

    if (readinessScore < 40) {
      prompt += 'cap 35 min, reduce volume 30%\n';
    } else if (readinessScore <= 70) {
      prompt += '40-50 min standard volume\n';
    } else {
      prompt += '50-60 min full volume\n';
    }

    List<dynamic> soreness = trainerContext['soreness'] ?? [];
    bool hasInjury = trainerContext['hasInjury'] ?? false;

    prompt += '\nTRAINER INPUT\n'
        'Energy: ${trainerContext['energyLevel']}/5\n'
        'Sore areas: ${soreness.isEmpty ? 'none' : soreness.join(', ')}\n'
        'Injury: ${hasInjury ? trainerContext['injuryNote'] : 'none'}\n';

    if (lastSession != null) {
      prompt += '\nLAST SESSION\n'
          'Date: [formatted]\n'
          'Duration: ${lastSession['durationMinutes'] ?? 'X'} min . RPE: ${lastSession['rpe'] ?? 'X'}/10\n'
          'Notes: ${lastSession['trainerNotes'] ?? 'none'}\n'
          'For repeated exercises suggest +2.5-5 percent weight.\n';
    } else {
      prompt += '\nLAST SESSION: None recorded.\n';
    }

    if (memberIntelligence != null) {
      List<dynamic> strongLifts = memberIntelligence['strongLifts'] ?? [];
      List<dynamic> weakLifts = memberIntelligence['weakLifts'] ?? [];
      List<dynamic> avoidedExercises = memberIntelligence['avoidedExercises'] ?? [];
      List<dynamic> injuryHistory = memberIntelligence['injuryHistory'] ?? [];
      int totalSessionsLogged = memberIntelligence['totalSessionsLogged'] ?? 0;

      prompt += '\nMEMBER INTELLIGENCE\n'
          'Strong lifts: ${strongLifts.join(', ')}\n'
          'Needs work: ${weakLifts.join(', ')}\n'
          'Always avoid: ${avoidedExercises.join(', ')}\n'
          'Injury history: ${injuryHistory.join(', ')}\n'
          'Total sessions: $totalSessionsLogged\n';
    } else {
      prompt += '\nMEMBER INTELLIGENCE: First session, no history.\n';
    }

    prompt += '\nAVAILABLE EQUIPMENT TODAY\n'
        '${availableEquipment.join(', ')}\n'
        'CRITICAL: Only program exercises using this equipment. No exceptions.\n';

    prompt += '\nHARD CONSTRAINTS\n'
        'Never program exercises for sore areas: ${soreness.join(', ')}\n';

    if (hasInjury) {
      prompt += 'Never include exercises involving: ${trainerContext['injuryNote']}\n';
    }

    if (memberAge > 45) {
      prompt += 'Older member: longer rest, lower joint impact.\n';
    }

    if (isFirstSession) {
      prompt += 'First session: no 1-rep maxes, no heavy compound lifts.\n';
    }

    prompt += 'Calorie estimate: weightKg x MET x minutes/60. Never use fixed calorie numbers.\n'
        'Use exercise names common in Indian gyms.\n';

    prompt += '\nDIET NOTE\n'
        'Include one brief Indian meal suggestion for:\n'
        '- Post-workout (within 30 minutes)\n'
        '- Dinner tonight\n'
        'Keep it short. Full plan is in AjAX coach screen.\n';

    prompt += '\nRespond with valid JSON only. No markdown. '
        'No explanation outside the JSON. '
        'Exact structure:\n'
        '{\n'
        '  "isFoundationSession": bool,\n'
        '  "nextWeighInDays": int,\n'
        '  "sessionFocus": "String",\n'
        '  "goalInsight": "String",\n'
        '  "postWorkoutMeal": "String",\n'
        '  "dinnerSuggestion": "String",\n'
        '  "low": { "label": "String", "estimatedMinutes": int, "estimatedCalories": int, "reasoning": "String", "exercises": [{"name": "String", "sets": int, "reps": int, "weightKg": double, "unit": "String", "restSeconds": int, "isMobilityWork": bool, "notes": "String"}] },\n'
        '  "medium": { "label": "String", "estimatedMinutes": int, "estimatedCalories": int, "reasoning": "String", "exercises": [{"name": "String", "sets": int, "reps": int, "weightKg": double, "unit": "String", "restSeconds": int, "isMobilityWork": bool, "notes": "String"}] },\n'
        '  "high": { "label": "String", "estimatedMinutes": int, "estimatedCalories": int, "reasoning": "String", "exercises": [{"name": "String", "sets": int, "reps": int, "weightKg": double, "unit": "String", "restSeconds": int, "isMobilityWork": bool, "notes": "String"}] }\n'
        '}';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final decoded = jsonDecode(response.text!) as Map<String, dynamic>;

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
            DateTime.now().add(Duration(
              days: (decoded['nextWeighInDays'] as int? ?? 7)))),
          'status': 'warmup',
        });
    } catch (e, stack) {
      debugPrint('TrainerAjaxService error: $e');
      debugPrint('$stack');
      // Update session to warmup with empty plans so screen
      // does not hang indefinitely
      await FirebaseFirestore.instance
        .collection('trainingSessions')
        .doc(sessionId)
        .update({
          'status': 'warmup',
          'sessionFocus': 'AjAX unavailable -- select plan manually.',
        });
    }
  }
}
