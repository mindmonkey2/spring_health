import 'package:cloud_firestore/cloud_firestore.dart';

class BodyMetricsModel {
  final String id;
  final String memberId;
  final double weight; // kg
  final double? height; // cm — optional, used to compute BMI
  final double? bodyFat; // %
  final double? chest; // cm
  final double? waist; // cm
  final double? hips; // cm
  final double? arms; // cm
  final double? thighs; // cm
  final String? notes;
  final DateTime recordedAt;

  BodyMetricsModel({
    required this.id,
    required this.memberId,
    required this.weight,
    this.height,
    this.bodyFat,
    this.chest,
    this.waist,
    this.hips,
    this.arms,
    this.thighs,
    this.notes,
    required this.recordedAt,
  });

  // ─── Computed Properties ───────────────────────────────────────────────────

  double? get bmi {
    if (height == null || height! <= 0) return null;
    final h = height! / 100.0;
    return weight / (h * h);
  }

  String get bmiCategory {
    final b = bmi;
    if (b == null) return '—';
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  // ─── Serialization ─────────────────────────────────────────────────────────

  factory BodyMetricsModel.fromFirestore(Map<String, dynamic> map, String id) {
    return BodyMetricsModel(
      id: id,
      memberId: map['memberId'] ?? '',
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: map['height'] != null ? (map['height']).toDouble() : null,
      bodyFat: map['bodyFat'] != null ? (map['bodyFat']).toDouble() : null,
      chest: map['chest'] != null ? (map['chest']).toDouble() : null,
      waist: map['waist'] != null ? (map['waist']).toDouble() : null,
      hips: map['hips'] != null ? (map['hips']).toDouble() : null,
      arms: map['arms'] != null ? (map['arms']).toDouble() : null,
      thighs: map['thighs'] != null ? (map['thighs']).toDouble() : null,
      notes: map['notes'],
      recordedAt: map['recordedAt'] is Timestamp
      ? (map['recordedAt'] as Timestamp).toDate()
      : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'weight': weight,
      if (height != null) 'height': height,
        if (bodyFat != null) 'bodyFat': bodyFat,
          if (chest != null) 'chest': chest,
            if (waist != null) 'waist': waist,
              if (hips != null) 'hips': hips,
                if (arms != null) 'arms': arms,
                  if (thighs != null) 'thighs': thighs,
                    if (notes != null && notes!.isNotEmpty) 'notes': notes,
                      'recordedAt': Timestamp.fromDate(recordedAt),
    };
  }
}
