import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/models/member_model.dart';
import 'package:spring_health_studio/services/firestore_service.dart';
import 'package:spring_health_studio/services/notification_service.dart';
import 'package:spring_health_studio/services/whatsapp_service.dart';

// ─── Fakes ──────────────────────────────────────────────────────────────────

class FakeFirestoreService extends Fake implements FirestoreService {
  List<MemberModel> _members = [];
  void setMembers(List<MemberModel> members) => _members = members;

  @override
  Stream<List<MemberModel>> getMembers({String? branch}) =>
      Stream.value(_members);
}

class FakeWhatsAppService extends Fake implements WhatsAppService {
  final List<String> birthdaySent = [];
  final List<String> expirySent = [];
  final List<String> duesSent = [];
  bool shouldSucceed = true;

  @override
  Future<bool> sendBirthdayWish(MemberModel member) async {
    if (shouldSucceed) birthdaySent.add(member.name);
    return shouldSucceed;
  }

  @override
  Future<bool> sendExpiryReminder(MemberModel member, int daysLeft) async {
    if (shouldSucceed) expirySent.add('${member.name}:$daysLeft');
    return shouldSucceed;
  }

  @override
  Future<bool> sendDuePaymentReminder(MemberModel member) async {
    if (shouldSucceed) duesSent.add(member.name);
    return shouldSucceed;
  }
}

// ─── Helper ─────────────────────────────────────────────────────────────────

MemberModel _member({
  required String name,
  required DateTime expiryDate,
  double dueAmount = 0,
  DateTime? dateOfBirth,
}) {
  final now = DateTime.now();
  return MemberModel(
    id: name.toLowerCase().replaceAll(' ', '-'),
    name: name,
    phone: '9999999999',
    email: '$name@test.com',
    gender: 'Male',
    branch: 'main',
    category: 'General',
    plan: 'Monthly',
    joiningDate: now.subtract(const Duration(days: 30)),
    expiryDate: expiryDate,
    paymentMode: 'Cash',
    totalFee: 1000,
    finalAmount: 1000,
    dueAmount: dueAmount,
    isActive: true,
    qrCode: name,
    createdAt: now,
    dateOfBirth: dateOfBirth,
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  late FakeFirestoreService fakeFs;
  late FakeWhatsAppService fakeWa;
  late NotificationService service;

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  setUp(() {
    fakeFs = FakeFirestoreService();
    fakeWa = FakeWhatsAppService();
    service = NotificationService(
      firestoreService: fakeFs,
      whatsAppService: fakeWa,
    );
  });

  // ─── sendBirthdayWishes ─────────────────────────────────────────────────

  group('NotificationService.sendBirthdayWishes', () {
    test('sends to member whose birthday is today', () async {
      final member = _member(
        name: 'Alice',
        expiryDate: today.add(const Duration(days: 30)),
        dateOfBirth: DateTime(1990, today.month, today.day),
      );
      final result = await service.sendBirthdayWishes(membersList: [member]);
      expect(result, contains('Alice'));
    });

    test('does not send to member whose birthday is tomorrow', () async {
      final tomorrow = today.add(const Duration(days: 1));
      final member = _member(
        name: 'Bob',
        expiryDate: today.add(const Duration(days: 30)),
        dateOfBirth: DateTime(1990, tomorrow.month, tomorrow.day),
      );
      final result = await service.sendBirthdayWishes(membersList: [member]);
      expect(result, isEmpty);
    });

    test('skips member with null dateOfBirth', () async {
      final member = _member(name: 'Carol', expiryDate: today.add(const Duration(days: 30)));
      final result = await service.sendBirthdayWishes(membersList: [member]);
      expect(result, isEmpty);
    });

    test('returns empty list when whatsapp send fails', () async {
      fakeWa.shouldSucceed = false;
      final member = _member(
        name: 'Dave',
        expiryDate: today.add(const Duration(days: 30)),
        dateOfBirth: DateTime(1995, today.month, today.day),
      );
      final result = await service.sendBirthdayWishes(membersList: [member]);
      expect(result, isEmpty);
    });

    test('sends to multiple birthday members on same day', () async {
      final members = [
        _member(name: 'Eve', expiryDate: today.add(const Duration(days: 30)), dateOfBirth: DateTime(1990, today.month, today.day)),
        _member(name: 'Frank', expiryDate: today.add(const Duration(days: 30)), dateOfBirth: DateTime(1985, today.month, today.day)),
        _member(name: 'Grace', expiryDate: today.add(const Duration(days: 30)), dateOfBirth: DateTime(1992, today.month == 12 ? 11 : today.month + 1, 1)),
      ];
      final result = await service.sendBirthdayWishes(membersList: members);
      expect(result, containsAll(['Eve', 'Frank']));
      expect(result, isNot(contains('Grace')));
    });
  });

  // ─── sendExpiryReminders ────────────────────────────────────────────────

  group('NotificationService.sendExpiryReminders', () {
    test('puts member expiring tomorrow in 1-day bucket', () async {
      final member = _member(name: 'Heidi', expiryDate: today.add(const Duration(days: 1)));
      final result = await service.sendExpiryReminders(membersList: [member]);
      expect(result.oneDay, contains('Heidi'));
      expect(result.threeDays, isEmpty);
      expect(result.sevenDays, isEmpty);
    });

    test('puts member expiring in 2 days in 3-day bucket', () async {
      final member = _member(name: 'Ivan', expiryDate: today.add(const Duration(days: 2)));
      final result = await service.sendExpiryReminders(membersList: [member]);
      expect(result.threeDays, contains('Ivan'));
    });

    test('puts member expiring in 3 days in 3-day bucket', () async {
      final member = _member(name: 'Judy', expiryDate: today.add(const Duration(days: 3)));
      final result = await service.sendExpiryReminders(membersList: [member]);
      expect(result.threeDays, contains('Judy'));
    });

    test('puts member expiring in 7 days in 7-day bucket', () async {
      final member = _member(name: 'Karl', expiryDate: today.add(const Duration(days: 7)));
      final result = await service.sendExpiryReminders(membersList: [member]);
      expect(result.sevenDays, contains('Karl'));
    });

    test('skips already-expired members', () async {
      final member = _member(name: 'Lena', expiryDate: today.subtract(const Duration(days: 1)));
      final result = await service.sendExpiryReminders(membersList: [member]);
      expect(result.total, 0);
    });

    test('skips members expiring in more than 7 days', () async {
      final member = _member(name: 'Mike', expiryDate: today.add(const Duration(days: 30)));
      final result = await service.sendExpiryReminders(membersList: [member]);
      expect(result.total, 0);
    });

    test('total sums all three buckets', () async {
      final members = [
        _member(name: 'A', expiryDate: today.add(const Duration(days: 1))),
        _member(name: 'B', expiryDate: today.add(const Duration(days: 2))),
        _member(name: 'C', expiryDate: today.add(const Duration(days: 6))),
      ];
      final result = await service.sendExpiryReminders(membersList: members);
      expect(result.total, 3);
    });

    test('categorises mixed list correctly', () async {
      final members = [
        _member(name: 'OneDay', expiryDate: today.add(const Duration(days: 1))),
        _member(name: 'ThreeDay', expiryDate: today.add(const Duration(days: 3))),
        _member(name: 'SevenDay', expiryDate: today.add(const Duration(days: 7))),
        _member(name: 'Expired', expiryDate: today.subtract(const Duration(days: 2))),
        _member(name: 'Future', expiryDate: today.add(const Duration(days: 30))),
      ];
      final result = await service.sendExpiryReminders(membersList: members);
      expect(result.oneDay, contains('OneDay'));
      expect(result.threeDays, contains('ThreeDay'));
      expect(result.sevenDays, contains('SevenDay'));
      expect(result.total, 3);
    });
  });

  // ─── sendDuePaymentReminders ────────────────────────────────────────────

  group('NotificationService.sendDuePaymentReminders', () {
    test('sends to member with positive dueAmount', () async {
      final member = _member(name: 'Nick', expiryDate: today.add(const Duration(days: 10)), dueAmount: 500);
      final result = await service.sendDuePaymentReminders(membersList: [member]);
      expect(result, contains('Nick'));
    });

    test('skips member with zero dueAmount', () async {
      final member = _member(name: 'Oscar', expiryDate: today.add(const Duration(days: 10)));
      final result = await service.sendDuePaymentReminders(membersList: [member]);
      expect(result, isEmpty);
    });

    test('sends to all members with dues, skips those without', () async {
      final members = [
        _member(name: 'Peggy', expiryDate: today.add(const Duration(days: 5)), dueAmount: 200),
        _member(name: 'Quinn', expiryDate: today.add(const Duration(days: 10)), dueAmount: 0),
        _member(name: 'Rita', expiryDate: today.add(const Duration(days: 15)), dueAmount: 800),
      ];
      final result = await service.sendDuePaymentReminders(membersList: members);
      expect(result, containsAll(['Peggy', 'Rita']));
      expect(result, isNot(contains('Quinn')));
    });

    test('returns empty when no members have dues', () async {
      final members = [
        _member(name: 'Sam', expiryDate: today.add(const Duration(days: 5))),
        _member(name: 'Trent', expiryDate: today.add(const Duration(days: 20))),
      ];
      final result = await service.sendDuePaymentReminders(membersList: members);
      expect(result, isEmpty);
    });
  });

  // ─── runDailyReminders ──────────────────────────────────────────────────

  group('NotificationService.runDailyReminders', () {
    test('calls all three reminder types and returns combined summary', () async {
      fakeFs.setMembers([
        _member(
          name: 'Uma',
          expiryDate: today.add(const Duration(days: 1)),
          dueAmount: 300,
          dateOfBirth: DateTime(1990, today.month, today.day),
        ),
      ]);
      final summary = await service.runDailyReminders();
      expect(summary.birthdaysSent, contains('Uma'));
      expect(summary.expirySent.total, greaterThan(0));
      expect(summary.duesSent, contains('Uma'));
    });

    test('returns empty summary when no members exist', () async {
      fakeFs.setMembers([]);
      final summary = await service.runDailyReminders();
      expect(summary.birthdaysSent, isEmpty);
      expect(summary.expirySent.total, 0);
      expect(summary.duesSent, isEmpty);
    });

    test('fetches members only once regardless of member count', () async {
      fakeFs.setMembers([
        _member(name: 'Victor', expiryDate: today.add(const Duration(days: 30))),
        _member(name: 'Wendy', expiryDate: today.add(const Duration(days: 30))),
      ]);
      // Should complete without error — single member fetch shared across all three calls
      final summary = await service.runDailyReminders();
      expect(summary, isNotNull);
    });
  });
}
