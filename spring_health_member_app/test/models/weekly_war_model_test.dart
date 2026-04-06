import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/models/weekly_war_model.dart';

void main() {
  group('WeeklyWarModel.fromMap', () {
    test('creates model correctly with full valid data and Timestamps', () {
      final now = DateTime.now();
      // Use exact seconds to avoid microsecond precision issues
      final startDate = DateTime(now.year, now.month, now.day, 10, 0, 0);
      final endDate = startDate.add(const Duration(days: 7));

      final map = {
        'branchId': 'branch_123',
        'weekNumber': 42,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'exercise': 'Pushups',
        'unit': 'reps',
        'category': 'strength',
        'status': 'active',
        'prizePool': {
          '1': 100,
          '2': 50,
          '3': 25,
        },
        'winnerId': 'user_99',
        'winnerName': 'John Doe',
      };

      final model = WeeklyWarModel.fromMap('war_doc_id', map);

      expect(model.id, 'war_doc_id');
      expect(model.branchId, 'branch_123');
      expect(model.weekNumber, 42);
      expect(model.startDate, startDate);
      expect(model.endDate, endDate);
      expect(model.exercise, 'Pushups');
      expect(model.unit, 'reps');
      expect(model.category, 'strength');
      expect(model.status, 'active');
      expect(model.prizePool, {'1': 100, '2': 50, '3': 25});
      expect(model.winnerId, 'user_99');
      expect(model.winnerName, 'John Doe');
    });

    test('creates model correctly when dates are ISO-8601 Strings', () {
      final map = {
        'startDate': '2023-01-01T10:00:00.000Z',
        'endDate': '2023-01-08T10:00:00.000Z',
      };

      final model = WeeklyWarModel.fromMap('test_id', map);

      expect(model.startDate, DateTime.parse('2023-01-01T10:00:00.000Z'));
      expect(model.endDate, DateTime.parse('2023-01-08T10:00:00.000Z'));
    });

    test('creates model with default values when map fields are missing or null', () {
      final beforeParsing = DateTime.now();

      final map = <String, dynamic>{};
      final model = WeeklyWarModel.fromMap('empty_id', map);

      final afterParsing = DateTime.now();

      expect(model.id, 'empty_id');
      expect(model.branchId, '');
      expect(model.weekNumber, 0);

      // Since _toDateTime falls back to DateTime.now() if null or unrecognized type,
      // we check if it falls within the reasonable parsing window.
      expect(
        model.startDate.isAfter(beforeParsing.subtract(const Duration(milliseconds: 1))) ||
        model.startDate.isAtSameMomentAs(beforeParsing),
        isTrue,
      );
      expect(
        model.startDate.isBefore(afterParsing.add(const Duration(milliseconds: 1))) ||
        model.startDate.isAtSameMomentAs(afterParsing),
        isTrue,
      );

      expect(
        model.endDate.isAfter(beforeParsing.subtract(const Duration(milliseconds: 1))) ||
        model.endDate.isAtSameMomentAs(beforeParsing),
        isTrue,
      );
      expect(
        model.endDate.isBefore(afterParsing.add(const Duration(milliseconds: 1))) ||
        model.endDate.isAtSameMomentAs(afterParsing),
        isTrue,
      );

      expect(model.exercise, '');
      expect(model.unit, 'reps');
      expect(model.category, 'strength');
      expect(model.status, 'active');
      expect(model.prizePool, isEmpty);
      expect(model.winnerId, isNull);
      expect(model.winnerName, isNull);
    });

    test('handles prizePool safely when it is null', () {
      final map = {
        'prizePool': null,
      };

      final model = WeeklyWarModel.fromMap('id', map);

      expect(model.prizePool, isEmpty);
    });
  });
}
