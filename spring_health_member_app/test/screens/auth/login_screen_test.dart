import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_member/screens/auth/login_screen.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Captures pushes so we can assert navigation without building the target screen.
class _RouteCaptor extends NavigatorObserver {
  Route<dynamic>? pushed;

  @override
  void didPush(Route route, Route? previousRoute) {
    pushed = route;
  }
}

Widget _wrap(Widget child, {List<NavigatorObserver>? observers}) {
  return MaterialApp(
    home: child,
    navigatorObservers: observers ?? const [],
  );
}

Future<void> _enterPhoneAndTap(WidgetTester tester, String phone) async {
  await tester.enterText(find.byType(TextFormField), phone);
  await tester.tap(find.text('SEND OTP'));
  await tester.pump();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    Animate.restartOnHotReload = false;
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen, {List<NavigatorObserver>? observers}) async {
    await tester.pumpWidget(_wrap(screen, observers: observers));
    await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
  }
  group('Member LoginScreen — rendering', () {
    testWidgets('renders phone input field and SEND OTP button', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('SEND OTP'), findsOneWidget);
    });

    testWidgets('shows WELCOME BACK heading', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      expect(find.text('WELCOME BACK'), findsOneWidget);
    });

    testWidgets('shows +91 country code prefix', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      expect(find.text('+91'), findsOneWidget);
    });

    testWidgets('shows membership notice text', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      expect(
        find.textContaining('registered Spring Health members'),
        findsOneWidget,
      );
    });
  });

  group('Member LoginScreen — phone validation', () {
    testWidgets('shows error when phone is empty', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      await tester.tap(find.text('SEND OTP'));
      await tester.pump();

      expect(find.text('Please enter your mobile number'), findsOneWidget);
    });

    testWidgets('shows error when phone has fewer than 10 digits', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      await _enterPhoneAndTap(tester, '98765432'); // 8 digits

      expect(find.text('Enter a valid 10-digit number'), findsOneWidget);
    });

    testWidgets('shows error when phone starts with 5 (invalid Indian number)',
        (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      await _enterPhoneAndTap(tester, '5123456789');

      expect(find.text('Enter a valid Indian mobile number'), findsOneWidget);
    });

    testWidgets('shows error for phone starting with 0', (tester) async {
      await pumpScreen(tester, const LoginScreen(testMode: true));

      await _enterPhoneAndTap(tester, '0123456789');

      expect(find.text('Enter a valid Indian mobile number'), findsOneWidget);
    });

    testWidgets('does not call sendOtp when form is invalid', (tester) async {
      var called = false;
      await pumpScreen(tester, LoginScreen(
        testMode: true,
        sendOtpOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) async {
          called = true;
        },
      ));

      // Submit without entering a phone number
      await tester.tap(find.text('SEND OTP'));
      await tester.pump();

      expect(called, isFalse);
    });
  });

  group('Member LoginScreen — valid phone accepted', () {
    for (final startDigit in ['6', '7', '8', '9']) {
      testWidgets('accepts valid phone starting with $startDigit', (tester) async {
        var called = false;
        await pumpScreen(tester, LoginScreen(
        testMode: true,
          sendOtpOverride: ({
            required phoneNumber,
            required onCodeSent,
            required onError,
          }) async {
            called = true;
            onCodeSent('vid');
          },
        ));

        await _enterPhoneAndTap(tester, '${startDigit}123456789');
        await tester.pump(Duration.zero);

        expect(called, isTrue,
            reason: 'Should call sendOtp for phone starting with $startDigit');
        expect(find.text('Please enter your mobile number'), findsNothing);
        expect(find.text('Enter a valid 10-digit number'), findsNothing);
        expect(find.text('Enter a valid Indian mobile number'), findsNothing);
      });
    }
  });

  group('Member LoginScreen — OTP send flow', () {
    testWidgets('shows loading indicator while OTP is being sent', (tester) async {
      final completer = Completer<void>();
      await pumpScreen(tester, LoginScreen(
        testMode: true,
        sendOtpOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) =>
            completer.future,
      ));

      await _enterPhoneAndTap(tester, '9876543210');

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pump();
    });

    testWidgets('calls sendOtp with the entered phone number', (tester) async {
      String? capturedPhone;
      await pumpScreen(tester, LoginScreen(
        testMode: true,
        sendOtpOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) async {
          capturedPhone = phoneNumber;
          onCodeSent('vid');
        },
      ));

      await _enterPhoneAndTap(tester, '9876543210');
      await tester.pump(Duration.zero);

      expect(capturedPhone, '9876543210');
    });

    testWidgets('shows error SnackBar when OTP send fails', (tester) async {
      await pumpScreen(tester, LoginScreen(
        testMode: true,
        sendOtpOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) async {
          onError('Too many requests. Please wait before trying again.');
        },
      ));

      await _enterPhoneAndTap(tester, '9876543210');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Too many requests. Please wait before trying again.'),
        findsOneWidget,
      );
    });

    testWidgets('hides loading indicator and restores button after OTP error',
        (tester) async {
      await pumpScreen(tester, LoginScreen(
        testMode: true,
        sendOtpOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) async {
          onError('OTP failed');
        },
      ));

      await _enterPhoneAndTap(tester, '9876543210');
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('SEND OTP'), findsOneWidget);
    });

    testWidgets('initiates navigation after successful OTP send', (tester) async {
      final captor = _RouteCaptor();
      await pumpScreen(tester, LoginScreen(
        testMode: true,
          sendOtpOverride: ({
            required phoneNumber,
            required onCodeSent,
            required onError,
          }) async {
            onCodeSent('fake-verification-id');
          },
        ), observers: [captor]);

      await _enterPhoneAndTap(tester, '9876543210');
      await tester.pump(Duration.zero);

      expect(captor.pushed, isNotNull);
    });
  });
}
