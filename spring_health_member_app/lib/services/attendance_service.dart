import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final _db = FirebaseFirestore.instance;

  // ✅ One-time fetch (for calendar + charts)
  Future<List<AttendanceModel>> getHistory(String memberId) async {
    final snap = await _db
        .collection('attendance')
        .where('memberId', isEqualTo: memberId)
        .orderBy('checkInTime', descending: true)
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return AttendanceModel.fromMap(data);
    }).toList();
  }

  // ✅ Real-time stream (kept for live UI)
  Stream<List<AttendanceModel>> streamHistory(String memberId) {
    return _db
        .collection('attendance')
        .where('memberId', isEqualTo: memberId)
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return AttendanceModel.fromMap(data);
          }).toList(),
        );
  }

  // ✅ Checked-in date keys for O(1) calendar lookup
  Set<String> buildCheckedInDates(List<AttendanceModel> records) {
    return records
        .map(
          (r) =>
              '${r.checkInTime.year}-${r.checkInTime.month}-${r.checkInTime.day}',
        )
        .toSet();
  }
}
