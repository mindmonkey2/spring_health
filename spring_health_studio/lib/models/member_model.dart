import 'package:cloud_firestore/cloud_firestore.dart';
import 'document_sent_model.dart';

class MemberModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String gender;
  final DateTime? dateOfBirth;
  final String branch;
  final String category;
  final String plan;
  final DateTime joiningDate;
  final DateTime expiryDate;
  final String paymentMode;
  final double totalFee;
  final double discount;
  final String discountDescription;
  final double finalAmount;
  final double cashAmount;
  final double upiAmount;
  final double dueAmount;
  final bool isActive;
  final bool isArchived;
  final DateTime? lastCheckIn;
  final String qrCode;
  final DateTime createdAt;
  final String? trainerId;
  final String? photoUrl;
  final List<DocumentSentModel> documentHistory;

  MemberModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.gender,
    this.dateOfBirth,
    required this.branch,
    required this.category,
    required this.plan,
    required this.joiningDate,
    required this.expiryDate,
    required this.paymentMode,
    required this.totalFee,
    this.discount = 0,
    this.discountDescription = '',
    required this.finalAmount,
    this.cashAmount = 0,
    this.upiAmount = 0,
    this.dueAmount = 0,
    required this.isActive,
    this.isArchived = false,
    this.lastCheckIn,
    required this.qrCode,
    required this.createdAt,
    this.trainerId,
    this.documentHistory = const [],
    this.photoUrl,
  });

  // ═══════════════════════════════════════════════════════
  //  COMPUTED GETTERS
  // ═══════════════════════════════════════════════════════

  String get uid => id;

  /// True if membership has passed its expiry date
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// True if expiry is within the next 7 days and not yet expired
  bool get isExpiringSoon {
    if (isExpired) return false;
    final daysLeft = expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= 7;
  }

  /// Days remaining until expiry — 0 if already expired
  int get daysRemaining {
    final diff = expiryDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// True if member has an outstanding due amount
  bool get hasDues => dueAmount > 0;

  // ═══════════════════════════════════════════════════════
  //  SERIALIZATION
  // ═══════════════════════════════════════════════════════

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'branch': branch,
      'category': category,
      'plan': plan,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'expiryDate': Timestamp.fromDate(expiryDate),
      'paymentMode': paymentMode,
      'totalFee': totalFee,
      'discount': discount,
      'discountDescription': discountDescription,
      'finalAmount': finalAmount,
      'cashAmount': cashAmount,
      'upiAmount': upiAmount,
      'dueAmount': dueAmount,
      'isActive': isActive,
      'isArchived': isArchived,
      'lastCheckIn':
          lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'trainerId': trainerId,
      'photoUrl': photoUrl,  // ✅ FIXED: was missing from toMap
      'documentHistory':
          documentHistory.map((doc) => doc.toMap()).toList(),
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return MemberModel(
      id: id ?? map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String? ?? '',
      gender: map['gender'] as String,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dateOfBirth'] as int)
          : null,
      branch: map['branch'] as String,
      category: map['category'] as String,
      plan: map['plan'] as String,
      joiningDate: (map['joiningDate'] as Timestamp).toDate(),
      expiryDate: (map['expiryDate'] as Timestamp).toDate(),
      paymentMode: map['paymentMode'] as String,
      totalFee: (map['totalFee'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      discountDescription: map['discountDescription'] as String? ?? '',
      finalAmount: (map['finalAmount'] as num).toDouble(),
      cashAmount: (map['cashAmount'] as num?)?.toDouble() ?? 0,
      upiAmount: (map['upiAmount'] as num?)?.toDouble() ?? 0,
      dueAmount: (map['dueAmount'] as num?)?.toDouble() ?? 0,
      isActive: map['isActive'] as bool,
      isArchived: map['isArchived'] as bool? ?? false,
      lastCheckIn: map['lastCheckIn'] != null
          ? (map['lastCheckIn'] as Timestamp).toDate()
          : null,
      qrCode: map['qrCode'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      trainerId: map['trainerId'] as String?,
      photoUrl: map['photoUrl'] as String?,  // ✅ FIXED: was missing from fromMap
      documentHistory: (map['documentHistory'] as List<dynamic>?)
              ?.map((item) =>
                  DocumentSentModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  factory MemberModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return MemberModel.fromMap(json, id: id);
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? branch,
    String? category,
    String? plan,
    DateTime? joiningDate,
    DateTime? expiryDate,
    String? paymentMode,
    double? totalFee,
    double? discount,
    String? discountDescription,
    double? finalAmount,
    double? cashAmount,
    double? upiAmount,
    double? dueAmount,
    bool? isActive,
    bool? isArchived,
    DateTime? lastCheckIn,
    String? qrCode,
    DateTime? createdAt,
    String? trainerId,
    String? photoUrl,  // ✅ FIXED: was missing from copyWith
    List<DocumentSentModel>? documentHistory,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      branch: branch ?? this.branch,
      category: category ?? this.category,
      plan: plan ?? this.plan,
      joiningDate: joiningDate ?? this.joiningDate,
      expiryDate: expiryDate ?? this.expiryDate,
      paymentMode: paymentMode ?? this.paymentMode,
      totalFee: totalFee ?? this.totalFee,
      discount: discount ?? this.discount,
      discountDescription: discountDescription ?? this.discountDescription,
      finalAmount: finalAmount ?? this.finalAmount,
      cashAmount: cashAmount ?? this.cashAmount,
      upiAmount: upiAmount ?? this.upiAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      trainerId: trainerId ?? this.trainerId,
      photoUrl: photoUrl ?? this.photoUrl,  // ✅ FIXED
      documentHistory: documentHistory ?? this.documentHistory,
    );
  }

  // ═══════════════════════════════════════════════════════
  //  DOCUMENT HISTORY HELPERS
  // ═══════════════════════════════════════════════════════

  bool hasDocumentBeenSent(String type) {
    return documentHistory.any((doc) => doc.type == type && doc.success);
  }

  DocumentSentModel? getLastSentDocument(String type) {
    try {
      final filtered = documentHistory
          .where((doc) => doc.type == type && doc.success)
          .toList();
      if (filtered.isEmpty) return null;
      return filtered.reduce((a, b) => a.sentAt.isAfter(b.sentAt) ? a : b);
    } catch (e) {
      return null;
    }
  }

  List<DocumentSentModel> getDocumentsByType(String type) =>
      documentHistory.where((doc) => doc.type == type).toList();

  List<DocumentSentModel> getDocumentsByMethod(String method) =>
      documentHistory.where((doc) => doc.method == method).toList();

  int get totalDocumentsSent =>
      documentHistory.where((doc) => doc.success).length;

  int get totalFailedDocuments =>
      documentHistory.where((doc) => !doc.success).length;

  List<DocumentSentModel> get recentDocuments {
    final sorted = List<DocumentSentModel>.from(documentHistory)
      ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    return sorted.take(5).toList();
  }

  DocumentSentModel? get lastSentDocument {
    if (documentHistory.isEmpty) return null;
    return documentHistory
        .reduce((a, b) => a.sentAt.isAfter(b.sentAt) ? a : b);
  }

  bool get welcomePackageSent => hasDocumentBeenSent('welcome');

  bool hasDocumentsSentInLastDays(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return documentHistory
        .any((doc) => doc.success && doc.sentAt.isAfter(cutoffDate));
  }

  List<DocumentSentModel> getDocumentsBySentBy(String sentBy) =>
      documentHistory.where((doc) => doc.sentBy == sentBy).toList();

  String get documentHistorySummary {
    if (documentHistory.isEmpty) return 'No documents sent';
    final lastSent = lastSentDocument;
    if (lastSent != null) {
      final timeAgo = _getTimeAgo(lastSent.sentAt);
      return '$totalDocumentsSent sent, $totalFailedDocuments failed. '
          'Last: ${lastSent.type} ($timeAgo)';
    }
    return '$totalDocumentsSent sent, $totalFailedDocuments failed';
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 30) {
      final m = (diff.inDays / 30).floor();
      return '$m ${m == 1 ? 'month' : 'months'} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }
}
