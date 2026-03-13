import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload member photo to Firebase Storage
  /// Returns the download URL of the uploaded photo
  Future<String> uploadMemberPhoto({
    required String memberId,
    required File imageFile,
    String? oldPhotoUrl,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      final fileName = 'member_photos/$memberId.jpg';
      final task = _storage
          .ref()
          .child(fileName)
          .putFile(
            imageFile,
            SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'member_id': memberId,
                'uploaded_at': DateTime.now().toIso8601String(),
              },
            ),
          );

      if (onProgress != null) {
        task.snapshotEvents.listen((event) {
          final total = event.totalBytes;
          if (total != 0) {
            final progress = event.bytesTransferred / total;
            onProgress(progress);
          }
        });
      }

      final snapshot = await task;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (oldPhotoUrl != null) {
        await _deleteOldPhoto(oldPhotoUrl);
      }

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading member photo: $e');
      rethrow;
    }
  }

  /// Upload trainer photo to Firebase Storage
  Future<String> uploadTrainerPhoto({
    required String trainerId,
    required File imageFile,
    String? oldPhotoUrl,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      final fileName = 'trainer_photos/$trainerId.jpg';
      final task = _storage
          .ref()
          .child(fileName)
          .putFile(
            imageFile,
            SettableMetadata(
              contentType: 'image/jpeg',
              customMetadata: {
                'trainer_id': trainerId,
                'uploaded_at': DateTime.now().toIso8601String(),
              },
            ),
          );

      if (onProgress != null) {
        task.snapshotEvents.listen((event) {
          final total = event.totalBytes;
          if (total != 0) {
            final progress = event.bytesTransferred / total;
            onProgress(progress);
          }
        });
      }

      final snapshot = await task;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (oldPhotoUrl != null) {
        await _deleteOldPhoto(oldPhotoUrl);
      }

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading trainer photo: $e');
      rethrow;
    }
  }

  /// Delete a photo from Firebase Storage by URL
  Future<void> deletePhotoByUrl(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final storagePath = uri.pathSegments.join('/');
      if (storagePath.isNotEmpty) {
        await _storage.ref().child(storagePath).delete();
      }
    } catch (e) {
      debugPrint('Error deleting photo by URL: $e');
    }
  }

  /// Delete old photo file from storage
  Future<void> _deleteOldPhoto(String oldPhotoUrl) async {
    try {
      final uri = Uri.parse(oldPhotoUrl);
      final storagePath = uri.pathSegments.join('/');
      if (storagePath.isNotEmpty) {
        await _storage.ref().child(storagePath).delete();
      }
    } catch (e) {
      debugPrint('Error deleting old photo: $e');
    }
  }

  /// Get download URL for a member photo
  Future<String?> getMemberPhotoUrl(String memberId) async {
    try {
      final ref = _storage.ref().child('member_photos/$memberId.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Member photo not found for ID: $memberId');
      return null;
    }
  }

  /// Get download URL for a trainer photo
  Future<String?> getTrainerPhotoUrl(String trainerId) async {
    try {
      final ref = _storage.ref().child('trainer_photos/$trainerId.jpg');
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Trainer photo not found for ID: $trainerId');
      return null;
    }
  }

  /// Get metadata for a photo
  Future<FullMetadata?> getPhotoMetadata(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final storagePath = uri.pathSegments.join('/');
      if (storagePath.isNotEmpty) {
        final ref = _storage.ref().child(storagePath);
        final metadata = await ref.getMetadata();
        return metadata;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting photo metadata: $e');
      return null;
    }
  }

  /// Generate a thumbnail URL (placeholder)
  String generateThumbnailUrl(String photoUrl,
      {int width = 100, int height = 100}) {
    return photoUrl;
  }

  /// Check if a photo exists in storage
  Future<bool> photoExists(String photoUrl) async {
    try {
      final uri = Uri.parse(photoUrl);
      final storagePath = uri.pathSegments.join('/');
      if (storagePath.isNotEmpty) {
        final ref = _storage.ref().child(storagePath);
        await ref.getDownloadURL();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
