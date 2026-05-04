import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/models/member_model.dart';

MemberModel _base({
  DateTime? expiryDate,
  bool isArchived = false,
  String id = 'member-1',
}) {
  final now = DateTime.now();
  return MemberModel(
    id: id,
    name: 'Test Member',
    phone: '9999999999',
    branch: 'branch-a',
    membershipPlan: 'Monthly',
    joiningDate: now.subtract(const Duration(days: 30)),
    expiryDate: expiryDate ?? now.add(const Duration(days: 30)),
    isArchived: isArchived,
  );
}

void main() {
  group('MemberModel.isExpired', () {
    test('false when expiry is in the future', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 1)));
      expect(m.isExpired, isFalse);
    });

    test('true when expiry is in the past', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(m.isExpired, isTrue);
    });
  });

  group('MemberModel.isExpiringSoon', () {
    test('true when expiry is exactly 7 days away', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 7)));
      expect(m.isExpiringSoon, isTrue);
    });

    test('true when expiry is 1 day away', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 1)));
      expect(m.isExpiringSoon, isTrue);
    });

    test('false when expiry is 8 days away', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 8)));
      expect(m.isExpiringSoon, isFalse);
    });

    test('false when already expired', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(m.isExpiringSoon, isFalse);
    });
  });

  group('MemberModel.isActive', () {
    test('true when not expired and not archived', () {
      final m = _base();
      expect(m.isActive, isTrue);
    });

    test('false when expired', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(m.isActive, isFalse);
    });

    test('false when archived even if not expired', () {
      final m = _base(isArchived: true);
      expect(m.isActive, isFalse);
    });

    test('false when both expired and archived', () {
      final m = _base(
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
        isArchived: true,
      );
      expect(m.isActive, isFalse);
    });
  });

  group('MemberModel.daysLeft', () {
    test('returns 0 when expired', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 5)));
      expect(m.daysLeft, 0);
    });

    test('returns positive days when not expired', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 10)));
      expect(m.daysLeft, greaterThan(0));
    });

    test('daysRemaining is alias for daysLeft', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 15)));
      expect(m.daysRemaining, m.daysLeft);
    });
  });

  group('MemberModel aliases', () {
    test('plan returns membershipPlan', () {
      final m = _base();
      expect(m.plan, m.membershipPlan);
    });

    test('qrCode returns id', () {
      final m = _base(id: 'abc-123');
      expect(m.qrCode, 'abc-123');
    });

    test('startDate returns joiningDate', () {
      final m = _base();
      expect(m.startDate, m.joiningDate);
    });

    test('membershipStartDate returns joiningDate', () {
      final m = _base();
      expect(m.membershipStartDate, m.joiningDate);
    });

    test('membershipEndDate returns expiryDate', () {
      final m = _base();
      expect(m.membershipEndDate, m.expiryDate);
    });
  });

  group('MemberModel.fromMap', () {
    final now = DateTime(2025, 6, 1, 12);
    final ts = Timestamp.fromDate(now);

    test('parses Timestamp dates correctly', () {
      final map = {
        'name': 'Alice',
        'phone': '1234567890',
        'branch': 'main',
        'membershipPlan': 'Annual',
        'joiningDate': ts,
        'expiryDate': Timestamp.fromDate(now.add(const Duration(days: 365))),
      };
      final m = MemberModel.fromMap(map, id: 'id-1');
      expect(m.joiningDate, now);
      expect(m.id, 'id-1');
    });

    test('parses DateTime dates correctly', () {
      final map = {
        'name': 'Bob',
        'phone': '0987654321',
        'branch': 'east',
        'membershipPlan': 'Monthly',
        'joiningDate': now,
        'expiryDate': now.add(const Duration(days: 30)),
      };
      final m = MemberModel.fromMap(map);
      expect(m.joiningDate, now);
    });

    test('parses ISO-8601 String dates correctly', () {
      final map = {
        'name': 'Carol',
        'phone': '1111111111',
        'branch': 'west',
        'membershipPlan': 'Quarterly',
        'joiningDate': now.toIso8601String(),
        'expiryDate': now.add(const Duration(days: 90)).toIso8601String(),
      };
      final m = MemberModel.fromMap(map);
      expect(m.joiningDate.year, now.year);
      expect(m.joiningDate.month, now.month);
    });

    test('applies defaults for missing optional fields', () {
      final map = {
        'name': 'Dave',
        'phone': '2222222222',
        'branch': 'north',
        'membershipPlan': 'Monthly',
        'joiningDate': ts,
        'expiryDate': ts,
      };
      final m = MemberModel.fromMap(map);
      expect(m.email, '');
      expect(m.isArchived, isFalse);
      expect(m.dueAmount, 0);
      expect(m.level, 1);
      expect(m.badges, isEmpty);
      expect(m.loyaltyMilestonesAwarded, isEmpty);
    });

    test('prefers map[id] when no explicit id given', () {
      final map = {
        'id': 'map-id',
        'name': 'Eve',
        'phone': '3333333333',
        'branch': 'south',
        'membershipPlan': 'Monthly',
        'joiningDate': ts,
        'expiryDate': ts,
      };
      final m = MemberModel.fromMap(map);
      expect(m.id, 'map-id');
    });

    test('explicit id param overrides map id', () {
      final map = {
        'id': 'map-id',
        'name': 'Frank',
        'phone': '4444444444',
        'branch': 'south',
        'membershipPlan': 'Monthly',
        'joiningDate': ts,
        'expiryDate': ts,
      };
      final m = MemberModel.fromMap(map, id: 'explicit-id');
      expect(m.id, 'explicit-id');
    });

    test('fromFirestore delegates to fromMap', () {
      final map = {
        'name': 'Grace',
        'phone': '5555555555',
        'branch': 'main',
        'membershipPlan': 'Monthly',
        'joiningDate': ts,
        'expiryDate': ts,
      };
      final m = MemberModel.fromFirestore(map, 'firestore-id');
      expect(m.id, 'firestore-id');
      expect(m.name, 'Grace');
    });
  });

  group('MemberModel.toMap round-trip', () {
    test('toMap then fromMap preserves all core fields', () {
      final original = _base(id: 'rt-1').copyWith(
        name: 'Round Trip',
        phone: '6666666666',
        email: 'rt@test.com',
        dueAmount: 500.0,
        xpPoints: 1200,
        level: 3,
        badges: ['first_checkin', 'streak_7'],
      );
      final map = original.toMap();
      final restored = MemberModel.fromMap(map, id: 'rt-1');
      expect(restored.name, original.name);
      expect(restored.phone, original.phone);
      expect(restored.email, original.email);
      expect(restored.dueAmount, original.dueAmount);
      expect(restored.xpPoints, original.xpPoints);
      expect(restored.level, original.level);
      expect(restored.badges, original.badges);
    });
  });

  group('MemberModel.copyWith', () {
    test('returns new instance with updated field', () {
      final m = _base();
      final updated = m.copyWith(name: 'Updated Name');
      expect(updated.name, 'Updated Name');
      expect(updated.phone, m.phone);
    });

    test('original is unchanged after copyWith', () {
      final m = _base();
      m.copyWith(name: 'Changed');
      expect(m.name, 'Test Member');
    });
  });
}
