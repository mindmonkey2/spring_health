import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String memberId;
  final String memberName;
  final String branch;
  final DateTime checkInTime;

  AttendanceModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.branch,
    required this.checkInTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'branch': branch,
      'checkInTime': Timestamp.fromDate(checkInTime),
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String,
      memberId: map['memberId'] as String,
      memberName: map['memberName'] as String,
      branch: map['branch'] as String,
      checkInTime: (map['checkInTime'] as Timestamp).toDate(),
    );
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel.fromMap(json);
  }
}
