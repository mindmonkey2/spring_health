import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerModel {
  final String id;           // Firestore doc ID e.g. "TRN001"
  final String userId;       // ✅ NEW — Firebase Auth UID for login linkage
  final String name;
  final String phone;
  final String email;
  final String gender;
  final DateTime? dateOfBirth;
  final String branch;
  final String specialization;
  final String experience;
  final double salary;
  final String qualification;
  final String? photoUrl;
  final DateTime joiningDate;
  final bool isActive;
  final List<String> assignedMembers;
  final DateTime createdAt;
  final String? address;

  const TrainerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    this.dateOfBirth,
    required this.branch,
    required this.specialization,
    required this.experience,
    required this.salary,
    required this.qualification,
    this.photoUrl,
    required this.joiningDate,
    required this.isActive,
    this.assignedMembers = const [],
    required this.createdAt,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      // ✅ REMOVED 'id' — redundant, Firestore doc ID is set via .doc(id).set()
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'branch': branch,
      'specialization': specialization,
      'experience': experience,
      'salary': salary,
      'qualification': qualification,
      'photoUrl': photoUrl,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'isActive': isActive,
      'assignedMembers': assignedMembers,
      'createdAt': Timestamp.fromDate(createdAt),
      'address': address ?? '',
    };
  }

  factory TrainerModel.fromMap(Map<String, dynamic> map, String id) {
    return TrainerModel(
      id: id,
      userId: map['authUid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      gender: map['gender'] as String? ?? 'Male',
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      branch: map['branch'] as String? ?? '',
      specialization: map['specialization'] as String? ?? '',
      experience: map['experience'] as String? ?? '',
      salary: (map['salary'] as num?)?.toDouble() ?? 0.0,
      qualification: map['qualification'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      // ✅ FIXED: null-safe joiningDate — falls back to createdAt or now
      joiningDate: map['joiningDate'] != null
          ? (map['joiningDate'] as Timestamp).toDate()
          : map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      isActive: map['isActive'] as bool? ?? true,
      assignedMembers:
          List<String>.from(map['assignedMembers'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      address: map['address'] as String?,
    );
  }

  TrainerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? branch,
    String? specialization,
    String? experience,
    double? salary,
    String? qualification,
    String? photoUrl,
    DateTime? joiningDate,
    bool? isActive,
    List<String>? assignedMembers,
    String? address,
  }) {
    return TrainerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      branch: branch ?? this.branch,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      salary: salary ?? this.salary,
      qualification: qualification ?? this.qualification,
      photoUrl: photoUrl ?? this.photoUrl,
      joiningDate: joiningDate ?? this.joiningDate,
      isActive: isActive ?? this.isActive,
      assignedMembers: assignedMembers ?? this.assignedMembers,
      createdAt: createdAt,
      address: address ?? this.address,
    );
  }

  // ── Helpers ──────────────────────────────────────────────
  int get totalAssigned => assignedMembers.length;

  String get experienceLabel =>
      experience.isEmpty ? 'Not specified' : '$experience yrs exp';
}
