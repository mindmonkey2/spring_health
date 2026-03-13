// lib/models/member_model.dart  — MEMBER APP

import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String branch;
  final String category;   // ✅ ADDED — admin writes this
  final String plan;
  final String membershipPlan;
  final DateTime startDate;
  final DateTime expiryDate;
  final double finalAmount;
  final double paidAmount;
  final double dueAmount;
  final double cashAmount;
  final double upiAmount;
  final double discount;
  final bool isActive;
  final bool isArchived;
  final String? photoUrl;
  final String? address;
  final DateTime createdAt;
  final String qrCode;
  final DateTime? lastCheckIn;  // ✅ ADDED — admin writes this

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.branch,
    this.category = '',
    required this.plan,
    required this.membershipPlan,
    required this.startDate,
    required this.expiryDate,
    required this.finalAmount,
    required this.paidAmount,
    required this.dueAmount,
    required this.cashAmount,
    required this.upiAmount,
    required this.discount,
    required this.isActive,
    required this.isArchived,
    required this.createdAt,
    required this.qrCode,
    this.photoUrl,
    this.address,
    this.lastCheckIn,
  });

  // ── Getter aliases (used by profile_screen & membership card) ──────────
  DateTime get membershipStartDate => startDate;
  DateTime get membershipEndDate => expiryDate;

  // ── fromMap — reads Firestore doc written by Admin app ─────────────────
  factory MemberModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MemberModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      branch: map['branch'] as String? ?? '',
      category: map['category'] as String? ?? '',

      // Admin writes 'plan' — membershipPlan is a member-app alias
      plan: map['plan'] as String? ?? map['membershipPlan'] as String? ?? '',
      membershipPlan: map['plan'] as String? ?? map['membershipPlan'] as String? ?? '',

      // ✅ FIX: Admin writes 'joiningDate', fallback to 'startDate' for safety
      startDate: _toDateTime(map['joiningDate'] ?? map['startDate']),

      // ✅ Admin writes 'expiryDate' — both apps agree on this key
      expiryDate: _toDateTime(map['expiryDate']),

      finalAmount: _toDouble(map['finalAmount']),
      // Admin has no 'paidAmount' — derive it: finalAmount - dueAmount
      paidAmount: _toDouble(map['paidAmount'] ??
          (_toDouble(map['finalAmount']) - _toDouble(map['dueAmount']))),
      dueAmount: _toDouble(map['dueAmount']),
      cashAmount: _toDouble(map['cashAmount']),
      upiAmount: _toDouble(map['upiAmount']),
      discount: _toDouble(map['discount']),

      isActive: map['isActive'] as bool? ?? true,
      isArchived: map['isArchived'] as bool? ?? false,

      createdAt: _toDateTime(map['createdAt']),
      qrCode: map['qrCode'] as String? ?? 'SPRING_${id ?? ''}',

      photoUrl: map['photoUrl'] as String?,
      address: map['address'] as String?,

      lastCheckIn: map['lastCheckIn'] != null
          ? _toDateTime(map['lastCheckIn'])
          : null,
    );
  }

  factory MemberModel.fromFirestore(Map<String, dynamic> map, String id) =>
      MemberModel.fromMap(map, id: id);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'branch': branch,
      'category': category,
      'plan': plan,
      'membershipPlan': membershipPlan,
      'joiningDate': Timestamp.fromDate(startDate),  // ✅ write same key as admin
      'expiryDate': Timestamp.fromDate(expiryDate),
      'finalAmount': finalAmount,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
      'cashAmount': cashAmount,
      'upiAmount': upiAmount,
      'discount': discount,
      'isActive': isActive,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'qrCode': qrCode,
      'photoUrl': photoUrl,
      'address': address,
      if (lastCheckIn != null) 'lastCheckIn': Timestamp.fromDate(lastCheckIn!),
    };
  }

  // ── Computed getters ───────────────────────────────────────────────────
  int get daysRemaining {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isExpiringSoon {
    final days = daysRemaining;
    return days > 0 && days <= 7;
  }

  // ── Private helpers ────────────────────────────────────────────────────

  /// Safely parses Timestamp, DateTime, or int millis → DateTime.
  /// Falls back to epoch (not DateTime.now()) so stale data is obvious.
  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.fromMillisecondsSinceEpoch(0); // ✅ epoch, not DateTime.now()
  }

  static double _toDouble(dynamic value) =>
      value == null ? 0.0 : (value as num).toDouble();
}
