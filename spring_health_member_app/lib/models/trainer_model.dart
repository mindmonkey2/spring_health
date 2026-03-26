import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerModel {
  final String id;
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

  TrainerModel({
    required this.id,
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
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
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
      joiningDate: (map['joiningDate'] as Timestamp).toDate(),
      isActive: map['isActive'] as bool? ?? true,
      assignedMembers: List<String>.from(map['assignedMembers'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      address: map['address'] as String?,
    );
  }

  TrainerModel copyWith({
    String? id,
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
}
