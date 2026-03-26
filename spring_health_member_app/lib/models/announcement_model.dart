import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final List<String> targetBranches;
  final DateTime createdAt;
  final String? createdByUid;
  final DateTime? expiresAt;
  final List<String> readBy;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.targetBranches,
    required this.createdAt,
    this.createdByUid,
    this.expiresAt,
    this.readBy = const [],
  });

  // ✅ Create from Map (generic)
  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? map['content'] ?? '',
      imageUrl: map['imageUrl'],
      targetBranches: List<String>.from(map['targetBranches'] ?? ['all']),
      createdAt: _toDateTime(map['createdAt']),
      createdByUid: map['createdByUid'],
      expiresAt: _toDateTimeNullable(map['expiresAt']),
      readBy: List<String>.from(map['readBy'] ?? []),
    );
  }

  // ✅ Create from Firestore document (with ID)
  factory AnnouncementModel.fromFirestore(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? map['content'] ?? '',
      imageUrl: map['imageUrl'],
      targetBranches: List<String>.from(map['targetBranches'] ?? ['all']),
      createdAt: _toDateTime(map['createdAt']),
      createdByUid: map['createdByUid'],
      expiresAt: _toDateTimeNullable(map['expiresAt']),
      readBy: List<String>.from(map['readBy'] ?? []),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _toDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  // ✅ Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'targetBranches': targetBranches,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdByUid': createdByUid,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'readBy': readBy,
    };
  }

  // ✅ Getter alias for backward compatibility
  String get content => message;

  // ✅ Helper method - Check if read by specific member
  bool isReadBy(String memberId) {
    return readBy.contains(memberId);
  }

  // ✅ Helper method - Check if announcement is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  // ✅ Helper method - Check if announcement is new for user
  bool isNew(DateTime userLastSeen) {
    return createdAt.isAfter(userLastSeen);
  }

  // ✅ Helper method - Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // ✅ Copy with method for updates
  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? imageUrl,
    List<String>? targetBranches,
    DateTime? createdAt,
    String? createdByUid,
    DateTime? expiresAt,
    List<String>? readBy,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      targetBranches: targetBranches ?? this.targetBranches,
      createdAt: createdAt ?? this.createdAt,
      createdByUid: createdByUid ?? this.createdByUid,
      expiresAt: expiresAt ?? this.expiresAt,
      readBy: readBy ?? this.readBy,
    );
  }

  // ✅ Mark as read by adding member ID
  AnnouncementModel markAsReadBy(String memberId) {
    if (readBy.contains(memberId)) return this;
    return copyWith(readBy: [...readBy, memberId]);
  }

  @override
  String toString() {
    return 'AnnouncementModel(id: $id, title: $title, message: $message, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnnouncementModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
