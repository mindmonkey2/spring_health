import 'package:cloud_firestore/cloud_firestore.dart';

class GymEquipmentModel {
  final String id;
  final String branch;
  final List<String> equipment;
  final Timestamp updatedAt;
  final String updatedBy;

  GymEquipmentModel({
    required this.id,
    required this.branch,
    required this.equipment,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory GymEquipmentModel.fromMap(Map<String, dynamic> data, String id) {
    return GymEquipmentModel(
      id: id,
      branch: data['branch'] ?? '',
      equipment: data['equipment'] != null
          ? List<String>.from(data['equipment'] as List)
          : [],
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      updatedBy: data['updatedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'branch': branch,
      'equipment': equipment,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }

  GymEquipmentModel copyWith({
    String? branch,
    List<String>? equipment,
    Timestamp? updatedAt,
    String? updatedBy,
  }) {
    return GymEquipmentModel(
      id: id,
      branch: branch ?? this.branch,
      equipment: equipment ?? this.equipment,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
