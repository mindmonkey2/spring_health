import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/services/whatsapp_service.dart';

void main() {
  group('WhatsAppService', () {
    group('formatPhoneNumber', () {
      test('should add +91 to standard 10-digit Indian numbers', () {
        expect(WhatsAppService.formatPhoneNumber('9876543210'), '+919876543210');
      });

      test('should not add +91 if number already starts with +91', () {
        expect(WhatsAppService.formatPhoneNumber('+919876543210'), '+919876543210');
      });

      test('should remove leading 0 and add +91', () {
        expect(WhatsAppService.formatPhoneNumber('09876543210'), '+919876543210');
      });

      test('should handle numbers with spaces', () {
        expect(WhatsAppService.formatPhoneNumber('98 765 43210'), '+919876543210');
        expect(WhatsAppService.formatPhoneNumber('+91 98765 43210'), '+919876543210');
      });

      test('should handle numbers with dashes', () {
        expect(WhatsAppService.formatPhoneNumber('987-654-3210'), '+919876543210');
        expect(WhatsAppService.formatPhoneNumber('+91-98765-43210'), '+919876543210');
      });

      test('should handle numbers with parentheses', () {
        expect(WhatsAppService.formatPhoneNumber('(987) 654-3210'), '+919876543210');
      });

      test('should handle international numbers correctly (e.g. US +1)', () {
        expect(WhatsAppService.formatPhoneNumber('+11234567890'), '+11234567890');
        expect(WhatsAppService.formatPhoneNumber('+1 (123) 456-7890'), '+11234567890');
      });

      test('should handle international numbers correctly (e.g. UK +44)', () {
        expect(WhatsAppService.formatPhoneNumber('+447911123456'), '+447911123456');
      });

      test('should remove alphabets or special characters other than +', () {
        expect(WhatsAppService.formatPhoneNumber('+91-987-abc-3210'), '+919873210');
        expect(WhatsAppService.formatPhoneNumber('987!@#3210'), '+919873210');
      });

      test('should handle empty string', () {
        expect(WhatsAppService.formatPhoneNumber(''), '+91');
      });
    });
  });
}
