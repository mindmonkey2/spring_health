import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerAjaxService {
  static Future<void> analyzeAndGenerate({
    required String memberId,
    required String memberAuthUid,
    required String sessionId,
  }) async {
    final db = FirebaseFirestore.instance;
    final nowTime = DateTime.now();
    final todayString = '${nowTime.year}-${nowTime.month.toString().padLeft(2, '0')}-${nowTime.day.toString().padLeft(2, '0')}';

    final queryResults = await Future.wait([
      db.collection('workouts')
          .where('memberId', isEqualTo: memberId)
          .orderBy('date', descending: true)
          .limit(7)
          .get(),
      db.collection('personalbests').doc(memberId).get(),
      db.collection('healthProfiles').doc(memberId).get(),
      db.collection('aiPlans').doc(memberAuthUid).collection('current').doc('current').get(),
      db.collection('wearableSnapshots').doc(memberAuthUid).collection('daily').doc(todayString).get(),
      db.collection('members').doc(memberId).get(),
    ]);

    final recentWorkouts = queryResults[0] as QuerySnapshot;
    final pbDoc = queryResults[1] as DocumentSnapshot;
    final healthDoc = queryResults[2] as DocumentSnapshot;
    final aiPlanDoc = queryResults[3] as DocumentSnapshot;
    final wearableDoc = queryResults[4] as DocumentSnapshot;
    final memberDoc = queryResults[5] as DocumentSnapshot;

    if (healthDoc.exists) {
      final healthInfo = healthDoc.data() as Map<String, dynamic>? ?? {};
      final isMedicalHold = healthInfo['medicalHold'] as bool? ?? false;
      final holdReasonText = healthInfo['holdReason'] as String? ?? '';

      if (isMedicalHold) {
        await db.collection('sessions').doc(sessionId).set({
          'status': 'medical_hold',
          'medicalHoldReason': holdReasonText,
          'aiSummary': 'Medical hold active — no workout generated. Consult member health profile.',
        }, SetOptions(merge: true));
        return;
      }

      await db.collection('sessions').doc(sessionId).set({
        'memberConditions': List<String>.from(healthInfo['conditions'] ?? []),
        'memberAllergies': List<String>.from(healthInfo['allergies'] ?? []),
      }, SetOptions(merge: true));
    }

    final memberInfo = memberDoc.data() as Map<String, dynamic>? ?? {};
    final isPremium = ((memberInfo['category'] as String?)?.toLowerCase() ?? 'standard') == 'premium';
    final totalExercises = isPremium ? 6 : 4;

    List<String> musclesToAvoid = [];
    if (recentWorkouts.docs.isNotEmpty) {
      final lastWorkout = recentWorkouts.docs.first.data() as Map<String, dynamic>;
      final lastWorkoutDate = (lastWorkout['date'] as Timestamp?)?.toDate();
      if (lastWorkoutDate != null && nowTime.difference(lastWorkoutDate).inDays <= 1) {
        musclesToAvoid.addAll(List<String>.from(lastWorkout['musclesWorked'] ?? []));
      }
    }

    final wearableInfo = wearableDoc.data() as Map<String, dynamic>?;
    final recovery = (wearableInfo?['recoveryScore'] as num?)?.toInt() ?? 100;
    final reduceSets = recovery < 40 ? 1 : 0;

    final allMuscleGroups = ['chest', 'back', 'shoulders', 'biceps', 'triceps', 'quads', 'hamstrings', 'glutes', 'core', 'calves'];
    var availableGroups = allMuscleGroups.where((m) => !musclesToAvoid.contains(m)).toList();
    if (availableGroups.isEmpty) availableGroups.addAll(allMuscleGroups);

    final pbInfo = pbDoc.data() as Map<String, dynamic>? ?? {};
    List<Map<String, dynamic>> exercisesList = [];

    final compoundList = ['Squat', 'Deadlift', 'Bench Press', 'Barbell Row'];
    final chosenCompound = compoundList[nowTime.microsecond % compoundList.length];

    double weightForCompound = 20.0;
    if (pbInfo.containsKey(chosenCompound)) {
      weightForCompound = ((pbInfo[chosenCompound]['weightKg'] as num?)?.toDouble() ?? 20.0) * 0.85;
    }

    exercisesList.add({
      'exerciseName': chosenCompound,
      'sets': (4 - reduceSets > 0) ? 4 - reduceSets : 1,
      'reps': 8,
      'weightKg': weightForCompound,
      'targetMuscles': _getMusclesForCompound(chosenCompound),
      'status': 'active',
      'completedSets': 0,
      'trainerNote': (recovery < 40) ? 'Lighter session due to low recovery.' : '',
    });

    for (int idx = 1; idx < totalExercises; idx++) {
      final targetMuscle = availableGroups[idx % availableGroups.length];
      final exName = _getExerciseForMuscle(targetMuscle, idx);

      double exWeight = 10.0;
      if (pbInfo.containsKey(exName)) {
        exWeight = ((pbInfo[exName]['weightKg'] as num?)?.toDouble() ?? 10.0) * 0.85;
      }

      exercisesList.add({
        'exerciseName': exName,
        'sets': (3 - reduceSets > 0) ? 3 - reduceSets : 1,
        'reps': 10,
        'weightKg': exWeight,
        'targetMuscles': [targetMuscle],
        'status': 'pending',
        'completedSets': 0,
        'trainerNote': '',
      });
    }

    String upcomingFocus = availableGroups.last;
    if (musclesToAvoid.isNotEmpty) upcomingFocus = musclesToAvoid.first;
    if (aiPlanDoc.exists) {
      final aiInfo = aiPlanDoc.data() as Map<String, dynamic>?;
      if (aiInfo != null && aiInfo.containsKey('currentFocus')) {
        final f = aiInfo['currentFocus'] as String;
        if (f.isNotEmpty) upcomingFocus = f;
      }
    }

    await db.collection('sessions').doc(sessionId).set({
      'exercises': exercisesList,
      'status': 'planning',
      'aiSummary': 'Generated session focused on ${availableGroups.take(2).join(' and ')}.',
      'nextSessionFocus': upcomingFocus,
    }, SetOptions(merge: true));
  }

  static Future<List<Map<String, dynamic>>> generateStretching(List<String> musclesWorked) async {
    const stretchesDict = {
      'chest':     [{ 'exerciseName': 'Doorway Chest Stretch', 'durationSeconds': 30, 'targetMuscle': 'chest' }],
      'back':      [{ 'exerciseName': 'Child\'s Pose', 'durationSeconds': 40, 'targetMuscle': 'back' }],
      'shoulders': [{ 'exerciseName': 'Cross-Body Shoulder Stretch', 'durationSeconds': 30, 'targetMuscle': 'shoulders' }],
      'biceps':    [{ 'exerciseName': 'Wrist Flexor Stretch', 'durationSeconds': 30, 'targetMuscle': 'biceps' }],
      'triceps':   [{ 'exerciseName': 'Overhead Tricep Stretch', 'durationSeconds': 30, 'targetMuscle': 'triceps' }],
      'quads':     [{ 'exerciseName': 'Standing Quad Stretch', 'durationSeconds': 35, 'targetMuscle': 'quads' }],
      'hamstrings':[{ 'exerciseName': 'Seated Hamstring Stretch', 'durationSeconds': 40, 'targetMuscle': 'hamstrings' }],
      'glutes':    [{ 'exerciseName': 'Pigeon Pose', 'durationSeconds': 40, 'targetMuscle': 'glutes' }],
      'core':      [{ 'exerciseName': 'Cobra Stretch', 'durationSeconds': 30, 'targetMuscle': 'core' }],
      'calves':    [{ 'exerciseName': 'Standing Calf Stretch', 'durationSeconds': 30, 'targetMuscle': 'calves' }],
    };

    final stretchesResult = <Map<String, dynamic>>[];
    for (final m in musclesWorked) {
      if (stretchesDict.containsKey(m)) {
        for (final st in stretchesDict[m]!) {
          stretchesResult.add({ ...st, 'status': 'pending' });
        }
      }
    }

    final uniqueNames = <String>{};
    final finalStretches = stretchesResult.where((item) => uniqueNames.add(item['exerciseName'] as String)).take(6).toList();

    if (finalStretches.isEmpty) {
      return [
        { 'exerciseName': 'Standing Forward Fold', 'durationSeconds': 40, 'targetMuscle': 'full body', 'status': 'pending' },
        { 'exerciseName': 'Child\'s Pose', 'durationSeconds': 40, 'targetMuscle': 'back', 'status': 'pending' },
        { 'exerciseName': 'Hip Flexor Stretch', 'durationSeconds': 35, 'targetMuscle': 'hip flexors', 'status': 'pending' },
      ];
    }
    return finalStretches;
  }

  static Future<void> finalizeSession(String sessionId) async {
    final database = FirebaseFirestore.instance;
    final sessionRef = database.collection('sessions').doc(sessionId);

    // Initial read for session data
    final initialSessionSnap = await sessionRef.get();
    if (!initialSessionSnap.exists) return;

    final initialData = initialSessionSnap.data()!;
    if (initialData['sessionXpAwarded'] == true) return;

    final mId = initialData['memberId'] as String;

    // Read current personal bests to check for updates
    final pbDoc = await database.collection('personalbests').doc(mId).get();
    final sData = initialData; // Already have session data

    final mAuthUid = sData['memberAuthUid'] as String;
    final tId = sData['trainerId'] as String;
    final sessionExercises = List<Map<String, dynamic>>.from(sData['exercises'] ?? []);
    final sessionMuscles = List<String>.from(sData['musclesWorked'] ?? []);
    final cTime = (sData['createdAt'] as Timestamp).toDate();

    final now = DateTime.now();
    final nowTimestamp = Timestamp.fromDate(now);
    final dMinutes = now.difference(cTime).inMinutes;

    final wExercises = sessionExercises.map((e) {
      final cSets = (e['completedSets'] as int?) ?? 0;
      return {
        'name': e['exerciseName'],
        'category': 'Trainer Session',
        'sets': List.generate(
            cSets,
            (j) => {
                  'setNumber': j + 1,
                  'weight': e['weightKg'] ?? 0,
                  'reps': e['reps'] ?? 0,
                  'isCompleted': true,
                }),
      };
    }).toList();

    final batch = database.batch();

    // 1. Add Workout
    final workoutRef = database.collection('workouts').doc();
    batch.set(workoutRef, {
      'memberId': mId,
      'memberAuthUid': mAuthUid,
      'exercises': wExercises,
      'durationMinutes': dMinutes,
      'date': nowTimestamp,
      'source': 'trainer_session',
      'sessionId': sessionId,
      'trainerId': tId,
      'musclesWorked': sessionMuscles,
    });

    // 2. Personal Bests
    final pbMap = Map<String, dynamic>.from(pbDoc.data() ?? {});
    final newPbs = <String, dynamic>{};
    for (final exItem in sessionExercises) {
      final n = exItem['exerciseName'] as String;
      final w = (exItem['weightKg'] as num?)?.toDouble() ?? 0.0;
      if (w <= 0) continue;
      final oldW = (pbMap[n]?['weightKg'] as num?)?.toDouble() ?? 0.0;
      if (w > oldW) {
        newPbs[n] = {'weightKg': w, 'reps': exItem['reps'] ?? 0, 'date': nowTimestamp};
      }
    }
    if (newPbs.isNotEmpty) {
      batch.set(database.collection('personalbests').doc(mId), newPbs, SetOptions(merge: true));
    }

    // 3. Gamification Event
    final eventRef = database.collection('gamification_events').doc();
    batch.set(eventRef, {
      'memberId': mId,
      'type': 'trainer_session_complete',
      'xp': 100,
      'processed': false,
      'createdAt': nowTimestamp,
    });

    // 4. Wearable Snapshot
    final dKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    batch.set(
        database.collection('wearableSnapshots').doc(mAuthUid).collection('daily').doc(dKey),
        {
          'musclesWorked': sessionMuscles,
          'sessionDurationMinutes': dMinutes,
          'source': 'trainer_session',
          'sessionId': sessionId,
          'nextSessionFocus': sData['nextSessionFocus'] ?? '',
        },
        SetOptions(merge: true));

    // 5. Notification
    final tNotes = sData['trainerNotes'] as String? ?? '';
    final aSum = sData['aiSummary'] as String? ?? '';
    final nBody = tNotes.isNotEmpty
        ? (tNotes.length > 100 ? '${tNotes.substring(0, 100)}...' : tNotes)
        : (aSum.isNotEmpty ? aSum : 'Session complete. Your diet plan is ready.');

    final notifRef = database.collection('notifications').doc(mAuthUid).collection('items').doc();
    batch.set(notifRef, {
      'type': 'session_complete',
      'title': 'Great session!',
      'body': nBody,
      'read': false,
      'createdAt': nowTimestamp,
    });

    // 6. Session Update
    batch.update(sessionRef, {
      'sessionXpAwarded': true,
      'status': 'complete',
      'completedAt': nowTimestamp,
    });

    await batch.commit();
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
