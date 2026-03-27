import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:spring_health_studio/services/whatsapp_service.dart';

class MockUrlLauncher extends Fake
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {
  String? url;
  LaunchOptions? launchOptions;
  bool canLaunchReturnValue = true;
  bool launchReturnValue = true;
  bool shouldThrowOnLaunch = false;

  @override
  Future<bool> canLaunch(String url) async {
    this.url = url;
    return canLaunchReturnValue;
  }

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    if (shouldThrowOnLaunch) {
      throw Exception('Mock launch error');
    }
    this.url = url;
    launchOptions = options;
    return launchReturnValue;
  }
}

void main() {
  group('WhatsAppService', () {
    late MockUrlLauncher mockUrlLauncher;

    setUp(() {
      mockUrlLauncher = MockUrlLauncher();
      UrlLauncherPlatform.instance = mockUrlLauncher;
    });

    group('sendMessage', () {
      test('should launch whatsapp url successfully', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: '9876543210',
          message: 'Hello World',
        );

        expect(result, true);
        expect(mockUrlLauncher.url, 'https://wa.me/+919876543210?text=Hello%20World');
        expect(mockUrlLauncher.launchOptions?.mode, PreferredLaunchMode.externalApplication);
      });

      test('should return false if canLaunchUrl returns false', () async {
        mockUrlLauncher.canLaunchReturnValue = false;

        final result = await WhatsAppService.sendMessage(
          phoneNumber: '9876543210',
          message: 'Hello World',
        );

        expect(result, false);
        // Ensure launchUrl was not called by checking if launchOptions is still null
        expect(mockUrlLauncher.launchOptions, isNull);
      });

      test('should catch exception and return false if launchUrl throws', () async {
        mockUrlLauncher.shouldThrowOnLaunch = true;

        final result = await WhatsAppService.sendMessage(
          phoneNumber: '9876543210',
          message: 'Hello World',
        );

        expect(result, false);
      });

      test('should correctly format phone number (remove spaces, leading zero, add +91)', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: ' 0 987 654 3210 ',
          message: 'Test',
        );

        expect(result, true);
        expect(mockUrlLauncher.url, 'https://wa.me/+919876543210?text=Test');
      });

      test('should correctly format phone number with existing country code', () async {
        final result = await WhatsAppService.sendMessage(
          phoneNumber: '+1-555-012-3456',
          message: 'Test',
        );

        expect(result, true);
        expect(mockUrlLauncher.url, 'https://wa.me/+15550123456?text=Test');
      });
    });
  });
}
