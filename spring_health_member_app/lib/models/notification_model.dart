import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { xp, badge, gym, announcement }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.metadata,
  });

  factory AppNotification.fromFirestore(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      type: NotificationType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'gym'),
        orElse: () => NotificationType.gym,
      ),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type': type.name,
    'title': title,
    'body': body,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
    if (metadata != null) 'metadata': metadata,
  };

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    metadata: metadata,
  );
}
