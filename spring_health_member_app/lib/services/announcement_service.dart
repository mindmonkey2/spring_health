import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AnnouncementModel>> getAnnouncements(String branch) {
    return _firestore
        .collection('announcements')
        .where('targetBranches', arrayContains: branch)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => AnnouncementModel.fromMap(doc.data(), doc.id),
              ) // ⬅️ FIXED
              .toList();
        });
  }

  Stream<List<AnnouncementModel>> getAnnouncementsStream(String branch) {
    return _firestore
        .collection('announcements')
        .where('targetBranches', arrayContainsAny: [branch, 'all'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AnnouncementModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<List<AnnouncementModel>> getAllAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => AnnouncementModel.fromMap(doc.data(), doc.id),
              ) // ⬅️ FIXED
              .toList();
        });
  }

  Future<void> markAsRead(String announcementId, String memberId) async {
    await _firestore.collection('announcements').doc(announcementId).update({
      'readBy': FieldValue.arrayUnion([memberId]),
    });
  }
}
