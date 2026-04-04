import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// FirebaseAuthService — Member App only.
///
/// Architecture rules (from Spring-Health-Memory.md):
/// Rule 20: NEVER write to users/{uid} — phone OTP members have NO users doc.
/// Rule 21: memberId = Firestore doc ID from members collection, NOT auth.uid.
/// Rule 22: isMember in Firestore rules always returns false for phone OTP users.
///          All member-side rules use isSignedIn && isOwnRecord(resource.data).
/// Rule 23: checkMemberExists is ONLY called after the user is authenticated.
///          Never call it on the phone-entry screen (user not yet signed in →
///          Firestore rules deny → memberId never stored → "Member Not Found").
///
/// memberId resolution order (getCurrentMemberId):
///   1. FlutterSecureStorage  — instant, zero network
///   2. Phone lookup          — user is now authenticated, rules allow this
///
/// memberId is stored proactively at every sign-in path:
///   • verificationCompleted  (auto-verify)
///   • verifyOTP              (manual OTP entry)
///   • getCurrentMemberId     (cold start / app resume fallback)
/// memberId is cleared on signOut.

class FirebaseAuthService {
  // ── Singleton ────────────────────────────────────────────────────────────
  static final FirebaseAuthService instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => instance;
  FirebaseAuthService._internal();

  // ── Dependencies ─────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Storage key constants — must match every consumer ────────────────────
  static const String _verificationKey = 'verificationId';
  static const String _memberIdKey = 'memberId';

  int? _resendToken;

  // ── Auth state accessors ─────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ════════════════════════════════════════════════════════════════════════
  // VERIFICATION ID HELPERS
  // ════════════════════════════════════════════════════════════════════════

  Future<void> _saveVerificationId(String verificationId) async {
    try {
      await _secureStorage.write(key: _verificationKey, value: verificationId);
      debugPrint('✅ Verification ID saved securely');
    } catch (e) {
      debugPrint('❌ Error saving verification ID: $e');
    }
  }

  Future<String?> _loadVerificationId() async {
    try {
      final saved = await _secureStorage.read(key: _verificationKey);
      if (saved != null) {
        debugPrint('✅ Loaded verification ID from secure storage');
      }
      return saved; // returns null if not found
    } catch (e) {
      debugPrint('❌ Error loading verification ID: $e');
      return null;
    }
  }

  Future<void> _clearVerificationId() async {
    try {
      await _secureStorage.delete(key: _verificationKey);
      debugPrint('🗑️ Verification ID cleared');
    } catch (e) {
      debugPrint('❌ Error clearing verification ID: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // MEMBER ID HELPERS
  // ════════════════════════════════════════════════════════════════════════

  Future<void> _saveMemberId(String memberId) async {
    try {
      await _secureStorage.write(key: _memberIdKey, value: memberId);
      debugPrint('✅ memberId saved to secure storage: $memberId');
    } catch (e) {
      debugPrint('❌ Error saving memberId: $e');
    }
  }

  Future<String?> _loadMemberId() async {
    try {
      return await _secureStorage.read(key: _memberIdKey);
    } catch (e) {
      debugPrint('❌ Error loading memberId: $e');
      return null;
    }
  }

  Future<void> _clearMemberId() async {
    try {
      await _secureStorage.delete(key: _memberIdKey);
      debugPrint('🗑️ memberId cleared from secure storage');
    } catch (e) {
      debugPrint('❌ Error clearing memberId: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // MEMBER LOOKUP
  // Returns {'id': firestoreDocId, ...memberData} or null.
  // Rule 23: ONLY called AFTER the user is authenticated (post-OTP sign-in).
  //          Never call before OTP — Firestore rules will deny the read.
  // ════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>?> checkMemberExists(String phoneNumber) async {
    try {
      final raw = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      // Normalize to 10-digit, strip leading 91 if present
      final tenDigit = (raw.startsWith('91') && raw.length == 12)
      ? raw.substring(2)
      : raw;

      // Try all storage formats — Firestore may store with or without +91
      final formats = [tenDigit, '+91$tenDigit', '91$tenDigit'];
      debugPrint('🔍 checkMemberExists: trying formats: $formats');

      for (final format in formats) {
        // Single-field query only — NO compound isArchived query.
        // Compound queries need Firestore composite indexes.
        // isArchived filtering is done in Dart below.
        final snap = await _firestore
        .collection('members')
        .where('phone', isEqualTo: format)
        .limit(1)
        .get();

        if (snap.docs.isNotEmpty) {
          final doc = snap.docs.first;
          final data = doc.data();

          // Filter archived members in Dart (avoid compound index requirement)
          final isArchived = data['isArchived'] as bool? ?? false;
          if (isArchived) {
            debugPrint('⚠️ Member archived — skipping format: $format');
            continue;
          }

          debugPrint('✅ Member found: ${data['name']} | format: $format | ID: ${doc.id}');
          return {'id': doc.id, ...data};
        }

        debugPrint('❌ No match for format: $format');
      }

      debugPrint('❌ Member not found for any phone format: $phoneNumber');
      return null;
    } catch (e, stack) {
      debugPrint('❌ checkMemberExists error: $e');
      debugPrint('$stack');
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // STORE MEMBER ID AFTER SIGN-IN
  // Called at every sign-in path AFTER signInWithCredential succeeds.
  // Rule 20: NEVER writes to users/{uid} — members have NO users collection doc.
  // Side effect: links the Firebase Auth uid back to the member Firestore doc
  //              and updates last_app_login timestamp.
  // ════════════════════════════════════════════════════════════════════════

  Future<void> _storeMemberIdFromUser(User user) async {
    try {
      // Normalize the phone number from the authenticated Firebase user
      final phone = (user.phoneNumber ?? '')
      .replaceAll('+91', '')
      .replaceAll('+', '')
      .replaceAll(RegExp(r'[^0-9]'), '');

      if (phone.isEmpty) {
        debugPrint('⚠️ No phone number on authenticated user — cannot store memberId');
        return;
      }

      final memberData = await checkMemberExists(phone);

      if (memberData != null) {
        final memberId = memberData['id'] as String;
        debugPrint('✅ Linked member: ${memberData['name']} (ID: $memberId)');

        // 1. Cache memberId locally for instant resolution on next app open
        await _saveMemberId(memberId);

        // 2. Write uid + login timestamp back to the member doc
        //    This enables server-side rules that check uid equality.
        await _firestore.collection('members').doc(memberId).update({
          'uid': user.uid,
          'last_app_login': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ memberId cached and uid linked to Firestore member doc');
      } else {
        debugPrint('⚠️ No member record found for phone: $phone');
        // Do NOT write to users/{uid} — Rule 20.
        // getCurrentMemberId phone fallback handles this on next app open.
      }
    } catch (e) {
      debugPrint('❌ Error in _storeMemberIdFromUser: $e');
      // Non-fatal — app can still proceed. getCurrentMemberId will retry.
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // SEND OTP
  // ════════════════════════════════════════════════════════════════════════

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

          // ── Path 1: Auto-verify (instant OTP on trusted devices) ──────────
          verificationCompleted: (PhoneAuthCredential credential) async {
            debugPrint('⚡ Auto-verification triggered');
            try {
              final userCredential =
              await _auth.signInWithCredential(credential);
              await _clearVerificationId();

              if (userCredential.user != null) {
                // Store memberId immediately — user is now authenticated
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
            debugPrint('✅ OTP sent successfully');
            _resendToken = resendToken;
            await _saveVerificationId(verificationId);
            onCodeSent(verificationId);
          },

          codeAutoRetrievalTimeout: (String verificationId) async {
            debugPrint('⏱️ Auto-retrieval timeout — saving latest verification ID');
            await _saveVerificationId(verificationId);
            onCodeAutoRetrievalTimeout?.call(verificationId);
          },
      );
    } catch (e) {
      debugPrint('❌ Error sending OTP: $e');
      onError(e.toString());
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // VERIFY OTP (manual entry)
  // Rule: verificationId passed explicitly from screen state.
  //       Storage is fallback only — never primary source.
  // ════════════════════════════════════════════════════════════════════════

  // ── Path 2: Manual OTP entry ──────────────────────────────────────────
  Future<UserCredential> verifyOTP(
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
          // Store memberId immediately — user is now authenticated
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

    // ════════════════════════════════════════════════════════════════════════
    // GET CURRENT MEMBER ID
    //
    // Returns the Firestore document ID (NOT auth.uid) — Rule 21.
    //
    // Resolution order:
    //   1. Secure storage — instant, no network
    //      (populated during login / auto-verify / previous session)
    //   2. Phone lookup — user IS authenticated here; Firestore rules allow read
    //      Also writes uid + timestamp back to member doc as a side effect.
    //
    // Rule 20: NO users/{uid} read — members have NO users collection doc.
    // Rule 21: Returns Firestore doc ID. For auth UID use currentUser!.uid.
    // Rule 23: checkMemberExists here is safe — user is already signed in.
    // ════════════════════════════════════════════════════════════════════════

    // ── Path 3: Cold start / app resume ──────────────────────────────────
    Future<String?> getCurrentMemberId() async {
      try {
        if (currentUser == null) {
          debugPrint('⚠️ getCurrentMemberId: no authenticated user');
          return null;
        }

        // 1. Secure storage — fastest, zero network
        final cached = await _loadMemberId();
        if (cached != null && cached.isNotEmpty) {
          debugPrint('✅ memberId from secure storage: $cached');
          return cached;
        }

        // 2. Phone fallback — user is authenticated at this point
        final phone = currentUser!.phoneNumber;
        if (phone == null || phone.isEmpty) {
          debugPrint('⚠️ No phone number on authenticated user');
          return null;
        }

        debugPrint('🔍 memberId not cached — falling back to phone lookup: $phone');
        final memberData = await checkMemberExists(phone);

        if (memberData == null) {
          debugPrint('❌ Member not found via phone fallback: $phone');
          return null;
        }

        final memberId = memberData['id'] as String;

        // Cache for all future calls
        await _saveMemberId(memberId);

        // Write uid + timestamp back to member doc
        await _firestore.collection('members').doc(memberId).update({
          'uid': currentUser!.uid,
          'last_app_login': FieldValue.serverTimestamp(),
        });

        debugPrint('✅ memberId resolved via phone fallback and cached: $memberId');
        return memberId;
      } catch (e) {
        debugPrint('❌ Error in getCurrentMemberId: $e');
        return null;
      }
    }

    // ════════════════════════════════════════════════════════════════════════
    // SIGN OUT
    // ── Path 4: Sign-out — clears both storage keys ───────────────────────
    // ════════════════════════════════════════════════════════════════════════

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

    // ════════════════════════════════════════════════════════════════════════
    // FRIENDLY ERROR MESSAGES
    // ════════════════════════════════════════════════════════════════════════

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
