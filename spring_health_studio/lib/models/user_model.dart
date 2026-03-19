import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? branch;
  final String? trainerId; // ✅ NEW — "TRN001" style ID, only set for Trainer role
  final String? name;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.branch,
    this.trainerId,
    this.name,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      branch: map['branch'] as String?,
      trainerId: map['trainer_id'] as String?,
      name: map['name'] as String?,
      createdAt: map['createdAt'] != null
      ? (map['createdAt'] as Timestamp).toDate()
      : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'role': role,
    'branch': branch,
    'trainer_id': trainerId,
    'name': name,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  bool get isOwner => role == 'Owner';
  bool get isReceptionist => role == 'Receptionist';
  bool get isTrainer => role == 'Trainer';
  bool get isMember => role == 'member';
}
