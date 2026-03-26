import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FirebaseAuthService {
  // Rule 2: singleton — use .instance, never instantiate directly
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Key names — must match every other file that reads these
  static const String _verificationKey = 'verificationId';
  static const String _memberIdKey = 'memberId';

  int? _resendToken;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Verification ID helpers ───────────────────────────────────────────────

  Future<void> _saveVerificationId(String verificationId) async {
    try {
      await _secureStorage.write(key: _verificationKey, value: verificationId);
      debugPrint('💾 Verification ID saved securely');
    } catch (e) {
      debugPrint('⚠ Error saving verification ID: $e');
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
      debugPrint('⚠ Error loading verification ID: $e');
      return null;
    }
  }

  Future<void> _clearVerificationId() async {
    try {
      await _secureStorage.delete(key: _verificationKey);
      debugPrint('🗑 Verification ID cleared');
    } catch (e) {
      debugPrint('⚠ Error clearing verification ID: $e');
    }
  }

  // ─── Member ID helpers ─────────────────────────────────────────────────────

  Future<void> _saveMemberId(String memberId) async {
    try {
      await _secureStorage.write(key: _memberIdKey, value: memberId);
      debugPrint('💾 memberId saved to secure storage: $memberId');
    } catch (e) {
      debugPrint('⚠ Error saving memberId: $e');
    }
  }

  Future<String?> _loadMemberId() async {
    try {
      return await _secureStorage.read(key: _memberIdKey);
    } catch (e) {
      debugPrint('⚠ Error loading memberId: $e');
      return null;
    }
  }

  Future<void> _clearMemberId() async {
    try {
      await _secureStorage.delete(key: _memberIdKey);
      debugPrint('🗑 memberId cleared');
    } catch (e) {
      debugPrint('⚠ Error clearing memberId: $e');
    }
  }

  // ─── Member lookup ─────────────────────────────────────────────────────────
  // Returns {'id': firestoreDocId, ...memberData} or null.
  // Called ONLY after user is authenticated (post-OTP). Never before.

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
          debugPrint('✅ Member found: ${data['name']} (${doc.id})');
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

  // ─── Store memberId after successful sign-in ───────────────────────────────
  // Rule 20: NEVER writes to users/{uid} — phone OTP members have NO users doc.

  Future<void> _storeMemberIdFromUser(User user) async {
    try {
      final phone = (user.phoneNumber ?? '')
          .replaceAll('+91', '')
          .replaceAll('+', '')
          .replaceAll(RegExp(r'[^0-9]'), '');

      if (phone.isEmpty) {
        debugPrint('⚠ No phone number on authenticated user');
        return;
      }

      final memberData = await checkMemberExists(phone);

      if (memberData != null) {
        final memberId = memberData['id'] as String;
        debugPrint('✅ Linked member: ${memberData['name']} (ID: $memberId)');

        await _saveMemberId(memberId);

        await _firestore.collection('members').doc(memberId).update({
          'uid': user.uid,
          'last_app_login': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ memberId cached and uid linked to member doc');
      } else {
        debugPrint('⚠ No member record found for phone: $phone');
        // Do NOT write to users/{uid} — Rule 20
        // getCurrentMemberId phone fallback will handle this on next app open
      }
    } catch (e) {
      debugPrint('❌ Error in _storeMemberIdFromUser: $e');
    }
  }

  // ─── Send OTP ──────────────────────────────────────────────────────────────
  // Jules' signature preserved — all new params are optional

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
          debugPrint('✅ Auto verification triggered');
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            await _clearVerificationId();
            if (userCredential.user != null) {
              await _storeMemberIdFromUser(userCredential.user!);
            }
            onAutoVerify?.call();
          } catch (e) {
            debugPrint('❌ Auto sign-in failed: $e');
            onError('Auto-verification failed. Please enter OTP manually.');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.code} - ${e.message}');
          onError(_friendlyAuthError(e.code, e.message));
        },

        codeSent: (String verificationId, int? resendToken) async {
          debugPrint('📨 OTP sent successfully');
          _resendToken = resendToken;
          await _saveVerificationId(verificationId);
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (String verificationId) async {
          debugPrint(
            '⏰ Auto-retrieval timeout — saving latest verification ID',
          );
          await _saveVerificationId(verificationId);
          onCodeAutoRetrievalTimeout?.call(verificationId);
        },
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError(e.toString());
    }
  }

  // ─── Verify OTP ────────────────────────────────────────────────────────────
  // Rule 3: verificationId passed explicitly from screen state.
  // Storage is fallback only — never primary source.

  Future<UserCredential?> verifyOTP(
    String otp, {
    String? verificationId,
  }) async {
    try {
      final cleanOtp = otp.replaceAll(RegExp(r'[^0-9]'), '');
      final resolvedId = verificationId ?? await _loadVerificationId();

      if (resolvedId == null || resolvedId.isEmpty) {
        throw Exception(
          'Verification session expired. Please request a new OTP.',
        );
      }

      debugPrint('🔐 Verifying OTP with ID: ${resolvedId.substring(0, 10)}...');

      final credential = PhoneAuthProvider.credential(
        verificationId: resolvedId,
        smsCode: cleanOtp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _clearVerificationId();

      if (userCredential.user != null) {
        await _storeMemberIdFromUser(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      await _clearVerificationId();
      throw Exception(_friendlyAuthError(e.code, e.message));
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      await _clearVerificationId();
      rethrow;
    }
  }

  // ─── Get current member ID ─────────────────────────────────────────────────
  // Returns the Firestore document ID (NOT auth.uid) — Rule 21.
  // Resolution order:
  //   1. Secure storage — instant, no network (set during login / auto-verify)
  //   2. Phone lookup   — user is authenticated, Firestore rules allow this
  //
  // Rule 20: NO users/{uid} read — members have NO users collection doc.
  // Rule 21: Returns Firestore doc ID. For auth UID use currentUser!.uid.

  Future<String?> getCurrentMemberId() async {
    try {
      if (currentUser == null) return null;

      // ── 1. Secure storage (fastest — no network) ────────────────────────
      final cached = await _loadMemberId();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('✅ memberId from secure storage: $cached');
        return cached;
      }

      // ── 2. Phone fallback (user is authenticated at this point) ─────────
      final phone = currentUser!.phoneNumber;
      if (phone == null || phone.isEmpty) {
        debugPrint('❌ No phone number on authenticated user');
        return null;
      }

      debugPrint(
        '🔄 memberId not cached — falling back to phone lookup: $phone',
      );
      final memberData = await checkMemberExists(phone);

      if (memberData == null) {
        debugPrint('❌ Member not found via phone fallback');
        return null;
      }

      final memberId = memberData['id'] as String;

      await _saveMemberId(memberId);

      await _firestore.collection('members').doc(memberId).update({
        'uid': currentUser!.uid,
        'last_app_login': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '✅ memberId resolved via phone fallback and cached: $memberId',
      );
      return memberId;
    } catch (e) {
      debugPrint('❌ Error getting memberId: $e');
      return null;
    }
  }

  // ─── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _clearVerificationId();
      await _clearMemberId();
      await _auth.signOut();
      debugPrint('✅ User signed out — memberId and verificationId cleared');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  // ─── Friendly error messages ───────────────────────────────────────────────

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
}
