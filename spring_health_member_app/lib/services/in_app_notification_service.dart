import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance =
  InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  static const _uuid = Uuid();

  // Firestore path: notifications/{uid}/items/{notifId}
  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore
    .collection('notifications')
    .doc(uid)
    .collection('items');
  }

  // ── Write ────────────────────────────────────────────────
  Future<void> addNotificationForMember({
    required String uid,
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? metadata,
  }) async {
    final col = _firestore.collection('notifications').doc(uid).collection('items');
    final id = _uuid.v4();
    await col.doc(id).set(AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: false,
      createdAt: DateTime.now(),
      metadata: metadata,
    ).toFirestore());
  }

  Future<void> addNotification({
    required NotificationType type,
    required String title,
    required String body,
    Map<String, dynamic>? metadata,
  }) async {
    final col = _col();
    if (col == null) return;
    final id = _uuid.v4();
    await col.doc(id).set(AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      isRead: false,
      createdAt: DateTime.now(),
      metadata: metadata,
    ).toFirestore());
  }

  // ── Streams ──────────────────────────────────────────────
  Stream<List<AppNotification>> streamAll() {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col
    .orderBy('createdAt', descending: true)
    .limit(50)
    .snapshots()
    .map((s) => s.docs
    .map((d) => AppNotification.fromFirestore(d.data(), d.id))
    .toList());
  }

  Stream<List<AppNotification>> streamByType(NotificationType type) {
    final col = _col();
    if (col == null) return const Stream.empty();
    return col
    .where('type', isEqualTo: type.name)
    .orderBy('createdAt', descending: true)
    .limit(50)
    .snapshots()
    .map((s) => s.docs
    .map((d) => AppNotification.fromFirestore(d.data(), d.id))
    .toList());
  }

  Stream<int> streamUnreadCount() {
    final col = _col();
    if (col == null) return Stream.value(0);
    return col
    .where('isRead', isEqualTo: false)
    .snapshots()
    .map((s) => s.docs.length);
  }

  // ── Actions ──────────────────────────────────────────────
  Future<void> markAsRead(String id) async =>
  _col()?.doc(id).update({'isRead': true});

  Future<void> markAllAsRead() async {
    final col = _col();
    if (col == null) return;
    final unread = await col.where('isRead', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) async =>
  _col()?.doc(id).delete();
}
