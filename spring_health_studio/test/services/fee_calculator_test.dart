import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/services/fee_calculator.dart';

void main() {
  group('FeeCalculator', () {
    group('getFee', () {
      test('returns correct fee for valid inputs', () {
        expect(FeeCalculator.getFee('Hanamkonda', 'Cardio', '1 Month'), 1700.0);
      });

      test('returns null when fee is 0', () {
        expect(FeeCalculator.getFee('Hanamkonda', 'Cardio', '6 Months'), isNull);
      });

      test('returns null for invalid branch', () {
        expect(FeeCalculator.getFee('UnknownBranch', 'Cardio', '1 Month'), isNull);
      });

      test('returns null for invalid category', () {
        expect(FeeCalculator.getFee('Hanamkonda', 'UnknownCategory', '1 Month'), isNull);
      });

      test('returns null for invalid plan', () {
        expect(FeeCalculator.getFee('Hanamkonda', 'Cardio', 'UnknownPlan'), isNull);
      });

      test('returns null for empty strings', () {
        expect(FeeCalculator.getFee('', '', ''), isNull);
      });
    });

    group('getAvailablePlans', () {
      test('returns list of plans with non-zero fees for valid inputs', () {
        final plans = FeeCalculator.getAvailablePlans('Hanamkonda', 'Cardio');
        expect(plans, containsAll(['1 Day', '1 Month', '3 Months']));
        expect(plans, isNot(contains('6 Months'))); // Fee is 0
        expect(plans, isNot(contains('1 Year'))); // Fee is 0
      });

      test('returns empty list for invalid branch', () {
        expect(FeeCalculator.getAvailablePlans('UnknownBranch', 'Cardio'), isEmpty);
      });

      test('returns empty list for invalid category', () {
        expect(FeeCalculator.getAvailablePlans('Hanamkonda', 'UnknownCategory'), isEmpty);
      });
    });

    group('calculateFinalAmount', () {
      test('returns totalFee minus discount', () {
        expect(FeeCalculator.calculateFinalAmount(1000.0, 200.0), 800.0);
      });

      test('handles zero values correctly', () {
        expect(FeeCalculator.calculateFinalAmount(1000.0, 0.0), 1000.0);
        expect(FeeCalculator.calculateFinalAmount(0.0, 0.0), 0.0);
      });
    });

    group('calculatePaidAmount', () {
      test('returns finalAmount minus dueAmount', () {
        expect(FeeCalculator.calculatePaidAmount(800.0, 300.0), 500.0);
      });

      test('handles zero due amount', () {
        expect(FeeCalculator.calculatePaidAmount(800.0, 0.0), 800.0);
      });
    });

    group('validateMixedPayment', () {
      test('returns true when cash + upi equals paidAmount', () {
        expect(FeeCalculator.validateMixedPayment(500.0, 200.0, 300.0), isTrue);
      });

      test('returns false when cash + upi does not equal paidAmount', () {
        expect(FeeCalculator.validateMixedPayment(500.0, 200.0, 200.0), isFalse);
        expect(FeeCalculator.validateMixedPayment(500.0, 300.0, 300.0), isFalse);
      });
    });
  });
}
