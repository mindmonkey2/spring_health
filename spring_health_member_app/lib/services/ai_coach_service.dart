import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/health_profile_model.dart';
import '../models/fitness_test_model.dart';
import '../models/member_model.dart';

class AiCoachService {
  final FirebaseFirestore _db;

  AiCoachService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      temperature: 0.4,
      maxOutputTokens: 2048,
    ),
  );

  Future<Map<String, dynamic>?> getCachedWorkoutPlan(String memberId) async {
    try {
      final docRef = _db.collection('aiPlans').doc(memberId).collection('current').doc('plan');
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        return docSnap.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCachedDietPlan(String memberId) async {
    try {
      final docRef = _db.collection('dietPlans').doc(memberId).collection('current').doc('plan');
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        return docSnap.data();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> generateDietPlan(String memberId) async {
    try {
      final healthDoc = await _db.collection('healthProfiles').doc(memberId).get();
      if (!healthDoc.exists) throw Exception('Health profile not found');
      final healthProfile = HealthProfileModel.fromMap(healthDoc.data()!, healthDoc.id);

      final fitnessTestSnap = await _db
          .collection('fitnessTests')
          .doc(memberId)
          .collection('tests')
          .orderBy('testedAt', descending: true)
          .limit(1)
          .get();

      FitnessTestModel? latestTest;
      if (fitnessTestSnap.docs.isNotEmpty) {
        final data = fitnessTestSnap.docs.first.data();
        final id = fitnessTestSnap.docs.first.id;
        latestTest = FitnessTestModel.fromMap(data, id);
      }

      final cachedPlan = await getCachedDietPlan(memberId);
      if (cachedPlan != null && cachedPlan['generatedAt'] != null) {
        final generatedAt = cachedPlan['generatedAt'] as Timestamp;
        final difference = DateTime.now().difference(generatedAt.toDate());
        if (difference.inHours < 24) {
          return cachedPlan;
        }
      }

      // BP Safety Gate
      if ((healthProfile.bpSystolic != null && healthProfile.bpSystolic! > 180) ||
          (healthProfile.bpDiastolic != null && healthProfile.bpDiastolic! > 120)) {
        throw Exception('medical_hold: BP reading requires medical clearance before exercise. Please consult a doctor.');
      }

      String medicalConditionsStr = '';
      if (healthProfile.medicalConditions.isNotEmpty) {
        medicalConditionsStr = '\n  - Medical conditions: ${healthProfile.medicalConditions.join(', ')}';
        if (healthProfile.medicalConditions.any((e) => e.toLowerCase().contains('diabetes'))) {
          medicalConditionsStr += '\n    * Important: include low GI foods, reduce simple carbs';
        }
        if (healthProfile.medicalConditions.any((e) => e.toLowerCase().contains('hypertension')) || (healthProfile.bpSystolic != null && healthProfile.bpSystolic! >= 130)) {
          medicalConditionsStr += '\n    * Important: include DASH diet principles, reduce sodium';
        }
      }

      final dietaryPref = healthProfile.dietaryPreference?.isNotEmpty == true ? healthProfile.dietaryPreference! : 'No specific preference';

      final String prompt = '''
  You are an expert certified sports nutritionist and dietitian.
  Generate a personalized 5-meal daily diet plan for this gym member.
  Respond ONLY with valid JSON — no text outside the JSON object.

  MEMBER PROFILE:
  - Weight: ${healthProfile.weightKg}kg, Height: ${healthProfile.heightCm}cm, BMI: ${healthProfile.bmi}
  - Fitness Goal: ${healthProfile.fitnessGoal}
  - Activity Level: ${latestTest?.overallLevel ?? 'Beginner'}

  HEALTH FLAGS:$medicalConditionsStr
  - Dietary Preference: $dietaryPref
  - Use Indian food context (roti, dal, rice, sabzi, paneer, chicken, eggs, curd, fruits common in India)
  - Align with ICMR recommended dietary allowances for Indians
  - Structure: 5 meals — breakfast, mid-morning snack, lunch, evening snack, dinner

  RESPOND WITH THIS EXACT JSON STRUCTURE:
  {
    "dailyTargets": {
      "calories": 2200,
      "proteinG": 140,
      "carbsG": 250,
      "fatG": 65
    },
    "meals": [
      {
        "mealName": "Breakfast",
        "timing": "7:00 AM - 8:00 AM",
        "foods": [
          {
            "name": "string",
            "quantity": "string",
            "approxCalories": 150
          }
        ],
        "totalCalories": 450
      }
    ],
    "hydrationLitres": 3.0,
    "nutritionNotes": "string",
    "bpDietNote": "string or null"
  }''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonString = response.text ?? '';

      Map<String, dynamic> planJson;
      try {
        planJson = jsonDecode(jsonString);
      } catch (e) {
        throw Exception('AI returned malformed JSON: ${e.toString()}');
      }

      if (!planJson.containsKey('meals') || (planJson['meals'] as List).isEmpty) {
        throw Exception('AI returned invalid plan structure');
      }

      final docData = {
        'dailyTargets': planJson['dailyTargets'],
        'meals': planJson['meals'],
        'hydrationLitres': planJson['hydrationLitres'],
        'nutritionNotes': planJson['nutritionNotes'],
        'bpDietNote': planJson['bpDietNote'],
        'memberId': memberId,
        'generatedAt': Timestamp.now(),
      };

      await _db.collection('dietPlans').doc(memberId).collection('current').doc('plan').set(docData, SetOptions(merge: true));

      return docData;
    } catch (e) {
      throw Exception('Failed to generate diet plan: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> generateWorkoutPlan(String memberId) async {
    try {
      // 1. Read healthProfiles/{memberId} → HealthProfileModel
      final healthDoc = await _db.collection('healthProfiles').doc(memberId).get();
      if (!healthDoc.exists) throw Exception('Health profile not found');
      final healthProfile = HealthProfileModel.fromMap(healthDoc.data()!, healthDoc.id);

      // 2. Read fitnessTests/{memberId}/tests — get latest by testedAt
      final fitnessTestSnap = await _db
          .collection('fitnessTests')
          .doc(memberId)
          .collection('tests')
          .orderBy('testedAt', descending: true)
          .limit(1)
          .get();

      FitnessTestModel? latestTest;
      if (fitnessTestSnap.docs.isNotEmpty) {
        final data = fitnessTestSnap.docs.first.data();
        final id = fitnessTestSnap.docs.first.id;
        latestTest = FitnessTestModel.fromMap(data, id);
      }

      // 3. Read members/{memberId} — get plan, branchId, branchName
      final memberDoc = await _db.collection('members').doc(memberId).get();
      if (!memberDoc.exists) throw Exception('Member not found');
      final memberModel = MemberModel.fromMap(memberDoc.data()!);

      // 4. Read attendance last 7 days — count recent sessions
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final attendanceSnap = await _db
          .collection('attendance')
          .where('memberId', isEqualTo: memberId)
          .where('checkInTime', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();
      // recentSessions unused, but read per instructions
      // ignore: unused_local_variable
      final int recentSessions = attendanceSnap.docs.length;

      // 5. Read aiPlans/{memberId}/current — check lastGeneratedAt
      final cachedPlan = await getCachedWorkoutPlan(memberId);
      if (cachedPlan != null && cachedPlan['generatedAt'] != null) {
        final generatedAt = cachedPlan['generatedAt'] as Timestamp;
        final difference = DateTime.now().difference(generatedAt.toDate());
        if (difference.inHours < 24) {
          return cachedPlan;
        }
      }

      // BP Safety Gate
      if ((healthProfile.bpSystolic != null && healthProfile.bpSystolic! > 180) ||
          (healthProfile.bpDiastolic != null && healthProfile.bpDiastolic! > 120)) {
        throw Exception('medical_hold: BP reading requires medical clearance before exercise. Please consult a doctor.');
      }

      // Extract branchName (if available, else empty)
      final branchName = memberModel.branch.isNotEmpty ? memberModel.branch : 'Main Branch';

      // BP String
      String bpString = '';
      if (healthProfile.bpSystolic != null && healthProfile.bpDiastolic != null) {
        bpString = '''
  - Blood Pressure: ${healthProfile.bpSystolic}/${healthProfile.bpDiastolic} mmHg (${HealthProfileModel.bpCategory(healthProfile.bpSystolic!, healthProfile.bpDiastolic!)})
  - If elevated/Stage 1: keep RPE under 7, no Valsalva maneuver, prioritize aerobic warm-up minimum 10 minutes''';
      }

      String medicalConditionsStr = '';
      if (healthProfile.medicalConditions.isNotEmpty) {
        medicalConditionsStr = '\n  - Medical conditions: ${healthProfile.medicalConditions.join(', ')}';
      }

      String jointRestrictionsStr = '';
      if (healthProfile.jointRestrictions.isNotEmpty) {
        jointRestrictionsStr = '\n  - Joint restrictions: ${healthProfile.jointRestrictions.join(', ')} — avoid exercises that directly load these joints, provide substitutes';
      }

      // Build prompt string
      final String prompt = '''
  You are an expert certified personal trainer and exercise physiologist.
  Generate a personalized 7-day workout plan for this gym member.
  Respond ONLY with valid JSON — no text outside the JSON object.

  MEMBER PROFILE:
  - Age: unknown, Gender: unknown
  - Weight: ${healthProfile.weightKg}kg, Height: ${healthProfile.heightCm}cm, BMI: ${healthProfile.bmi}
  - Fitness Goal: ${healthProfile.fitnessGoal}
  - Fitness Level: ${latestTest?.overallLevel ?? 'Beginner'}
  - Days available per week: 4
  - Session duration: 60 minutes

  HEALTH FLAGS:$bpString$medicalConditionsStr$jointRestrictionsStr

  FITNESS BASELINE:
  - Pushups max: ${latestTest?.pushupsMax ?? 'unknown'}
  - Pullups max: ${latestTest?.pullupsMax ?? 'unknown'}
  - Plank: ${latestTest?.plankSeconds ?? 'unknown'} seconds
  - Squat 1RM: ${latestTest?.squat1rmKg ?? 'estimate from level'} kg
  - Deadlift 1RM: ${latestTest?.deadlift1rmKg ?? 'estimate from level'} kg

  GYM: Spring Health Studio, $branchName branch, Warangal, India
  Available equipment: standard gym equipment including barbells, dumbbells, cables, machines

  RULES:
  1. Day 7 must be active recovery or mobility only
  2. Include warm-up and cool-down in every session
  3. Each exercise must have sets, reps/duration, rest seconds, and one coaching cue sentence
  4. Match exercises to available equipment only
  5. Progressive overload: each session slightly harder than previous same muscle group session

  RESPOND WITH THIS EXACT JSON STRUCTURE:
  {
    "weeklyPlan": [
      {
        "day": 1,
        "sessionType": "string",
        "estimatedMinutes": 60,
        "isRestDay": false,
        "exercises": [
          {
            "name": "string",
            "sets": 3,
            "reps": "10",
            "restSeconds": 90,
            "coachingCue": "string",
            "muscleGroups": ["string"]
          }
        ]
      }
    ],
    "weeklyFocus": "string",
    "coachNote": "string (2-3 personalized sentences)",
    "bpNote": "string or null"
  }''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final jsonString = response.text ?? '';

      Map<String, dynamic> planJson;
      try {
        planJson = jsonDecode(jsonString);
      } catch (e) {
        throw Exception('AI returned malformed JSON: ${e.toString()}');
      }

      if (!planJson.containsKey('weeklyPlan') || (planJson['weeklyPlan'] as List).length != 7) {
        throw Exception('AI returned invalid plan structure');
      }

      final docData = {
        'weeklyPlan': planJson['weeklyPlan'],
        'weeklyFocus': planJson['weeklyFocus'],
        'coachNote': planJson['coachNote'],
        'bpNote': planJson['bpNote'],
        'memberId': memberId,
        'status': 'active',
        'generatedAt': Timestamp.now(),
        'basedOn': {
          'goal': healthProfile.fitnessGoal,
          'fitnessLevel': latestTest?.overallLevel,
          'bpSystolic': healthProfile.bpSystolic,
          'bpDiastolic': healthProfile.bpDiastolic,
        }
      };

      // The instructions say "Write to Firestore — aiPlans/{memberId}/current".
      // Assuming 'current' is a document within the 'aiPlans' subcollection for memberId. Wait.
      // Firestore path aiPlans/{memberId}/current can be created as a subcollection doc.
      await _db.collection('aiPlans').doc(memberId).collection('current').doc('plan').set(docData, SetOptions(merge: true));

      return docData;
    } catch (e) {
      throw Exception('Failed to generate workout plan: ${e.toString()}');
    }
  }
}
