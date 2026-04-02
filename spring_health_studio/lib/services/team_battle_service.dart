import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_battle_model.dart';

class TeamBattleService {
  static final TeamBattleService instance = TeamBattleService._();
  TeamBattleService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createBattle({
    required String organizerTrainerId,
    required String organizerName,
    required String team1Name,
    required List<String> team1MemberIds,
    required String team2TrainerId,
    required String team2Name,
    required List<String> team2MemberIds,
    required String metric,
    required String title,
    required int durationDays,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: durationDays));

    final docRef = _firestore.collection('trainerTeamBattles').doc();

    final battle = TeamBattleModel(
      id: docRef.id,
      organizerTrainerId: organizerTrainerId,
      organizerName: organizerName,
      team1: {
        'trainerId': organizerTrainerId,
        'trainerName': organizerName, // Simplified
        'name': team1Name,
        'memberIds': team1MemberIds,
      },
      team2: {
        'trainerId': team2TrainerId,
        'trainerName': team2TrainerId, // simplified
        'name': team2Name,
        'memberIds': team2MemberIds,
      },
      metric: metric,
      title: title,
      durationDays: durationDays,
      startDate: now,
      endDate: endDate,
      team1Score: 0.0,
      team2Score: 0.0,
      status: 'active',
      winnerId: '',
      createdAt: now,
    );

    await docRef.set(battle.toMap());
    return docRef.id;
  }

  Stream<List<TeamBattleModel>> getActiveBattlesForTrainer(String trainerId) {
    return _firestore
        .collection('trainerTeamBattles')
        .where('organizerTrainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final battles = snapshot.docs
          .map((doc) => TeamBattleModel.fromMap(doc.data(), doc.id))
          .toList();
      battles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return battles;
    });
  }

  Future<void> computeAndUpdateScores(String battleId) async {
    final docRef = _firestore.collection('trainerTeamBattles').doc(battleId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) return;

    final battle = TeamBattleModel.fromMap(docSnap.data()!, docSnap.id);
    if (battle.status == 'complete') return; // already completed

    double t1Score = 0.0;
    // double t2Score = battle.team2Score; // Team 2 is manual

    final t1MemberIds = List<String>.from(battle.team1['memberIds'] ?? []);
    final startTimestamp = Timestamp.fromDate(battle.startDate);

    // Note: workouts uses `memberId` field too, so we can query it easily.
    if (battle.metric == 'total_sessions') {
      for (final mId in t1MemberIds) {
        final snap = await _firestore.collection('workouts')
            .where('memberId', isEqualTo: mId)
            .where('date', isGreaterThanOrEqualTo: startTimestamp)
            .get();
        t1Score += snap.docs.length;
      }
    } else if (battle.metric == 'total_weight_lifted') {
      for (final mId in t1MemberIds) {
        final snap = await _firestore.collection('workouts')
            .where('memberId', isEqualTo: mId)
            .where('date', isGreaterThanOrEqualTo: startTimestamp)
            .get();
        for (final doc in snap.docs) {
          final data = doc.data();
          final exercises = List.from(data['exercises'] ?? []);
          for (final ex in exercises) {
            final sets = List.from(ex['sets'] ?? []);
            for (final s in sets) {
              if (s['isCompleted'] == true) {
                final weight = (s['weightKg'] as num?)?.toDouble() ?? 0.0;
                final reps = (s['reps'] as num?)?.toInt() ?? 0;
                t1Score += weight * reps; // typical calculation or just weight
              }
            }
          }
        }
      }
    } else if (battle.metric == 'combined_attendance_days') {
      for (final mId in t1MemberIds) {
        final snap = await _firestore.collection('attendance')
            .where('memberId', isEqualTo: mId)
            .where('checkInTime', isGreaterThanOrEqualTo: startTimestamp)
            .get();
        t1Score += snap.docs.length;
      }
    }

    final updates = <String, dynamic>{
      'team1Score': t1Score,
    };

    final now = DateTime.now();
    if (now.isAfter(battle.endDate)) {
      updates['status'] = 'complete';
      double t2Score = battle.team2Score;
      if (t1Score > t2Score) {
        updates['winnerId'] = 'team1';
      } else if (t2Score > t1Score) {
        updates['winnerId'] = 'team2';
      } else {
        updates['winnerId'] = 'draw';
      }
    }

    await docRef.update(updates);
  }
}
