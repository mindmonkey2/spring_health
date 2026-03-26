import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/models/member_model.dart';
import 'package:spring_health_studio/services/notification_service.dart';
import 'package:spring_health_studio/services/whatsapp_service.dart';
import 'package:spring_health_studio/services/firestore_service.dart';

class MockWhatsAppService extends WhatsAppService {
  int sendCount = 0;
  final Duration delay;

  MockWhatsAppService({this.delay = const Duration(milliseconds: 100)});

  @override
  Future<bool> sendBirthdayWish(MemberModel member) async {
    sendCount++;
    await Future.delayed(delay);
    return true;
  }

  @override
  Future<bool> sendExpiryReminder(MemberModel member, int daysLeft) async {
    sendCount++;
    await Future.delayed(delay);
    return true;
  }

  @override
  Future<bool> sendDuePaymentReminder(MemberModel member) async {
    sendCount++;
    await Future.delayed(delay);
    return true;
  }
}

class MockFirestoreService extends FirestoreService {
  final List<MemberModel> members;

  MockFirestoreService(this.members);

  @override
  Stream<List<MemberModel>> getMembers({String? branch}) {
    return Stream.value(members);
  }
}

void main() {
  group('NotificationService Performance Baseline', () {
    late List<MemberModel> mockMembers;

    setUp(() {
      mockMembers = List.generate(
        10,
        (i) => MemberModel(
          id: 'M00$i',
          name: 'Member $i',
          phone: '987654321$i',
          email: 'member$i@test.com',
          gender: 'Male',
          dateOfBirth: DateTime.now(), // Birthday today
          branch: 'Hanamkonda',
          category: 'General',
          plan: '1 Month',
          joiningDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 1)), // Expiring soon
          paymentMode: 'Cash',
          totalFee: 1000,
          finalAmount: 1000,
          dueAmount: 500, // Has dues
          isActive: true,
          qrCode: 'QR$i',
          createdAt: DateTime.now(),
        ),
      );
    });

    test('Optimized (Firestore) Baseline: sendBirthdayWishes sequential with delays', () async {
      final mockWhatsApp = MockWhatsAppService(delay: const Duration(milliseconds: 10));
      final mockFirestore = MockFirestoreService(mockMembers);

      final service = NotificationService(
        firestoreService: mockFirestore,
        whatsAppService: mockWhatsApp,
      );

      final stopwatch = Stopwatch()..start();
      await service.sendBirthdayWishes();
      stopwatch.stop();

      expect(mockWhatsApp.sendCount, 10);
    });

    test('Optimized (Firestore) Baseline: sendExpiryReminders sequential with delays', () async {
      final mockWhatsApp = MockWhatsAppService(delay: const Duration(milliseconds: 10));
      final mockFirestore = MockFirestoreService(mockMembers);

      final service = NotificationService(
        firestoreService: mockFirestore,
        whatsAppService: mockWhatsApp,
      );

      final stopwatch = Stopwatch()..start();
      await service.sendExpiryReminders();
      stopwatch.stop();

      expect(mockWhatsApp.sendCount, 10);
    });

    test('Optimized (Firestore) Baseline: sendDuePaymentReminders sequential with delays', () async {
      final mockWhatsApp = MockWhatsAppService(delay: const Duration(milliseconds: 10));
      final mockFirestore = MockFirestoreService(mockMembers);

      final service = NotificationService(
        firestoreService: mockFirestore,
        whatsAppService: mockWhatsApp,
      );

      final stopwatch = Stopwatch()..start();
      await service.sendDuePaymentReminders();
      stopwatch.stop();

      expect(mockWhatsApp.sendCount, 10);
    });
  });
}
