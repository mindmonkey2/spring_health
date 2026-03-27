import 'package:cloud_firestore/cloud_firestore.dart';

class GymEquipmentModel {
  final String branch;
  final List<String> equipment;
  final DateTime updatedAt;
  final String updatedBy;

  GymEquipmentModel({
    required this.branch,
    required this.equipment,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory GymEquipmentModel.fromMap(Map<String, dynamic> map, String id) {
    return GymEquipmentModel(
      branch: map['branch'] as String? ?? id,
      equipment: List<String>.from(map['equipment'] ?? []),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedBy: map['updatedBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'branch': branch,
      'equipment': equipment,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'updatedBy': updatedBy,
    };
  }
}
