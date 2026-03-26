import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfileImage(String memberId, File imageFile) async {
    try {
      // ✅ Always use the actual Firebase Auth UID for storage path
      final String? authUid = _auth.currentUser?.uid;

      if (authUid == null) {
        debugPrint('StorageService: No authenticated user found.');
        return null;
      }

      // ✅ Store by authUid but keep memberId as metadata for reference
      final Reference storageRef = _storage.ref().child(
        'users/profile_images/$authUid.jpg',
      );

      final UploadTask uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'memberId': memberId},
        ),
      );

      // ✅ Monitor upload progress & catch task-level errors
      uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          final progress =
              snapshot.bytesTransferred / snapshot.totalBytes * 100;
          debugPrint('Upload progress: ${progress.toStringAsFixed(1)}%');
        },
        onError: (e) {
          debugPrint('Upload stream error: $e');
        },
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Upload success: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      // ✅ Firebase-specific error with code — visible in release too
      debugPrint('FirebaseException [${e.code}]: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected upload error: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage(String authUid) async {
    try {
      await _storage.ref().child('users/profile_images/$authUid.jpg').delete();
    } on FirebaseException catch (e) {
      debugPrint('Delete error [${e.code}]: ${e.message}');
    }
  }
}
