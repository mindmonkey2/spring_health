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
  static const String _memberIdKey     = 'member_id';
  int? _resendToken;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Verification ID helpers ──────────────────────────────────────────────

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
      if (saved != null) debugPrint('✅ Loaded verification ID from secure storage');
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

  // ─── Member ID helpers (secure storage) ──────────────────────────────────

  Future<void> _saveMemberId(String memberId) async {
    try {
      await _secureStorage.write(key: _memberIdKey, value: memberId);
      debugPrint('💾 Member ID saved to secure storage: $memberId');
    } catch (e) {
      debugPrint('⚠️ Error saving member ID: $e');
    }
  }

  Future<String?> _loadMemberId() async {
    try {
      return await _secureStorage.read(key: _memberIdKey);
    } catch (e) {
      debugPrint('⚠️ Error loading member ID: $e');
      return null;
    }
  }

  Future<void> _clearMemberId() async {
    try {
      await _secureStorage.delete(key: _memberIdKey);
    } catch (e) {
      debugPrint('⚠️ Error clearing member ID: $e');
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
          final doc  = snap.docs.first;
          final data = doc.data() as Map<String, dynamic>;
          final memberName = data['name'] as String? ?? 'Unknown';
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
      final clean     = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final fullPhone = '+91$clean';
      debugPrint('📱 Sending OTP to: $fullPhone');

      await _clearVerificationId();

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,

        // ── Auto-verify (Android) ──────────────────────────────────────────
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('✅ Auto verification completed');
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            await _clearVerificationId();
            debugPrint('✅ Auto sign-in successful');

            // Store memberId immediately after auto sign-in
            if (userCredential.user != null) {
              await _createOrUpdateUserDocument(userCredential.user!);
            }

            onAutoVerify?.call();
          } catch (e) {
            debugPrint('❌ Auto sign-in failed: $e');
            onError('Auto-verification failed. Please enter OTP manually.');
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Verification failed: \${e.code} - \${e.message}');
          onError(_friendlyAuthError(e.code, e.message));
        },

        codeSent: (String verificationId, int? resendToken) async {
          debugPrint('📨 OTP sent successfully');
          _resendToken = resendToken;
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
  Future<UserCredential?> verifyOTP(
    String otp, {
    String? verificationId,
  }) async {
    try {
      final cleanOtp    = otp.replaceAll(RegExp(r'[^0-9]'), '');
      final resolvedId  = verificationId ?? await _loadVerificationId();

      debugPrint('🔐 Verifying OTP: $cleanOtp');

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
        // Create/update user doc AND store memberId in secure storage
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

  // ─── User document + member linking ──────────────────────────────────────

  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final phone = (user.phoneNumber ?? '')
          .replaceAll('+91', '')
          .replaceAll('+', '')
          .replaceAll(RegExp(r'[^0-9]'), '');

      debugPrint('👤 Creating/updating user document for phone: $phone');

      final memberData = await checkMemberExists(phone);

      if (memberData != null) {
        final memberId   = memberData['id'] as String;
        final memberName = memberData['name'] ?? 'Unknown';
        debugPrint('✅ Found member: $memberName (ID: $memberId)');

        // 1. Write to users collection
        await _firestore.collection('users').doc(user.uid).set({
          'role'        : 'Member',
          'phone_number': phone,
          'member_id'   : memberId,
          'created_at'  : FieldValue.serverTimestamp(),
          'last_login'  : FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 2. Link auth UID back to member document
        await _firestore.collection('members').doc(memberId).update({
          'user_id'       : user.uid,
          'last_app_login': FieldValue.serverTimestamp(),
        });

        // 3. Save to secure storage — the fast path for future logins
        await _saveMemberId(memberId);

        debugPrint('✅ User + member documents updated, memberId cached');
      } else {
        debugPrint('⚠️ No member record found for phone: $phone');
        // Write minimal users doc so getCurrentMemberId can detect pending state
        await _firestore.collection('users').doc(user.uid).set({
          'role'        : 'pending',
          'phone_number': phone,
          'created_at'  : FieldValue.serverTimestamp(),
          'last_login'  : FieldValue.serverTimestamp(),
          'error'       : 'Member not found in database',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('❌ Error creating/updating user document: $e');
    }
  }

  // ─── Get current member ID ────────────────────────────────────────────────

  /// Resolution order:
  /// 1. Secure storage (instant, no network — set during login/auto-verify)
  /// 2. Firestore users/{uid}.member_id (one network call, allowed by rules)
  /// 3. Phone-based lookup fallback (authenticated phone query)
  Future<String?> getCurrentMemberId() async {
    try {
      if (currentUser == null) return null;

      // ── 1. Secure storage (fastest) ──────────────────────────────────────
      final cached = await _loadMemberId();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('✅ memberId from secure storage: $cached');
        return cached;
      }

      // ── 2. Firestore users/{uid} doc ──────────────────────────────────────
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (doc.exists) {
        final memberId = doc.data()?['member_id'];
        if (memberId != null && memberId.toString().isNotEmpty) {
          debugPrint('✅ memberId from users doc: $memberId');
          await _saveMemberId(memberId as String); // cache for next time
          return memberId as String;
        }
      }

      // ── 3. Phone fallback (user is authenticated at this point) ───────────
      final phone = currentUser!.phoneNumber;
      if (phone == null || phone.isEmpty) {
        debugPrint('❌ No phone on authenticated user');
        return null;
      }

      debugPrint('🔄 Falling back to phone lookup: $phone');
      final memberData = await checkMemberExists(phone);
      if (memberData == null) {
        debugPrint('❌ Member not found via phone fallback');
        return null;
      }

      final memberId = memberData['id'] as String;

      // Cache in both places so fallback is never needed again
      await _saveMemberId(memberId);
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'member_id' : memberId,
        'last_login': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ memberId found via fallback and cached: $memberId');
      return memberId;
    } catch (e) {
      debugPrint('❌ Error getting member ID: $e');
      return null;
    }
  }

  // ─── Friendly error messages ──────────────────────────────────────────────

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

  // ─── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _clearVerificationId();
      await _clearMemberId();        // ← clear cached memberId on logout
      await _auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }
}
