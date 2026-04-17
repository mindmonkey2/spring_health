import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/models/attendance_model.dart';

void main() {
  group('AttendanceModel Equality & Debug', () {
    final now = DateTime(2023, 10, 27, 10, 30);
    final today = DateTime(2023, 10, 27);
    final tomorrow = DateTime(2023, 10, 28, 11, 0);

    final model1 = AttendanceModel(
      id: '1',
      memberId: 'M1',
      memberName: 'John Doe',
      branch: 'Warangal',
      checkInTime: now,
      date: today,
      checkOutTime: null,
    );

    final model2 = AttendanceModel(
      id: '1',
      memberId: 'M1',
      memberName: 'John Doe',
      branch: 'Warangal',
      checkInTime: now,
      date: today,
      checkOutTime: null,
    );

    final model3 = AttendanceModel(
      id: '2',
      memberId: 'M1',
      memberName: 'John Doe',
      branch: 'Warangal',
      checkInTime: now,
      date: today,
      checkOutTime: null,
    );

    final modelWithCheckOut = model1.copyWith(checkOutTime: tomorrow);
    final modelWithCheckOut2 = model2.copyWith(checkOutTime: tomorrow);

    test('Identical models should be equal', () {
      expect(model1 == model2, isTrue);
      expect(model1.hashCode == model2.hashCode, isTrue);
    });

    test('Different models should not be equal', () {
      expect(model1 == model3, isFalse);
      expect(model1.hashCode == model3.hashCode, isFalse);
    });

    test('Models with different checkOutTime should not be equal', () {
      expect(model1 == modelWithCheckOut, isFalse);
      expect(model1.hashCode == modelWithCheckOut.hashCode, isFalse);
    });

    test('Models with same checkOutTime should be equal', () {
      expect(modelWithCheckOut == modelWithCheckOut2, isTrue);
      expect(modelWithCheckOut.hashCode == modelWithCheckOut2.hashCode, isTrue);
    });

    test('toString should contain all field values', () {
      final str = model1.toString();
      expect(str, contains('id: 1'));
      expect(str, contains('memberId: M1'));
      expect(str, contains('memberName: John Doe'));
      expect(str, contains('branch: Warangal'));
      expect(str, contains('checkInTime: $now'));
      expect(str, contains('date: $today'));
      expect(str, contains('checkOutTime: null'));
    });
  });
}
