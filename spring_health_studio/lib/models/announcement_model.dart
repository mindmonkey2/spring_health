
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String branch;
  final String priority;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? scheduledAt;
  final bool isActive;
  final String? imageUrl;
  final List<String> readBy;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.branch,
    this.priority = 'normal',
    required this.createdBy,
    required this.createdAt,
    this.scheduledAt,
    this.isActive = true,
    this.imageUrl,
    this.readBy = const [],
  });

  // ── Alias ─────────────────────────────────────────────────────
  String get content => message;

  // ── Regular method (NOT a getter — getters cannot have params) ──
  bool isReadBy(String memberId) => readBy.contains(memberId);

  // ── Computed getters ─────────────────────────────────────────
  int get readCount => readBy.length;

  bool get isPending =>
  scheduledAt != null && scheduledAt!.isAfter(DateTime.now());

  bool get isUrgent => priority == 'urgent';

  bool get isImportant => priority == 'important' || priority == 'urgent';

  // ── Factory ──────────────────────────────────────────────────
  factory AnnouncementModel.fromMap(Map<String, dynamic> map, String id) {
    return AnnouncementModel(
      id: id,
      title: map['title'] as String? ?? '',
      message: (map['message'] ?? map['content'] ?? '') as String,
      branch: map['branch'] as String? ?? 'All',
      priority: map['priority'] as String? ?? 'normal',
      createdBy: map['createdBy'] as String? ?? 'Admin',
      createdAt: _toDateTime(map['createdAt']),
      scheduledAt: _toDateTimeNullable(map['scheduledAt']),
      isActive: map['isActive'] as bool? ?? true,
      imageUrl: map['imageUrl'] as String?,
      readBy: List<String>.from(map['readBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'content': message,
      'branch': branch,
      'priority': priority,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      if (scheduledAt != null)
        'scheduledAt': Timestamp.fromDate(scheduledAt!),
        'isActive': isActive,
        if (imageUrl != null) 'imageUrl': imageUrl,
          'readBy': readBy,
    };
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _toDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  AnnouncementModel copyWith({
    String? title,
    String? message,
    String? branch,
    String? priority,
    String? createdBy,
    DateTime? createdAt,
    DateTime? scheduledAt,
    bool? isActive,
    String? imageUrl,
    List<String>? readBy,
    bool clearSchedule = false,
  }) {
    return AnnouncementModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      branch: branch ?? this.branch,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: clearSchedule ? null : (scheduledAt ?? this.scheduledAt),
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      readBy: readBy ?? this.readBy,
    );
  }
}
