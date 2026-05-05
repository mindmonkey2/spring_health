import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spring_health_studio/models/user_model.dart';
import 'package:spring_health_studio/screens/auth/login_screen.dart';
import 'package:spring_health_studio/services/auth_service.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

/// Configurable fake — returns [user], throws [throwError], or suspends via [completer].
/// Optionally records the most recent call in [lastEmail] / [lastPassword].
class _FakeAuthService extends Fake implements AuthService {
  final UserModel? user;
  final String? throwError;
  final Completer<UserModel>? completer;

  String? lastEmail;
  String? lastPassword;

  _FakeAuthService({this.user, this.throwError, this.completer});

  @override
  Future<UserModel> signInAndResolveUser(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    if (completer != null) return completer!.future;
    if (throwError != null) throw throwError!;
    return user!;
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(home: child);

Future<void> _fillAndSubmit(
  WidgetTester tester, {
  String email = 'test@gym.com',
  String password = 'password123',
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Enter your email'),
    email,
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Enter your password'),
    password,
  );
  await tester.tap(find.text('SIGN IN'));
  await tester.pump();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('Studio LoginScreen — rendering', () {
    testWidgets('renders email field, password field, and sign-in button',
        (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(
          find.widgetWithText(TextFormField, 'Enter your email'), findsOneWidget);
      expect(
          find.widgetWithText(TextFormField, 'Enter your password'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('shows app title and welcome text', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SPRING HEALTH STUDIO'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('password is obscured by default', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      final field = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Enter your password'),
          matching: find.byType(TextField),
        ),
      );
      expect(field.obscureText, isTrue);
    });

    testWidgets('password visibility toggle reveals then re-hides password',
        (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final visibleField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Enter your password'),
          matching: find.byType(TextField),
        ),
      );
      expect(visibleField.obscureText, isFalse);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      final hiddenField = tester.widget<TextField>(
        find.descendant(
          of: find.widgetWithText(TextFormField, 'Enter your password'),
          matching: find.byType(TextField),
        ),
      );
      expect(hiddenField.obscureText, isTrue);
    });
  });

  group('Studio LoginScreen — form validation', () {
    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(user: null),
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error when email has no @ symbol', (tester) async {
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(user: null),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'notanemail',
      );
      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(user: null),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'test@gym.com',
      );
      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows error when password is fewer than 6 characters',
        (tester) async {
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(user: null),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'test@gym.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        'abc',
      );
      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows no validation errors for valid credentials', (tester) async {
      final completer = Completer<UserModel>();
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(completer: completer),
      )));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your email'),
        'valid@gym.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter your password'),
        'validpass',
      );
      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Password must be at least 6 characters'), findsNothing);

      completer.completeError('cancelled');
      await tester.pump();
    });

    testWidgets('does not call auth service when form is invalid', (tester) async {
      final fakeAuth = _FakeAuthService(user: null);
      await tester.pumpWidget(_wrap(LoginScreen(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SIGN IN'));
      await tester.pump();

      // signInAndResolveUser was never reached — lastEmail stays null
      expect(fakeAuth.lastEmail, isNull);
    });
  });

  group('Studio LoginScreen — auth flow', () {
    testWidgets('shows loading indicator while login is in progress',
        (tester) async {
      final completer = Completer<UserModel>();
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(completer: completer),
      )));
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.completeError('cancelled');
      await tester.pump();
    });

    testWidgets('calls signInAndResolveUser with the entered credentials',
        (tester) async {
      final fakeAuth = _FakeAuthService(throwError: 'stop');
      await tester.pumpWidget(_wrap(LoginScreen(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester, email: 'owner@gym.com', password: 'hunter2');
      await tester.pump();

      expect(fakeAuth.lastEmail, 'owner@gym.com');
      expect(fakeAuth.lastPassword, 'hunter2');
    });

    testWidgets('shows error message on auth failure', (tester) async {
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(throwError: 'No user found with this email.'),
      )));
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester);
      await tester.pump();

      expect(find.text('No user found with this email.'), findsOneWidget);
    });

    testWidgets('hides loading indicator after auth failure', (tester) async {
      await tester.pumpWidget(_wrap(LoginScreen(
        authService: _FakeAuthService(throwError: 'Incorrect password.'),
      )));
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('calls signInAndResolveUser with correct credentials for Owner',
        (tester) async {
      final fakeAuth = _FakeAuthService(throwError: 'stop-before-navigation');
      await tester.pumpWidget(_wrap(LoginScreen(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await _fillAndSubmit(tester, email: 'owner@gym.com', password: 'hunter2');
      await tester.pump();

      expect(fakeAuth.lastEmail, 'owner@gym.com');
      expect(fakeAuth.lastPassword, 'hunter2');
    });

    testWidgets('calls signInAndResolveUser with correct credentials for Receptionist',
        (tester) async {
      final fakeAuth = _FakeAuthService(
        throwError: 'stop-before-navigation',
      );
      await tester.pumpWidget(_wrap(LoginScreen(authService: fakeAuth)));
      await tester.pumpAndSettle();

      await _fillAndSubmit(
          tester, email: 'receptionist@gym.com', password: 'abc123');
      await tester.pump();

      expect(fakeAuth.lastEmail, 'receptionist@gym.com');
    });
  });
}
