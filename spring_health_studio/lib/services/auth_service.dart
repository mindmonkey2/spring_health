import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<UserModel> signInAndResolveUser(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUid = result.user!.uid;

      String? trainerId;
      String role = '';
      String? name;
      String? branch;
      DateTime createdAt = DateTime.now();

      // ── Try users collection first ──────────────────────────────
      final userDoc = await _firestore
      .collection('users')
      .doc(firebaseUid)
      .get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        role   = (userData['role']   as String? ?? '').trim();
        name   =  userData['name']   as String?;
        branch =  userData['branch'] as String?;
        createdAt = userData['createdAt'] != null
        ? (userData['createdAt'] as Timestamp).toDate()
        : DateTime.now();
      }
      // ── If no users doc, still allow trainer login ──────────────

      if (role.toLowerCase() == 'trainer' || role.isEmpty) {
        final trainerQuery = await _firestore
        .collection('trainers')
        .where('authUid', isEqualTo: firebaseUid)
        .limit(1)
        .get();

        if (trainerQuery.docs.isEmpty) {
          throw 'Trainer profile not found. Contact admin.';
        }

        final trainerData = trainerQuery.docs.first.data();
        trainerId = trainerQuery.docs.first.id;

        name   ??= trainerData['name']   as String?;
        branch ??= trainerData['branch'] as String?;
        role     = 'Trainer';
      }

      return UserModel(
        uid:       firebaseUid,
        email:     email,
        role:      role,
        name:      name,
        branch:    branch,
        trainerId: trainerId,
        createdAt: createdAt,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserCredential> createUserWithEmailPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
