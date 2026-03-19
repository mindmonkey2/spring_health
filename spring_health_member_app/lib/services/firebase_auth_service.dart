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

  String? _verificationId;
  int? _resendToken;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Verification ID persistence ─────────────────────────────────────────

  Future<void> _saveVerificationId(String verificationId) async {
    try {
      _verificationId = verificationId;
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(key: 'verification_id', value: verificationId);
      await secureStorage.write(key: 'verification_time', value: DateTime.now().millisecondsSinceEpoch.toString());
      debugPrint('💾 Verification ID saved: ${verificationId.substring(0, 10)}...');
    } catch (e) {
      debugPrint('⚠️ Error saving verification ID: $e');
    }
  }

  Future<String?> _loadVerificationId() async {
    try {
      // Use in-memory cache first — avoids async storage delay
      if (_verificationId != null) {
        debugPrint('✅ Using cached verification ID');
        return _verificationId;
      }

      const secureStorage = FlutterSecureStorage();
      final savedId = await secureStorage.read(key: 'verification_id');
      final savedTimeString = await secureStorage.read(key: 'verification_time');
      final savedTime = savedTimeString != null ? int.tryParse(savedTimeString) ?? 0 : 0;

      final age = (DateTime.now().millisecondsSinceEpoch - savedTime) / 1000;

      if (savedId != null && age < 120) {
        debugPrint('✅ Loaded verification ID from storage (age: ${age.toInt()}s)');
        _verificationId = savedId;
        return savedId;
      } else if (savedId != null) {
        debugPrint('⚠️ Verification ID expired (age: ${age.toInt()}s)');
        await secureStorage.delete(key: 'verification_id');
        await secureStorage.delete(key: 'verification_time');
      }
      return null;
    } catch (e) {
      debugPrint('⚠️ Error loading verification ID: $e');
      return null;
    }
  }

  Future<void> _clearVerificationId() async {
    try {
      _verificationId = null;
      const secureStorage = FlutterSecureStorage();
      await secureStorage.delete(key: 'verification_id');
      await secureStorage.delete(key: 'verification_time');
      debugPrint('🗑️ Verification ID cleared');
    } catch (e) {
      debugPrint('⚠️ Error clearing verification ID: $e');
    }
  }

  // ─── Member lookup ────────────────────────────────────────────────────────

  /// Tries phone as-is, with +91, and without country code — in that order.
  Future<Map<String, dynamic>?> checkMemberExists(String phoneNumber) async {
    try {
      final clean = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      debugPrint('🔍 Checking member with phone: $clean');

      // Try all three formats in one round-trip via whereIn
      final formats = [clean, '+91$clean'];

      for (final format in formats) {
        QuerySnapshot snap = await _firestore
        .collection('members')
        .where('phone', isEqualTo: format)
        .where('isArchived', isEqualTo: false)
        .limit(1)
        .get();

        if (snap.docs.isEmpty) {
          // Retry without isArchived filter (older records may not have the field)
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
    Function(PhoneAuthCredential)? onAutoVerify,
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
            // Auto-verification (Android only) — fires before user types OTP
            debugPrint('✅ Auto verification completed');
            if (onAutoVerify != null) {
              onAutoVerify(credential);
            } else {
              try {
                await _auth.signInWithCredential(credential);
                debugPrint('✅ Auto sign-in successful');
              } catch (e) {
                debugPrint('❌ Auto sign-in failed: $e');
              }
            }
          },

          verificationFailed: (FirebaseAuthException e) {
            debugPrint('❌ Verification failed: \${e.code} - \${e.message}');
            final message = _friendlyAuthError(e.code, e.message);
            onError(message);
          },

          codeSent: (String verificationId, int? resendToken) async {
            debugPrint('📨 OTP sent successfully');
            _resendToken = resendToken;
            // FIX: save BEFORE calling onCodeSent so verificationId is
            // guaranteed to be in memory when verifyOTP() is called
            await _saveVerificationId(verificationId);
            onCodeSent(verificationId);
          },

          codeAutoRetrievalTimeout: (String verificationId) async {
            debugPrint('⏰ Auto-retrieval timeout — saving latest verification ID');
            await _saveVerificationId(verificationId);
          },
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError(e.toString());
    }
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────

  /// FIX: accepts verificationId explicitly so the screen's widget.verificationId
  /// is used as primary source, with _loadVerificationId() as fallback.
  Future<UserCredential> verifyOTP(
    String otp, {
      String? verificationId,
    }) async {
      try {
        final cleanOtp = otp.replaceAll(RegExp(r'[^0-9]'), '');
        debugPrint('🔐 Verifying OTP: $cleanOtp');

        // FIX: prefer the verificationId passed from the screen widget
        final resolvedId = verificationId ?? await _loadVerificationId();

        if (resolvedId == null || resolvedId.isEmpty) {
          debugPrint('❌ No verification ID found');
          throw Exception('Verification session expired. Please request a new OTP.');
        }

        debugPrint('🔑 Using verification ID: \${resolvedId.substring(0, 10)}...');

        final credential = PhoneAuthProvider.credential(
          verificationId: resolvedId,
          smsCode: cleanOtp,
        );

        debugPrint('🔓 Attempting sign in...');
        final userCredential = await _auth.signInWithCredential(credential);

        await _clearVerificationId();

        if (userCredential.user != null) {
          debugPrint('✅ Sign in successful! UID: \${userCredential.user!.uid}');
          await _createOrUpdateUserDocument(userCredential.user!);
        }

        return userCredential;
      } on FirebaseAuthException catch (e) {
        debugPrint('❌ Firebase Auth Error: \${e.code} - \${e.message}');
        await _clearVerificationId();
        throw Exception(_friendlyAuthError(e.code, e.message));
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
