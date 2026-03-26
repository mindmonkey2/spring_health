import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/challenge_model.dart';

class ChallengeService {
  final _db = FirebaseFirestore.instance;

  // ── Streams ───────────────────────────────────────────────────────────────

  Stream<ChallengeModel?> getActiveChallengeStream() => _db
      .collection('challenges')
      .where('status', isEqualTo: 'active')
      .limit(1)
      .snapshots()
      .map(
        (s) => s.docs.isEmpty
            ? null
            : ChallengeModel.fromFirestore(
                s.docs.first.data(),
                s.docs.first.id,
              ),
      );

  Stream<List<ChallengeEntryModel>> getEntriesStream(String challengeId) => _db
      .collection('challengeEntries')
      .where('challengeId', isEqualTo: challengeId)
      .orderBy('score', descending: true)
      .snapshots()
      .map(
        (s) => s.docs
            .map((d) => ChallengeEntryModel.fromFirestore(d.data(), d.id))
            .toList(),
      );

  // ── Join Team ─────────────────────────────────────────────────────────────

  Future<void> joinTeam({
    required String challengeId,
    required String memberId,
    required String memberName,
    required String teamId,
  }) async {
    try {
      final batch = _db.batch();

      // Add member to team's memberIds array (dot-notation nested update)
      final challengeRef = _db.collection('challenges').doc(challengeId);
      final field = teamId == 'teamA' ? 'teamA.memberIds' : 'teamB.memberIds';
      batch.update(challengeRef, {
        field: FieldValue.arrayUnion([memberId]),
      });

      // Upsert entry with score 0
      final entryRef = _db
          .collection('challengeEntries')
          .doc('${challengeId}_$memberId');
      batch.set(
        entryRef,
        ChallengeEntryModel(
          id: '${challengeId}_$memberId',
          challengeId: challengeId,
          memberId: memberId,
          memberName: memberName,
          teamId: teamId,
          score: 0,
          lastUpdated: DateTime.now(),
        ).toMap(),
      );

      await batch.commit();
      debugPrint('ChallengeService: Joined $teamId successfully');
    } catch (e) {
      debugPrint('ChallengeService: joinTeam error — $e');
      rethrow;
    }
  }

  // ── Log Progress ──────────────────────────────────────────────────────────

  Future<void> logProgress({
    required String challengeId,
    required String memberId,
    required String memberName,
    required String teamId,
    required int newScore,
    required int previousScore,
  }) async {
    try {
      final diff = newScore - previousScore;
      final batch = _db.batch();

      // Upsert member entry doc
      final entryRef = _db
          .collection('challengeEntries')
          .doc('${challengeId}_$memberId');
      batch.set(
        entryRef,
        ChallengeEntryModel(
          id: '${challengeId}_$memberId',
          challengeId: challengeId,
          memberId: memberId,
          memberName: memberName,
          teamId: teamId,
          score: newScore,
          lastUpdated: DateTime.now(),
        ).toMap(),
      );

      // Atomically update team total (FieldValue.increment is race-safe)
      final challengeRef = _db.collection('challenges').doc(challengeId);
      final scoreField = teamId == 'teamA'
          ? 'teamA.totalScore'
          : 'teamB.totalScore';
      batch.update(challengeRef, {scoreField: FieldValue.increment(diff)});

      await batch.commit();
      debugPrint(
        'ChallengeService: Score updated — new: $newScore  diff: $diff',
      );
    } catch (e) {
      debugPrint('ChallengeService: logProgress error — $e');
      rethrow;
    }
  }

  // ── Demo Challenge ────────────────────────────────────────────────────────

  Future<void> createDemoChallenge() async {
    final now = DateTime.now();
    await _db
        .collection('challenges')
        .add(
          ChallengeModel(
            id: '',
            title: 'Step Wars — Week 1',
            type: ChallengeType.stepWars,
            status: ChallengeStatus.active,
            startDate: now,
            endDate: now.add(const Duration(days: 7)),
            teamA: const ChallengeTeam(
              id: 'teamA',
              name: 'Alpha Squad',
              emoji: '🔥',
              totalScore: 0,
              memberIds: [],
            ),
            teamB: const ChallengeTeam(
              id: 'teamB',
              name: 'Beast Mode',
              emoji: '⚡',
              totalScore: 0,
              memberIds: [],
            ),
            prizeXP: 500,
            description:
                'Walk your way to victory! Most steps at end of the week wins 500 XP each.',
            createdAt: now,
          ).toMap(),
        );
  }
}
