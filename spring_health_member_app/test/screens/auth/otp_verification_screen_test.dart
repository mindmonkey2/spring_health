import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';
import 'package:spring_health_member/screens/auth/otp_verification_screen.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

OtpVerificationScreen _screen({
  String phoneNumber = '9876543210',
  String verificationId = 'fake-vid',
  Future<void> Function(String otp, {String? verificationId})? verifyOverride,
  Future<void> Function({
    required String phoneNumber,
    required void Function(String) onCodeSent,
    required void Function(String) onError,
  })? resendOverride,
}) {
  return OtpVerificationScreen(
    phoneNumber: phoneNumber,
    verificationId: verificationId,
    verifyOtpOverride: verifyOverride,
    resendOtpOverride: resendOverride,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: child);

/// Enters 6 digits into the Pinput widget.
Future<void> _enter6Digits(WidgetTester tester, String digits) async {
  await tester.enterText(find.byType(Pinput), digits);
  await tester.pump();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('OtpVerificationScreen — rendering', () {
    testWidgets('displays the phone number OTP was sent to', (tester) async {
      await tester.pumpWidget(_wrap(_screen(phoneNumber: '9876543210')));
      await tester.pumpAndSettle();

      expect(find.textContaining('9876543210'), findsOneWidget);
    });

    testWidgets('shows VERIFY IDENTITY heading', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      await tester.pumpAndSettle();

      expect(find.text('VERIFY IDENTITY'), findsOneWidget);
    });

    testWidgets('shows VERIFY & CONTINUE button', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      await tester.pumpAndSettle();

      expect(find.text('VERIFY & CONTINUE'), findsOneWidget);
    });

    testWidgets('shows Resend OTP link', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      await tester.pumpAndSettle();

      expect(find.text('Resend OTP'), findsOneWidget);
    });

    testWidgets('back button is present in AppBar', (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });

  group('OtpVerificationScreen — OTP length validation', () {
    testWidgets('shows error SnackBar when tapping verify with no digits entered',
        (tester) async {
      await tester.pumpWidget(_wrap(_screen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFY & CONTINUE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Please enter the complete 6-digit OTP'),
        findsOneWidget,
      );
    });

    testWidgets('does not call verifyOtp when OTP field is empty', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(_screen(
        verifyOverride: (otp, {verificationId}) async {
          called = true;
        },
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('VERIFY & CONTINUE'));
      await tester.pump();

      expect(called, isFalse);
    });
  });

  group('OtpVerificationScreen — verify flow', () {
    testWidgets('shows loading indicator while verifying', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(_screen(
        verifyOverride: (otp, {verificationId}) => completer.future,
      )));
      await tester.pumpAndSettle();

      await _enter6Digits(tester, '123456');
      await tester.tap(find.text('VERIFY & CONTINUE'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete with error to prevent navigation to MainScreen in tests
      completer.completeError('cancelled');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('shows error SnackBar when verification throws', (tester) async {
      await tester.pumpWidget(_wrap(_screen(
        verifyOverride: (otp, {verificationId}) async {
          throw Exception('Invalid OTP code. Please check and try again.');
        },
      )));
      await tester.pumpAndSettle();

      await _enter6Digits(tester, '999999');
      await tester.tap(find.text('VERIFY & CONTINUE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.text('Invalid OTP code. Please check and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('hides loading indicator after verification fails', (tester) async {
      await tester.pumpWidget(_wrap(_screen(
        verifyOverride: (otp, {verificationId}) async {
          throw Exception('Session expired');
        },
      )));
      await tester.pumpAndSettle();

      await _enter6Digits(tester, '123456');
      await tester.tap(find.text('VERIFY & CONTINUE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('VERIFY & CONTINUE'), findsOneWidget);
    });

    testWidgets('passes the correct OTP and verificationId to the callback',
        (tester) async {
      String? capturedOtp;
      String? capturedVid;

      await tester.pumpWidget(_wrap(_screen(
        verificationId: 'real-vid-123',
        // Throw after capturing to prevent navigation to MainScreen
        verifyOverride: (otp, {verificationId}) async {
          capturedOtp = otp;
          capturedVid = verificationId;
          throw Exception('stop-navigation');
        },
      )));
      await tester.pumpAndSettle();

      await _enter6Digits(tester, '654321');
      await tester.tap(find.text('VERIFY & CONTINUE'));
      await tester.pump();
      await tester.pump();

      expect(capturedOtp, '654321');
      expect(capturedVid, 'real-vid-123');
    });
  });

  group('OtpVerificationScreen — resend flow', () {
    testWidgets('shows spinner while resending OTP', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_wrap(_screen(
        resendOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) =>
            completer.future,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend OTP'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pump();
    });

    testWidgets('shows success SnackBar after successful resend', (tester) async {
      await tester.pumpWidget(_wrap(_screen(
        phoneNumber: '9876543210',
        resendOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) async {
          onCodeSent('new-vid');
        },
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('New OTP sent to +91 9876543210'),
        findsOneWidget,
      );
    });

    testWidgets('shows error SnackBar when resend fails', (tester) async {
      await tester.pumpWidget(_wrap(_screen(
        resendOverride: ({
          required phoneNumber,
          required onCodeSent,
          required onError,
        }) async {
          onError('quota exceeded');
        },
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Resend OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Failed to resend OTP'), findsOneWidget);
    });
  });
}
