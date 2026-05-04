import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/models/member_model.dart';
import 'package:spring_health_studio/models/document_sent_model.dart';

MemberModel _base({
  DateTime? expiryDate,
  bool isArchived = false,
  double dueAmount = 0,
  DateTime? dateOfBirth,
}) {
  final now = DateTime.now();
  return MemberModel(
    id: 'studio-member-1',
    name: 'Test Member',
    phone: '9999999999',
    email: 'test@example.com',
    gender: 'Male',
    branch: 'main',
    category: 'General',
    plan: 'Monthly',
    joiningDate: now.subtract(const Duration(days: 30)),
    expiryDate: expiryDate ?? now.add(const Duration(days: 30)),
    paymentMode: 'Cash',
    totalFee: 1000,
    finalAmount: 1000,
    dueAmount: dueAmount,
    isActive: true,
    isArchived: isArchived,
    qrCode: 'studio-member-1',
    createdAt: now.subtract(const Duration(days: 30)),
    dateOfBirth: dateOfBirth,
  );
}

void main() {
  group('MemberModel.isExpired', () {
    test('false when expiry is in the future', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 10)));
      expect(m.isExpired, isFalse);
    });

    test('true when expiry is in the past', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(m.isExpired, isTrue);
    });
  });

  group('MemberModel.isExpiringSoon', () {
    test('true when expiry is within 7 days', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 5)));
      expect(m.isExpiringSoon, isTrue);
    });

    test('true when expiry is exactly 7 days away', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 7)));
      expect(m.isExpiringSoon, isTrue);
    });

    test('false when expiry is more than 7 days away', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 8)));
      expect(m.isExpiringSoon, isFalse);
    });

    test('false when member is already expired', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 1)));
      expect(m.isExpiringSoon, isFalse);
    });
  });

  group('MemberModel.daysRemaining', () {
    test('returns positive count when not expired', () {
      final m = _base(expiryDate: DateTime.now().add(const Duration(days: 15)));
      expect(m.daysRemaining, greaterThan(0));
    });

    test('returns 0 when expired', () {
      final m = _base(expiryDate: DateTime.now().subtract(const Duration(days: 3)));
      expect(m.daysRemaining, 0);
    });
  });

  group('MemberModel.hasDues', () {
    test('true when dueAmount is positive', () {
      final m = _base(dueAmount: 500);
      expect(m.hasDues, isTrue);
    });

    test('false when dueAmount is zero', () {
      final m = _base(dueAmount: 0);
      expect(m.hasDues, isFalse);
    });
  });

  group('MemberModel.fromMap', () {
    final now = DateTime(2025, 6, 1, 12);
    final ts = Timestamp.fromDate(now);

    test('parses all required fields correctly', () {
      final map = {
        'id': 'sm-1',
        'name': 'Alice',
        'phone': '1234567890',
        'email': 'alice@test.com',
        'gender': 'Female',
        'branch': 'east',
        'category': 'Premium',
        'plan': 'Annual',
        'joiningDate': ts,
        'expiryDate': Timestamp.fromDate(now.add(const Duration(days: 365))),
        'paymentMode': 'UPI',
        'totalFee': 5000.0,
        'finalAmount': 4800.0,
        'isActive': true,
        'isArchived': false,
        'qrCode': 'sm-1',
        'createdAt': ts,
      };
      final m = MemberModel.fromMap(map, id: 'sm-1');
      expect(m.id, 'sm-1');
      expect(m.name, 'Alice');
      expect(m.plan, 'Annual');
      expect(m.totalFee, 5000.0);
      expect(m.finalAmount, 4800.0);
    });

    test('applies defaults for optional numeric fields', () {
      final map = {
        'id': 'bob-id',
        'name': 'Bob',
        'phone': '0987654321',
        'email': '',
        'gender': 'Male',
        'branch': 'west',
        'category': 'General',
        'plan': 'Monthly',
        'joiningDate': ts,
        'expiryDate': ts,
        'paymentMode': 'Cash',
        'totalFee': 1000.0,
        'finalAmount': 1000.0,
        'isActive': true,
        'isArchived': false,
        'qrCode': 'bob-qr',
        'createdAt': ts,
      };
      final m = MemberModel.fromMap(map);
      expect(m.discount, 0);
      expect(m.cashAmount, 0);
      expect(m.upiAmount, 0);
      expect(m.dueAmount, 0);
      expect(m.isArchived, isFalse);
      expect(m.documentHistory, isEmpty);
    });

    test('parses documentHistory list', () {
      final sentAt = DateTime.now().subtract(const Duration(hours: 1));
      final map = {
        'id': 'carol-id',
        'name': 'Carol',
        'phone': '1111111111',
        'email': '',
        'gender': 'Female',
        'branch': 'north',
        'category': 'General',
        'plan': 'Monthly',
        'joiningDate': ts,
        'expiryDate': ts,
        'paymentMode': 'Cash',
        'totalFee': 800.0,
        'finalAmount': 800.0,
        'isActive': true,
        'isArchived': false,
        'qrCode': 'carol-qr',
        'createdAt': ts,
        'documentHistory': [
          {
            'type': 'welcome',
            'sentAt': sentAt.toIso8601String(),
            'sentBy': 'admin@gym.com',
            'method': 'whatsapp',
            'success': true,
          },
        ],
      };
      final m = MemberModel.fromMap(map);
      expect(m.documentHistory.length, 1);
      expect(m.documentHistory.first.type, 'welcome');
      expect(m.documentHistory.first.method, 'whatsapp');
    });
  });

  group('MemberModel.copyWith', () {
    test('updates specified fields while preserving others', () {
      final m = _base(dueAmount: 200);
      final updated = m.copyWith(name: 'Updated', dueAmount: 0);
      expect(updated.name, 'Updated');
      expect(updated.dueAmount, 0);
      expect(updated.phone, m.phone);
      expect(updated.branch, m.branch);
    });
  });

  group('DocumentSentModel', () {
    test('toMap and fromMap round-trip', () {
      final sentAt = DateTime(2025, 3, 15, 10, 30);
      final doc = DocumentSentModel(
        type: 'receipt',
        sentAt: sentAt,
        sentBy: 'staff@gym.com',
        method: 'email',
        success: true,
      );
      final map = doc.toMap();
      final restored = DocumentSentModel.fromMap(map);
      expect(restored.type, 'receipt');
      expect(restored.sentAt, sentAt);
      expect(restored.sentBy, 'staff@gym.com');
      expect(restored.method, 'email');
      expect(restored.success, isTrue);
    });

    test('displayText contains type and method', () {
      final doc = DocumentSentModel(
        type: 'welcome',
        sentAt: DateTime(2025, 1, 5, 9, 0),
        sentBy: 'admin',
        method: 'whatsapp',
      );
      expect(doc.displayText, contains('welcome'));
      expect(doc.displayText, contains('whatsapp'));
    });

    test('defaults success to true when missing from map', () {
      final doc = DocumentSentModel.fromMap({
        'type': 'rejoin',
        'sentAt': DateTime.now().toIso8601String(),
        'sentBy': 'admin',
        'method': 'both',
      });
      expect(doc.success, isTrue);
    });
  });
}
