import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/models/announcement_model.dart';

void main() {
  group('AnnouncementModel', () {
    final now = DateTime.now();
    final timestamp = Timestamp.fromDate(now);

    test('fromMap handles createdAt with Timestamp', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'targetBranches': ['all'],
        'createdAt': timestamp,
      };
      final model = AnnouncementModel.fromMap(map, map['id'] as String);
      expect(model.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('fromMap handles createdAt with DateTime', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'targetBranches': ['all'],
        'createdAt': now,
      };
      final model = AnnouncementModel.fromMap(map, map['id'] as String);
      expect(model.createdAt, now);
    });

    test('fromMap handles expiresAt with Timestamp', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'targetBranches': ['all'],
        'createdAt': timestamp,
        'expiresAt': timestamp,
      };
      final model = AnnouncementModel.fromMap(map, map['id'] as String);
      expect(model.expiresAt?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('fromMap handles expiresAt with DateTime', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'targetBranches': ['all'],
        'createdAt': timestamp,
        'expiresAt': now,
      };
      final model = AnnouncementModel.fromMap(map, map['id'] as String);
      expect(model.expiresAt, now);
    });

    test('fromMap handles expiresAt being null', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'targetBranches': ['all'],
        'createdAt': timestamp,
        'expiresAt': null,
      };
      final model = AnnouncementModel.fromMap(map, map['id'] as String);
      expect(model.expiresAt, isNull);
    });

    test('fromMap handles missing expiresAt', () {
      final map = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'targetBranches': ['all'],
        'createdAt': timestamp,
      };
      final model = AnnouncementModel.fromMap(map, map['id'] as String);
      expect(model.expiresAt, isNull);
    });
  });
}
