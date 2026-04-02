import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerAjaxService {
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
