import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spring_health_studio/services/auth_service.dart';

class MockFirebaseAuth extends Fake implements FirebaseAuth {
  String? _throwCode;

  void setThrowCode(String? code) {
    _throwCode = code;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (_throwCode != null) {
      throw FirebaseAuthException(code: _throwCode!, message: 'Test error');
    }
    return MockUserCredential();
  }
}

class MockUserCredential extends Fake implements UserCredential {
  @override
  User? get user => MockUser();
}

class MockUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
  @override
  String? get email => 'test@example.com';
}

class MockFirebaseFirestore extends Fake implements FirebaseFirestore {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockAuth, firestore: MockFirebaseFirestore());
    });

    group('signInWithEmailAndPassword', () {
      test('returns user on success', () async {
        final user = await authService.signInWithEmailAndPassword('test@test.com', 'password');
        expect(user?.uid, 'test-uid');
        expect(user?.email, 'test@example.com');
      });

      test('throws correct message for user-not-found', () async {
        mockAuth.setThrowCode('user-not-found');

        expect(
          () => authService.signInWithEmailAndPassword('test@test.com', 'password'),
          throwsA('No user found with this email.'),
        );
      });

      test('throws correct message for wrong-password', () async {
        mockAuth.setThrowCode('wrong-password');

        expect(
          () => authService.signInWithEmailAndPassword('test@test.com', 'password'),
          throwsA('Incorrect password.'),
        );
      });

      test('throws correct message for invalid-email', () async {
        mockAuth.setThrowCode('invalid-email');

        expect(
          () => authService.signInWithEmailAndPassword('test@test.com', 'password'),
          throwsA('Invalid email address.'),
        );
      });

      test('throws correct message for user-disabled', () async {
        mockAuth.setThrowCode('user-disabled');

        expect(
          () => authService.signInWithEmailAndPassword('test@test.com', 'password'),
          throwsA('This account has been disabled.'),
        );
      });

      test('throws default message for unknown error', () async {
        mockAuth.setThrowCode('unknown');

        expect(
          () => authService.signInWithEmailAndPassword('test@test.com', 'password'),
          throwsA(startsWith('Authentication error:')),
        );
      });
    });

    group('signInAndResolveUser Error Paths', () {
      test('throws handled FirebaseAuthException', () async {
        mockAuth.setThrowCode('user-not-found');

        expect(
          () => authService.signInAndResolveUser('test@test.com', 'password'),
          throwsA('No user found with this email.'),
        );
      });
    });
  });
}
