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

  static Future<void> analyzeAndGenerate({
    required String memberId,
    required String memberAuthUid,
    required String sessionId,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final results = await Future.wait([
      firestore.collection('workouts')
          .where('memberId', isEqualTo: memberId)
          .orderBy('date', descending: true)
          .limit(7)
          .get(),
      firestore.collection('personalbests').doc(memberId).get(),
      firestore.collection('healthProfiles').doc(memberId).get(),
      firestore.collection('aiPlans').doc(memberAuthUid).collection('current').doc('current').get(),
      firestore.collection('wearableSnapshots').doc(memberAuthUid).collection('daily').doc(todayStr).get(),
      firestore.collection('members').doc(memberId).get(),
    ]);

    final lastWorkoutsSnapshot = results[0] as QuerySnapshot;
    final personalBestsSnapshot = results[1] as DocumentSnapshot;
    final healthSnap = results[2] as DocumentSnapshot;
    // final aiPlanSnapshot = results[3] as DocumentSnapshot;
    final wearableSnapshot = results[4] as DocumentSnapshot;
    final memberSnapshot = results[5] as DocumentSnapshot;

    if (healthSnap.exists) {
      final healthData = healthSnap.data() as Map<String, dynamic>? ?? {};
      final medicalHold = healthData['medicalHold'] as bool? ?? false;
      final holdReason = healthData['holdReason'] as String? ?? '';

      if (medicalHold) {
        await FirebaseFirestore.instance
            .collection('sessions')
            .doc(sessionId)
            .set({
          'status': 'medical_hold',
          'medicalHoldReason': holdReason,
          'aiSummary': 'Medical hold active — no workout generated. '
                       'Consult member health profile.',
        }, SetOptions(merge: true));
        return;
      }

      final conditions = List<String>.from(healthData['conditions'] ?? []);
      final allergies = List<String>.from(healthData['allergies'] ?? []);

      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .set({
        'memberConditions': conditions,
        'memberAllergies': allergies,
      }, SetOptions(merge: true));
    }

    final memberData = memberSnapshot.data() as Map<String, dynamic>? ?? {};
    final category = (memberData['category'] as String?)?.toLowerCase() ?? 'standard';

    int exerciseCount = (category == 'premium') ? 6 : 4; // base count

    List<String> avoidMuscles = [];
    if (lastWorkoutsSnapshot.docs.isNotEmpty) {
      final lastWorkoutData = lastWorkoutsSnapshot.docs.first.data() as Map<String, dynamic>;
      final lastDate = (lastWorkoutData['date'] as Timestamp?)?.toDate();
      if (lastDate != null && now.difference(lastDate).inDays <= 1) {
        final muscles = List<String>.from(lastWorkoutData['musclesWorked'] ?? []);
        avoidMuscles.addAll(muscles);
      }
    }

    final wearableData = wearableSnapshot.data() as Map<String, dynamic>?;
    final recoveryScore = (wearableData?['recoveryScore'] as num?)?.toInt() ?? 100;

    int setReduction = (recoveryScore < 40) ? 1 : 0;

    final allMuscles = ['chest', 'back', 'shoulders', 'biceps', 'triceps', 'quads', 'hamstrings', 'glutes', 'core', 'calves'];
    final availableMuscles = allMuscles.where((m) => !avoidMuscles.contains(m)).toList();

    if (availableMuscles.isEmpty) {
      availableMuscles.addAll(allMuscles);
    }

    final personalBestsData = personalBestsSnapshot.data() as Map<String, dynamic>? ?? {};

    List<Map<String, dynamic>> generatedExercises = [];

    // Always include a compound movement
    final compounds = ['Squat', 'Deadlift', 'Bench Press', 'Barbell Row'];
    final selectedCompound = compounds[now.microsecond % compounds.length];

    double compoundWeight = 20.0;
    if (personalBestsData.containsKey(selectedCompound)) {
      final pb = (personalBestsData[selectedCompound]['weightKg'] as num?)?.toDouble() ?? 20.0;
      compoundWeight = pb * 0.85; // 85% of PB
    }

    generatedExercises.add({
      'exerciseName': selectedCompound,
      'sets': 4 - setReduction > 0 ? 4 - setReduction : 1,
      'reps': 8,
      'weightKg': compoundWeight,
      'targetMuscles': _getMusclesForCompound(selectedCompound),
      'status': 'active',
      'completedSets': 0,
      'trainerNote': (recoveryScore < 40) ? 'Lighter session due to low recovery.' : '',
    });

    for (int i = 1; i < exerciseCount; i++) {
      final muscle = availableMuscles[i % availableMuscles.length];
      final exerciseName = _getExerciseForMuscle(muscle, i);

      double weight = 10.0;
      if (personalBestsData.containsKey(exerciseName)) {
        final pb = (personalBestsData[exerciseName]['weightKg'] as num?)?.toDouble() ?? 10.0;
        weight = pb * 0.85;
      }

      generatedExercises.add({
        'exerciseName': exerciseName,
        'sets': 3 - setReduction > 0 ? 3 - setReduction : 1,
        'reps': 10,
        'weightKg': weight,
        'targetMuscles': [muscle],
        'status': 'pending',
        'completedSets': 0,
        'trainerNote': '',
      });
    }

    String nextFocus = availableMuscles.last;
    if (avoidMuscles.isNotEmpty) {
      nextFocus = avoidMuscles.first; // Next time hit what we rested today
    }

    await firestore.collection('sessions').doc(sessionId).set({
      'exercises': generatedExercises,
      'status': 'planning',
      'aiSummary': 'Generated session focused on ${availableMuscles.take(2).join(' and ')}.',
      'nextSessionFocus': nextFocus,
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> generateStretching(
    List<String> musclesWorked,
  ) async {
    // Rule-based stretch selection (no external call needed):
    // Map each muscle group to 1-2 stretch exercises:
    const stretchMap = {
      'chest':     [{ 'exerciseName': 'Doorway Chest Stretch',
                      'durationSeconds': 30, 'targetMuscle': 'chest' }],
      'back':      [{ 'exerciseName': 'Child\'s Pose',
                      'durationSeconds': 40, 'targetMuscle': 'back' }],
      'shoulders': [{ 'exerciseName': 'Cross-Body Shoulder Stretch',
                      'durationSeconds': 30, 'targetMuscle': 'shoulders' }],
      'biceps':    [{ 'exerciseName': 'Wrist Flexor Stretch',
                      'durationSeconds': 30, 'targetMuscle': 'biceps' }],
      'triceps':   [{ 'exerciseName': 'Overhead Tricep Stretch',
                      'durationSeconds': 30, 'targetMuscle': 'triceps' }],
      'quads':     [{ 'exerciseName': 'Standing Quad Stretch',
                      'durationSeconds': 35, 'targetMuscle': 'quads' }],
      'hamstrings':[{ 'exerciseName': 'Seated Hamstring Stretch',
                      'durationSeconds': 40, 'targetMuscle': 'hamstrings' }],
      'glutes':    [{ 'exerciseName': 'Pigeon Pose',
                      'durationSeconds': 40, 'targetMuscle': 'glutes' }],
      'core':      [{ 'exerciseName': 'Cobra Stretch',
                      'durationSeconds': 30, 'targetMuscle': 'core' }],
      'calves':    [{ 'exerciseName': 'Standing Calf Stretch',
                      'durationSeconds': 30, 'targetMuscle': 'calves' }],
    };

    final result = <Map<String, dynamic>>[];
    for (final muscle in musclesWorked) {
      final stretches = stretchMap[muscle];
      if (stretches != null) {
        for (final s in stretches) {
          result.add({ ...s, 'status': 'pending' });
        }
      }
    }

    // Deduplicate, cap at 6 stretches
    final seen = <String>{};
    final deduped = result.where((s) {
      final name = s['exerciseName'] as String;
      return seen.add(name);
    }).take(6).toList();

    // If no muscles matched: return 3 generic full-body stretches
    if (deduped.isEmpty) {
      return [
        { 'exerciseName': 'Standing Forward Fold',
          'durationSeconds': 40, 'targetMuscle': 'full body',
          'status': 'pending' },
        { 'exerciseName': 'Child\'s Pose',
          'durationSeconds': 40, 'targetMuscle': 'back',
          'status': 'pending' },
        { 'exerciseName': 'Hip Flexor Stretch',
          'durationSeconds': 35, 'targetMuscle': 'hip flexors',
          'status': 'pending' },
      ];
    }
    return deduped;
  }

  static Future<void> finalizeSession(String sessionId) async {
    final db = FirebaseFirestore.instance;
    final sessionSnap = await db.collection('sessions').doc(sessionId).get();
    if (!sessionSnap.exists) return;
    final sessionData = sessionSnap.data()!;

    // IDEMPOTENCY GUARD — critical rule from master plan
    if (sessionData['sessionXpAwarded'] == true) return;

    final memberId = sessionData['memberId'] as String;
    final memberAuthUid = sessionData['memberAuthUid'] as String;
    final trainerId = sessionData['trainerId'] as String;
    final exercises = List<Map<String,dynamic>>.from(
      sessionData['exercises'] ?? []);
    final musclesWorked = List<String>.from(
      sessionData['musclesWorked'] ?? []);
    final createdAt = (sessionData['createdAt'] as Timestamp).toDate();
    final now = DateTime.now();
    final durationMinutes = now.difference(createdAt).inMinutes;

    // 1. Write to workouts collection
    final workoutExercises = exercises.map((ex) {
      final completedSets = (ex['completedSets'] as int?) ?? 0;
      return {
        'name': ex['exerciseName'],
        'category': 'Trainer Session',
        'sets': List.generate(completedSets, (i) => {
          'setNumber': i + 1,
          'weight': ex['weightKg'] ?? 0,
          'reps': ex['reps'] ?? 0,
          'isCompleted': true,
        }),
      };
    }).toList();

    await db.collection('workouts').add({
      'memberId': memberId,
      'memberAuthUid': memberAuthUid,
      'exercises': workoutExercises,
      'durationMinutes': durationMinutes,
      'date': Timestamp.now(),
      'source': 'trainer_session',
      'sessionId': sessionId,
      'trainerId': trainerId,
      'musclesWorked': musclesWorked,
    });

    // 2. PB detection
    // For each exercise: check if max weight in this session exceeds
    // stored PB in personalbests/{memberId}
    final pbDoc = await db.collection('personalbests').doc(memberId).get();
    final pbData = Map<String,dynamic>.from(pbDoc.data() ?? {});
    final pbUpdates = <String,dynamic>{};

    for (final ex in exercises) {
      final name = ex['exerciseName'] as String;
      final weight = (ex['weightKg'] as num?)?.toDouble() ?? 0.0;
      if (weight <= 0) continue;
      final existing = (pbData[name]?['weightKg'] as num?)?.toDouble() ?? 0.0;
      if (weight > existing) {
        pbUpdates[name] = {
          'weightKg': weight,
          'reps': ex['reps'] ?? 0,
          'date': Timestamp.now(),
        };
      }
    }

    if (pbUpdates.isNotEmpty) {
      await db.collection('personalbests').doc(memberId)
        .set(pbUpdates, SetOptions(merge: true));
    }

    // 3. Award 100 XP — trainer session is worth more than self-logged (75 XP)
    await db.collection('gamificationEvents').add({
      'memberId': memberId,
      'type': 'trainer_session_complete',
      'xp': 100,
      'processed': false,
      'createdAt': Timestamp.now(),
    });

    // 4. Write tomorrow's AI context to wearableSnapshots
    final today = DateTime.now();
    final dateKey =
      '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    await db.collection('wearableSnapshots')
      .doc(memberAuthUid)
      .collection('daily')
      .doc(dateKey)
      .set({
        'musclesWorked': musclesWorked,
        'sessionDurationMinutes': durationMinutes,
        'source': 'trainer_session',
        'sessionId': sessionId,
        'nextSessionFocus': sessionData['nextSessionFocus'] ?? '',
      }, SetOptions(merge: true));

    // 5. Send notification to member
    final trainerNote = sessionData['trainerNotes'] as String? ?? '';
    final aiSummary = sessionData['aiSummary'] as String? ?? '';
    final notifBody = trainerNote.isNotEmpty
      ? (trainerNote.length > 100
          ? '${trainerNote.substring(0,100)}...'
          : trainerNote)
      : (aiSummary.isNotEmpty ? aiSummary : 'Session complete. Your diet plan is ready.');

    await db.collection('notifications')
      .doc(memberAuthUid)
      .collection('items')
      .add({
        'type': 'session_complete',
        'title': 'Great session!',
        'body': notifBody,
        'read': false,
        'createdAt': Timestamp.now(),
      });

    // 6. Mark session complete — set sessionXpAwarded FIRST (idempotency)
    await db.collection('sessions').doc(sessionId).update({
      'sessionXpAwarded': true,
      'status': 'complete',
      'completedAt': Timestamp.now(),
    });
  }

  static List<String> _getMusclesForCompound(String compound) {
    switch (compound) {
      case 'Squat': return ['quads', 'glutes'];
      case 'Deadlift': return ['hamstrings', 'back', 'glutes'];
      case 'Bench Press': return ['chest', 'triceps', 'shoulders'];
      case 'Barbell Row': return ['back', 'biceps'];
      default: return [];
    }
  }

  static String _getExerciseForMuscle(String muscle, int salt) {
    switch (muscle) {
      case 'chest': return (salt % 2 == 0) ? 'Incline Dumbbell Press' : 'Cable Crossovers';
      case 'back': return (salt % 2 == 0) ? 'Lat Pulldown' : 'Seated Cable Row';
      case 'shoulders': return (salt % 2 == 0) ? 'Overhead Press' : 'Lateral Raises';
      case 'biceps': return (salt % 2 == 0) ? 'Barbell Curl' : 'Hammer Curls';
      case 'triceps': return (salt % 2 == 0) ? 'Tricep Pushdown' : 'Overhead Tricep Extension';
      case 'quads': return (salt % 2 == 0) ? 'Leg Press' : 'Leg Extensions';
      case 'hamstrings': return (salt % 2 == 0) ? 'Romanian Deadlift' : 'Leg Curls';
      case 'glutes': return (salt % 2 == 0) ? 'Hip Thrusts' : 'Cable Pull-throughs';
      case 'core': return (salt % 2 == 0) ? 'Plank' : 'Russian Twists';
      case 'calves': return (salt % 2 == 0) ? 'Standing Calf Raise' : 'Seated Calf Raise';
      default: return 'Custom Exercise';
    }
  }
}
