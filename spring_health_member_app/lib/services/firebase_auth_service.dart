import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseAuthService {
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _verificationKey = 'otp_verification_id';
  int? _resendToken;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Verification ID persistence ─────────────────────────────────────────

  Future<void> _saveVerificationId(String verificationId) async {
    try {
      await _secureStorage.write(key: _verificationKey, value: verificationId);
      debugPrint('💾 Verification ID saved securely');
    } catch (e) {
      debugPrint('⚠️ Error saving verification ID: $e');
    }
  }

  Future<String?> _loadVerificationId() async {
    try {
      final saved = await _secureStorage.read(key: _verificationKey);
      if (saved != null) {
        debugPrint('✅ Loaded verification ID from secure storage');
      }
      return saved;
    } catch (e) {
      debugPrint('⚠️ Error loading verification ID: $e');
      return null;
    }
  }

  Future<void> _clearVerificationId() async {
    try {
      await _secureStorage.delete(key: _verificationKey);
      debugPrint('🗑️ Verification ID cleared');
    } catch (e) {
      debugPrint('⚠️ Error clearing verification ID: $e');
    }
  }

  // ─── Member lookup ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> checkMemberExists(String phoneNumber) async {
    try {
      final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      debugPrint('🔍 Checking member with phone: $clean');

      final formats = [clean, '+91$clean'];

      for (final format in formats) {
        QuerySnapshot snap = await _firestore
            .collection('members')
            .where('phone', isEqualTo: format)
            .where('isArchived', isEqualTo: false)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) {
          snap = await _firestore
              .collection('members')
              .where('phone', isEqualTo: format)
              .limit(1)
              .get();
        }

        if (snap.docs.isNotEmpty) {
          final doc = snap.docs.first;
          final data = doc.data() as Map<String, dynamic>;
          final memberName = data['name'] ?? 'Unknown';
          debugPrint('✅ Member found: $memberName (${doc.id})');
          return {'id': doc.id, ...data};
        }
      }

      debugPrint('❌ No member found with phone: $clean');
      return null;
    } catch (e) {
      debugPrint('❌ Error checking member: $e');
      return null;
    }
  }

  // ─── Send OTP ─────────────────────────────────────────────────────────────

  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    VoidCallback? onAutoVerify,
    Function(String verificationId)? onCodeAutoRetrievalTimeout,
  }) async {
    try {
      final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final fullPhone = '+91$clean';
      debugPrint('📱 Sending OTP to: $fullPhone');

      await _clearVerificationId();

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto verification completed');
          try {
            await _auth.signInWithCredential(credential);
            await _clearVerificationId();
            debugPrint('✅ Auto sign-in successful');
            onAutoVerify?.call();
          } catch (e) {
            debugPrint('❌ Auto sign-in failed: $e');
            onError('Auto-verification failed. Please enter OTP manually.');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          final code = e.code;
          final msg = e.message;
          debugPrint('❌ Verification failed: $code - $msg');
          onError(_friendlyAuthError(code, msg));
        },

        codeSent: (String verificationId, int? resendToken) async {
          debugPrint('📨 OTP sent successfully');
          _resendToken = resendToken;
          // Save BEFORE calling onCodeSent so verificationId is guaranteed
          // to be in storage when verifyOTP() is called
          await _saveVerificationId(verificationId);
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) async {
          debugPrint('⏰ Auto-retrieval timeout — saving latest verification ID');
          await _saveVerificationId(verificationId);
          onCodeAutoRetrievalTimeout?.call(verificationId);
        },
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError(e.toString());
    }
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────

  /// Accepts verificationId explicitly so the screen's _currentVerificationId
  /// is used as primary source, with _loadVerificationId() as fallback only.
  Future<UserCredential> verifyOTP(
    String otp, {
    String? verificationId,
  }) async {
    try {
      final cleanOtp = otp.replaceAll(RegExp(r'[^0-9]'), '');
      debugPrint('🔐 Verifying OTP: $cleanOtp');

      // Prefer the verificationId passed from the screen
      final resolvedId = verificationId ?? await _loadVerificationId();

      if (resolvedId == null || resolvedId.isEmpty) {
        debugPrint('❌ No verification ID found');
        throw Exception(
            'Verification session expired. Please request a new OTP.');
      }

      final idPreview = resolvedId.substring(0, 10);
      debugPrint('🔑 Using verification ID: $idPreview...');

      final credential = PhoneAuthProvider.credential(
        verificationId: resolvedId,
        smsCode: cleanOtp,
      );

      debugPrint('🔓 Attempting sign in...');
      final userCredential = await _auth.signInWithCredential(credential);

      await _clearVerificationId();

      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        debugPrint('✅ Sign in successful! UID: $uid');
        await _createOrUpdateUserDocument(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      final code = e.code;
      final msg = e.message;
      debugPrint('❌ Firebase Auth Error: $code - $msg');
      await _clearVerificationId();
      throw Exception(_friendlyAuthError(code, msg));
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      await _clearVerificationId();
      rethrow;
    }
  }

  // ─── User document ────────────────────────────────────────────────────────

  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final phone = (user.phoneNumber ?? '')
          .replaceAll('+91', '')
          .replaceAll('+', '')
          .replaceAll(RegExp(r'[^0-9]'), '');

      debugPrint('👤 Creating/updating user document for phone: $phone');

      final memberData = await checkMemberExists(phone);

      if (memberData != null) {
        final memberId = memberData['id'];
        final memberName = memberData['name'] ?? 'Unknown';
        debugPrint('✅ Found member: $memberName (ID: $memberId)');

        await _firestore.collection('users').doc(user.uid).set({
          'role': 'member',
          'phone_number': phone,
          'member_id': memberId,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await _firestore.collection('members').doc(memberId).update({
          'user_id': user.uid,
          'last_app_login': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ User + member documents updated');
      } else {
        debugPrint('⚠️ No member record found for phone: $phone');
        await _firestore.collection('users').doc(user.uid).set({
          'role': 'pending',
          'phone_number': phone,
          'created_at': FieldValue.serverTimestamp(),
          'last_login': FieldValue.serverTimestamp(),
          'error': 'Member not found in database',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('❌ Error creating/updating user document: $e');
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<String?> getCurrentMemberId() async {
    try {
      if (currentUser == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        final memberId = doc.data()?['member_id'];
        debugPrint('✅ Current member ID: $memberId');
        return memberId;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting member ID: $e');
      return null;
    }
  }

  String _friendlyAuthError(String code, String? message) {
    switch (code) {
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new code.';
      case 'invalid-verification-id':
        return 'Verification session invalid. Please restart.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait before trying again.';
      case 'invalid-phone-number':
        return 'Invalid phone number. Please check and try again.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return message ?? 'Verification failed. Please try again.';
    }
  }

  Future<void> signOut() async {
    try {
      await _clearVerificationId();
      await _auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }
}
