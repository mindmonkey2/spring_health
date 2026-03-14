import 'package:cloud_firestore/cloud_firestore.dart';

class DietPlanModel {
  final String id;
  final String memberId;
  final String trainerId;
  final Map<String, dynamic> macros;
  final List<Map<String, dynamic>> meals;
  final DateTime activeUntil;

  const DietPlanModel({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.macros,
    required this.meals,
    required this.activeUntil,
  });

  factory DietPlanModel.fromMap(Map<String, dynamic> data, String id) {
    return DietPlanModel(
      id: id,
      memberId: data['memberId'] as String? ?? '',
      trainerId: data['trainerId'] as String? ?? '',
      macros: Map<String, dynamic>.from(data['macros'] ?? {}),
      meals: List<Map<String, dynamic>>.from(data['meals'] ?? []),
      activeUntil: (data['activeUntil'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'memberId': memberId,
    'trainerId': trainerId,
    'macros': macros,
    'meals': meals,
    'activeUntil': Timestamp.fromDate(activeUntil),
  };
}
