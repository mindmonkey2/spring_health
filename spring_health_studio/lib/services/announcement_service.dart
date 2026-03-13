import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('announcements');

  // ── Streams ──────────────────────────────────────────────────────

  /// All announcements, newest first (for admin list view)
  Stream<List<AnnouncementModel>> getAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => AnnouncementModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// Active announcements for a branch — used by admin manage screen
  Stream<List<AnnouncementModel>> getActive({String? branch}) {
    return _col
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
      final all = s.docs
          .map((d) => AnnouncementModel.fromMap(
              d.data() as Map<String, dynamic>, d.id))
          .toList();
      if (branch == null || branch == 'All') return all;
      return all
          .where((a) => a.branch == 'All' || a.branch == branch)
          .toList();
    });
  }

  /// ✅ FIX: Member app calls this — was missing, stream was broken
  /// Active announcements filtered for member's branch
  Stream<List<AnnouncementModel>> getAnnouncementsStream(String branch) {
    return _col
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) {
      return s.docs
          .map((d) => AnnouncementModel.fromMap(
              d.data() as Map<String, dynamic>, d.id))
          .where((a) => a.branch == 'All' || a.branch == branch)
          .toList();
    });
  }

  // ── CRUD ─────────────────────────────────────────────────────────

  Future<String> create(AnnouncementModel announcement) async {
    final ref = await _col.add(announcement.toMap());
    return ref.id;
  }

  Future<void> update(AnnouncementModel announcement) async {
    await _col.doc(announcement.id).update(announcement.toMap());
  }

  Future<void> deactivate(String id) async {
    await _col.doc(id).update({'isActive': false});
  }

  Future<void> activate(String id) async {
    await _col.doc(id).update({'isActive': true});
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  // ── Read Tracking ─────────────────────────────────────────────────

  /// ✅ FIX: Was completely missing — marks announcement as read for a member
  /// Writes memberId into the readBy array in Firestore
  /// This fixes:
  ///   - Member app: NEW badge not disappearing after tap
  ///   - Admin app: read count showing 0 forever
  Future<void> markAsRead(String announcementId, String memberId) async {
    try {
      await _col.doc(announcementId).update({
        'readBy': FieldValue.arrayUnion([memberId]),
      });
    } catch (e) {
      // Doc may not exist or network error — fail silently
      debugPrint('markAsRead error: $e');
    }
  }

  /// ✅ Mark multiple announcements as read at once (used on screen open)
  Future<void> markAllAsRead(
      List<String> announcementIds, String memberId) async {
    final batch = _db.batch();
    for (final id in announcementIds) {
      batch.update(_col.doc(id), {
        'readBy': FieldValue.arrayUnion([memberId]),
      });
    }
    await batch.commit();
  }

  // ── Stats ─────────────────────────────────────────────────────────

  Future<int> getTotalMemberCount(String branch) async {
    Query q = _db
        .collection('members')
        .where('isArchived', isEqualTo: false);
    if (branch != 'All') {
      q = q.where('branch', isEqualTo: branch);
    }
    final snap = await q.count().get();
    return snap.count ?? 0;
  }
}
