import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/services/gamification_service.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late GamificationService service;

  const memberId = 'member-gam-1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = GamificationService.withFirestore(fakeFirestore);
  });

  group('GamificationService.getOrCreate', () {
    test('creates a new profile when one does not exist', () async {
      final profile = await service.getOrCreate(memberId);
      expect(profile.memberId, memberId);
      expect(profile.totalXp, 0);
      expect(profile.currentStreak, 0);
      expect(profile.earnedBadgeIds, isEmpty);
    });

    test('persists the new profile to Firestore', () async {
      await service.getOrCreate(memberId);
      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      expect(doc.exists, isTrue);
    });

    test('returns existing profile when one already exists', () async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 500,
        'currentStreak': 3,
        'longestStreak': 5,
        'totalCheckIns': 10,
        'totalWorkouts': 4,
        'totalVolumeKg': 200,
        'earnedBadgeIds': ['first_checkin'],
        'recentXpEvents': [],
        'warWins': 0,
        'loyaltyMilestonesAwarded': [],
      });

      final profile = await service.getOrCreate(memberId);
      expect(profile.totalXp, 500);
      expect(profile.currentStreak, 3);
      expect(profile.earnedBadgeIds, contains('first_checkin'));
    });

    test('does not overwrite existing profile', () async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 999,
        'currentStreak': 7,
        'longestStreak': 7,
        'totalCheckIns': 20,
        'totalWorkouts': 10,
        'totalVolumeKg': 500,
        'earnedBadgeIds': [],
        'recentXpEvents': [],
        'warWins': 0,
        'loyaltyMilestonesAwarded': [],
      });

      await service.getOrCreate(memberId);
      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      expect(doc.data()!['totalXp'], 999);
    });
  });

  group('GamificationService.calculateStreak', () {
    Future<void> addCheckIn(DateTime date) async {
      await fakeFirestore.collection('attendance').add({
        'memberId': memberId,
        'checkInTime': Timestamp.fromDate(date),
      });
    }

    Future<void> seedGamification() async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'totalCheckIns': 0,
        'totalWorkouts': 0,
        'totalVolumeKg': 0,
        'earnedBadgeIds': [],
        'recentXpEvents': [],
        'warWins': 0,
        'loyaltyMilestonesAwarded': [],
      });
    }

    test('returns 0 and resets when no attendance records exist', () async {
      await seedGamification();
      final streak = await service.calculateStreak(memberId);
      expect(streak, 0);
    });

    test('returns streak of 1 for a single check-in today', () async {
      await seedGamification();
      final today = DateTime.now();
      await addCheckIn(DateTime(today.year, today.month, today.day, 10));
      final streak = await service.calculateStreak(memberId);
      expect(streak, 1);
    });

    test('returns streak of 3 for 3 consecutive days ending today', () async {
      await seedGamification();
      final today = DateTime.now();
      for (int i = 0; i < 3; i++) {
        await addCheckIn(DateTime(today.year, today.month, today.day).subtract(Duration(days: i)));
      }
      final streak = await service.calculateStreak(memberId);
      expect(streak, 3);
    });

    test('streak resets after a gap day', () async {
      await seedGamification();
      final today = DateTime.now();
      // Check in today and 2 days ago — gap on yesterday breaks the streak
      await addCheckIn(DateTime(today.year, today.month, today.day));
      await addCheckIn(DateTime(today.year, today.month, today.day).subtract(const Duration(days: 2)));

      final streak = await service.calculateStreak(memberId);
      expect(streak, 1);
    });

    test('counts streak starting from yesterday when no check-in today', () async {
      await seedGamification();
      final today = DateTime.now();
      final yesterday = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 1));
      final dayBefore = yesterday.subtract(const Duration(days: 1));
      await addCheckIn(yesterday);
      await addCheckIn(dayBefore);

      final streak = await service.calculateStreak(memberId);
      expect(streak, 2);
    });

    test('updates longestStreak when current streak is higher', () async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 0,
        'currentStreak': 0,
        'longestStreak': 2,
        'totalCheckIns': 0,
        'totalWorkouts': 0,
        'totalVolumeKg': 0,
        'earnedBadgeIds': [],
        'recentXpEvents': [],
        'warWins': 0,
        'loyaltyMilestonesAwarded': [],
      });
      final today = DateTime.now();
      for (int i = 0; i < 4; i++) {
        await addCheckIn(DateTime(today.year, today.month, today.day).subtract(Duration(days: i)));
      }
      await service.calculateStreak(memberId);
      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      expect(doc.data()!['longestStreak'], 4);
    });

    test('does not lower longestStreak below existing value', () async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 0,
        'currentStreak': 0,
        'longestStreak': 30,
        'totalCheckIns': 0,
        'totalWorkouts': 0,
        'totalVolumeKg': 0,
        'earnedBadgeIds': [],
        'recentXpEvents': [],
        'warWins': 0,
        'loyaltyMilestonesAwarded': [],
      });
      final today = DateTime.now();
      await addCheckIn(DateTime(today.year, today.month, today.day));
      await service.calculateStreak(memberId);
      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      expect(doc.data()!['longestStreak'], 30);
    });

    test('deduplicates multiple check-ins on the same day', () async {
      await seedGamification();
      final today = DateTime.now();
      // Two check-ins on the same day should still count as streak 1
      await addCheckIn(DateTime(today.year, today.month, today.day, 9));
      await addCheckIn(DateTime(today.year, today.month, today.day, 18));
      final streak = await service.calculateStreak(memberId);
      expect(streak, 1);
    });
  });

  group('GamificationService.processEvent (Social Hooks)', () {
    Future<void> seedGamification() async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 0,
        'currentStreak': 0,
        'longestStreak': 0,
        'totalCheckIns': 0,
        'totalWorkouts': 0,
        'totalVolumeKg': 0,
        'earnedBadgeIds': [],
        'recentXpEvents': [],
        'warWins': 0,
        'loyaltyMilestonesAwarded': [],
      });
    }

    test('awards 50 XP for first_post and records in loyaltyMilestonesAwarded', () async {
      await seedGamification();
      await service.processEvent('first_post', memberId);

      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      final data = doc.data()!;
      expect(data['totalXp'], 50);
      expect(data['loyaltyMilestonesAwarded'], contains('first_post'));
    });

    test('first_post is idempotent (does not award XP twice)', () async {
      await seedGamification();
      await service.processEvent('first_post', memberId);
      await service.processEvent('first_post', memberId);

      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      expect(doc.data()!['totalXp'], 50); // XP should remain 50, not 100
    });

    test('awards 20 XP for post_popular', () async {
      await seedGamification();
      await service.processEvent('post_popular', memberId);

      final doc = await fakeFirestore.collection('gamification').doc(memberId).get();
      expect(doc.data()!['totalXp'], 20);
    });
  });

  group('GamificationService.stream', () {
    test('emits empty profile when document does not exist', () async {
      final profile = await service.stream(memberId).first;
      expect(profile.memberId, memberId);
      expect(profile.totalXp, 0);
    });

    test('emits existing profile data', () async {
      await fakeFirestore.collection('gamification').doc(memberId).set({
        'memberId': memberId,
        'totalXp': 750,
        'currentStreak': 5,
        'longestStreak': 10,
        'totalCheckIns': 15,
        'totalWorkouts': 8,
        'totalVolumeKg': 300,
        'earnedBadgeIds': ['first_checkin', 'streak_7'],
        'recentXpEvents': [],
        'warWins': 1,
        'loyaltyMilestonesAwarded': [],
      });
      final profile = await service.stream(memberId).first;
      expect(profile.totalXp, 750);
      expect(profile.currentStreak, 5);
      expect(profile.earnedBadgeIds, contains('streak_7'));
    });
  });
}
