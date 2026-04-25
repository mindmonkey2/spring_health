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

  Future<double> _getScoreForMetric(
      String metric, List<String> memberIds, Timestamp startTimestamp) async {
    if (memberIds.isEmpty) return 0.0;

    final chunks = <List<String>>[];
    for (var i = 0; i < memberIds.length; i += 30) {
      chunks.add(memberIds.sublist(
          i, i + 30 > memberIds.length ? memberIds.length : i + 30));
    }

    double score = 0.0;

    if (metric == 'total_sessions') {
      final futures = chunks.map((chunk) => _firestore
          .collection('workouts')
          .where('memberId', whereIn: chunk)
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .count()
          .get());
      final snaps = await Future.wait(futures);
      for (final snap in snaps) {
        score += snap.count ?? 0;
      }
    } else if (metric == 'total_weight_lifted') {
      final futures = chunks.map((chunk) => _firestore
          .collection('workouts')
          .where('memberId', whereIn: chunk)
          .where('date', isGreaterThanOrEqualTo: startTimestamp)
          .get());
      final snaps = await Future.wait(futures);
      for (final snap in snaps) {
        for (final doc in snap.docs) {
          final data = doc.data();
          final exercises = List.from(data['exercises'] ?? []);
          for (final ex in exercises) {
            final sets = List.from(ex['sets'] ?? []);
            for (final s in sets) {
              if (s['isCompleted'] == true) {
                final weight = (s['weightKg'] as num?)?.toDouble() ?? 0.0;
                final reps = (s['reps'] as num?)?.toInt() ?? 0;
                score += weight * reps;
              }
            }
          }
        }
      }
    } else if (metric == 'combined_attendance_days') {
      final futures = chunks.map((chunk) => _firestore
          .collection('attendance')
          .where('memberId', whereIn: chunk)
          .where('checkInTime', isGreaterThanOrEqualTo: startTimestamp)
          .count()
          .get());
      final snaps = await Future.wait(futures);
      for (final snap in snaps) {
        score += snap.count ?? 0;
      }
    }

    return score;
  }

  Future<void> computeAndUpdateScores(String battleId) async {
    final docRef = _firestore.collection('trainerTeamBattles').doc(battleId);
    final docSnap = await docRef.get();

    if (!docSnap.exists) return;

    final battle = TeamBattleModel.fromMap(docSnap.data()!, docSnap.id);
    if (battle.status == 'complete') return; // already completed

    final t1MemberIds = List<String>.from(battle.team1['memberIds'] ?? []);
    final startTimestamp = Timestamp.fromDate(battle.startDate);

    double t1Score =
        await _getScoreForMetric(battle.metric, t1MemberIds, startTimestamp);

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
