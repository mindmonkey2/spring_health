import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('returns null for valid email', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('name.surname@domain.co.uk'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail(''), equals('Email is required'));
    });

    test('returns error for missing @ symbol', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('notanemail'), equals('Enter a valid email'));
    });

    test('returns error for missing domain', () {
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('returns error for missing local part', () {
      expect(Validators.validateEmail('@example.com'), isNotNull);
    });

    test('returns error for consecutive dots', () {
      expect(Validators.validateEmail('user..name@example.com'), isNotNull);
    });
  });

  group('Validators.validatePhone', () {
    test('returns null for valid 10-digit phone', () {
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('0123456789'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.validatePhone(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validatePhone(''), equals('Phone number is required'));
    });

    test('returns error for fewer than 10 digits', () {
      expect(Validators.validatePhone('98765432'), isNotNull);
      expect(Validators.validatePhone('98765432'), equals('Enter a valid 10-digit phone number'));
    });

    test('returns error for more than 10 digits', () {
      expect(Validators.validatePhone('98765432109'), isNotNull);
    });

    test('returns error for non-digit characters', () {
      expect(Validators.validatePhone('9876-43210'), isNotNull);
      expect(Validators.validatePhone('+919876543210'), isNotNull);
    });
  });

  group('Validators.validatePassword', () {
    test('returns null for password of 6+ characters', () {
      expect(Validators.validatePassword('secret'), isNull);
      expect(Validators.validatePassword('supersecurepassword'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.validatePassword(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validatePassword(''), equals('Password is required'));
    });

    test('returns error for password shorter than 6 characters', () {
      expect(Validators.validatePassword('abc'), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
      expect(Validators.validatePassword('12345'), equals('Password must be at least 6 characters'));
    });

    test('accepts exactly 6 characters', () {
      expect(Validators.validatePassword('abcdef'), isNull);
    });
  });

  group('Validators.validateRequired', () {
    test('returns null for non-empty input', () {
      expect(Validators.validateRequired('some value', 'Field'), isNull);
      expect(Validators.validateRequired('  x  ', 'Field'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.validateRequired(null, 'Name'), isNotNull);
      expect(Validators.validateRequired(null, 'Name'), equals('Name is required'));
    });

    test('returns error for empty string', () {
      expect(Validators.validateRequired('', 'Branch'), equals('Branch is required'));
    });

    test('includes the field name in the error message', () {
      final error = Validators.validateRequired('', 'Membership Plan');
      expect(error, contains('Membership Plan'));
    });
  });

  group('Validators.validateNumber', () {
    test('returns null for valid integer string', () {
      expect(Validators.validateNumber('42', 'Amount'), isNull);
      expect(Validators.validateNumber('0', 'Amount'), isNull);
    });

    test('returns null for valid decimal string', () {
      expect(Validators.validateNumber('3.14', 'Price'), isNull);
      expect(Validators.validateNumber('1000.50', 'Fee'), isNull);
    });

    test('returns error for null input', () {
      expect(Validators.validateNumber(null, 'Amount'), isNotNull);
    });

    test('returns error for empty string', () {
      expect(Validators.validateNumber('', 'Amount'), equals('Amount is required'));
    });

    test('returns error for non-numeric string', () {
      expect(Validators.validateNumber('abc', 'Amount'), equals('Enter a valid number'));
      expect(Validators.validateNumber('12abc', 'Amount'), equals('Enter a valid number'));
    });

    test('returns error for string with spaces', () {
      expect(Validators.validateNumber('1 000', 'Amount'), isNotNull);
    });
  });
}
