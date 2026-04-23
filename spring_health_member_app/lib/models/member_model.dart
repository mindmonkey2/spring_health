import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spring_health_member/core/utils/date_time_utils.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String? photoUrl;
  final String? dateOfBirth;
  final String? address;
  final String branch;
  final String membershipPlan;
  final String category;
  final DateTime joiningDate;
  final DateTime expiryDate;
  final double totalFee;
  final double discount;
  final double finalAmount;
  final double cashAmount;
  final double upiAmount;
  final double dueAmount;
  final String paymentMode;
  final bool isArchived;
  final List<String> loyaltyMilestonesAwarded;
  final int totalCheckIns;
  final DateTime? lastCheckInTime;
  final int currentStreak;
  final int longestStreak;
  final int xpPoints;
  final int level;
  final List<String> badges;
  final String? fcmToken;
  final String? uid;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MemberModel({
    this.id = '',
    required this.name,
    required this.phone,
    this.email = '',
    this.photoUrl,
    this.dateOfBirth,
    this.address,
    required this.branch,
    required this.membershipPlan,
    this.category = '',
    required this.joiningDate,
    required this.expiryDate,
    this.totalFee = 0,
    this.discount = 0,
    this.finalAmount = 0,
    this.cashAmount = 0,
    this.upiAmount = 0,
    this.dueAmount = 0,
    this.paymentMode = 'Cash',
    this.isArchived = false,
    this.loyaltyMilestonesAwarded = const [],
    this.totalCheckIns = 0,
    this.lastCheckInTime,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xpPoints = 0,
    this.level = 1,
    this.badges = const [],
    this.fcmToken,
    this.uid,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.createdAt,
    this.updatedAt,
  });

  // ── Status getters ───────────────────────────────────────────────────────

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isExpiringSoon =>
      !isExpired && expiryDate.difference(DateTime.now()).inDays <= 7;

  /// Active = not expired AND not archived
  bool get isActive => !isExpired && !isArchived;

  int get daysLeft =>
      isExpired ? 0 : expiryDate.difference(DateTime.now()).inDays;

  // ── Compatibility aliases ────────────────────────────────────────────────

  /// Alias used by ai_coach_service, membership_alert_service, and admin model
  String get plan => membershipPlan;

  /// Alias used by profile_screen (spec version)
  int get daysRemaining => daysLeft;

  /// Alias used by ai_coach_service and workout services
  DateTime get startDate => joiningDate;

  DateTime get membershipStartDate => joiningDate;
  DateTime get membershipEndDate => expiryDate;

  /// Used by QR check-in and membership card widget
  String get qrCode => id;

  // ── Factories ────────────────────────────────────────────────────────────

  /// Matches how member_service.dart calls it:
  ///   MemberModel.fromFirestore(doc.data() as Map, doc.id)
  factory MemberModel.fromFirestore(Map<String, dynamic> data, String id) =>
      MemberModel.fromMap(data, id: id);

  factory MemberModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return MemberModel(
      id: id.isNotEmpty ? id : (map['id'] as String? ?? ''),
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      dateOfBirth: map['dateOfBirth'] as String?,
      address: map['address'] as String?,
      branch: map['branch'] as String? ?? '',
      membershipPlan:
          map['membershipPlan'] as String? ?? map['plan'] as String? ?? '',
      category: map['category'] as String? ?? '',
      joiningDate: DateTimeUtils.toDateTime(map['joiningDate']),
      expiryDate: DateTimeUtils.toDateTime(map['expiryDate']),
      totalFee: (map['totalFee'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      finalAmount: (map['finalAmount'] as num?)?.toDouble() ?? 0,
      cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0,
      upiAmount: (map['upiAmount'] as num?)?.toDouble() ?? 0,
      dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0,
      paymentMode: map['paymentMode'] as String? ?? 'Cash',
      isArchived: map['isArchived'] as bool? ?? false,
      loyaltyMilestonesAwarded: List<String>.from(
        map['loyaltyMilestonesAwarded'] as List? ?? [],
      ),
      totalCheckIns: map['totalCheckIns'] as int? ?? 0,
      lastCheckInTime: DateTimeUtils.toDateTimeNullable(map['lastCheckInTime']),
      currentStreak: map['currentStreak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      xpPoints: map['xpPoints'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      badges: List<String>.from(map['badges'] as List? ?? []),
      fcmToken: map['fcmToken'] as String?,
      uid: map['uid'] as String?,
      emergencyContactName: map['emergencyContactName'] as String?,
      emergencyContactPhone: map['emergencyContactPhone'] as String?,
      createdAt: DateTimeUtils.toDateTimeNullable(map['createdAt']),
      updatedAt: DateTimeUtils.toDateTimeNullable(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'email': email,
    if (photoUrl != null) 'photoUrl': photoUrl,
    if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
    if (address != null) 'address': address,
    'branch': branch,
    'membershipPlan': membershipPlan,
    'category': category,
    'joiningDate': Timestamp.fromDate(joiningDate),
    'expiryDate': Timestamp.fromDate(expiryDate),
    'totalFee': totalFee,
    'discount': discount,
    'finalAmount': finalAmount,
    'cashAmount': cashAmount,
    'upiAmount': upiAmount,
    'dueAmount': dueAmount,
    'paymentMode': paymentMode,
    'isArchived': isArchived,
    'loyaltyMilestonesAwarded': loyaltyMilestonesAwarded,
    'totalCheckIns': totalCheckIns,
    if (lastCheckInTime != null)
      'lastCheckInTime': Timestamp.fromDate(lastCheckInTime!),
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'xpPoints': xpPoints,
    'level': level,
    'badges': badges,
    if (fcmToken != null) 'fcmToken': fcmToken,
    if (uid != null) 'uid': uid,
    if (emergencyContactName != null)
      'emergencyContactName': emergencyContactName,
    if (emergencyContactPhone != null)
      'emergencyContactPhone': emergencyContactPhone,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
  };

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? address,
    String? dateOfBirth,
    String? branch,
    String? membershipPlan,
    String? category,
    DateTime? joiningDate,
    DateTime? expiryDate,
    double? totalFee,
    double? discount,
    double? finalAmount,
    double? cashAmount,
    double? upiAmount,
    double? dueAmount,
    String? paymentMode,
    bool? isArchived,
    List<String>? loyaltyMilestonesAwarded,
    int? totalCheckIns,
    DateTime? lastCheckInTime,
    int? currentStreak,
    int? longestStreak,
    int? xpPoints,
    int? level,
    List<String>? badges,
    String? fcmToken,
    String? uid,
    String? emergencyContactName,
    String? emergencyContactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MemberModel(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    address: address ?? this.address,
    branch: branch ?? this.branch,
    membershipPlan: membershipPlan ?? this.membershipPlan,
    category: category ?? this.category,
    joiningDate: joiningDate ?? this.joiningDate,
    expiryDate: expiryDate ?? this.expiryDate,
    totalFee: totalFee ?? this.totalFee,
    discount: discount ?? this.discount,
    finalAmount: finalAmount ?? this.finalAmount,
    cashAmount: cashAmount ?? this.cashAmount,
    upiAmount: upiAmount ?? this.upiAmount,
    dueAmount: dueAmount ?? this.dueAmount,
    paymentMode: paymentMode ?? this.paymentMode,
    isArchived: isArchived ?? this.isArchived,
    loyaltyMilestonesAwarded:
        loyaltyMilestonesAwarded ?? this.loyaltyMilestonesAwarded,
    totalCheckIns: totalCheckIns ?? this.totalCheckIns,
    lastCheckInTime: lastCheckInTime ?? this.lastCheckInTime,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    xpPoints: xpPoints ?? this.xpPoints,
    level: level ?? this.level,
    badges: badges ?? this.badges,
    fcmToken: fcmToken ?? this.fcmToken,
    uid: uid ?? this.uid,
    emergencyContactName: emergencyContactName ?? this.emergencyContactName,
    emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
