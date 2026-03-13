class DocumentSentModel {
  final String type; // 'welcome', 'rejoin', 'receipt', 'resend'
  final DateTime sentAt;
  final String sentBy; // User email/ID who sent it
  final String method; // 'whatsapp', 'email', 'both'
  final bool success;

  DocumentSentModel({
    required this.type,
    required this.sentAt,
    required this.sentBy,
    required this.method,
    this.success = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'sentAt': sentAt.toIso8601String(),
      'sentBy': sentBy,
      'method': method,
      'success': success,
    };
  }

  factory DocumentSentModel.fromMap(Map<String, dynamic> map) {
    return DocumentSentModel(
      type: map['type'] ?? '',
      sentAt: DateTime.parse(map['sentAt']),
      sentBy: map['sentBy'] ?? '',
      method: map['method'] ?? 'whatsapp',
      success: map['success'] ?? true,
    );
  }

  String get displayText {
    final date = '${sentAt.day}/${sentAt.month}/${sentAt.year}';
    final time = '${sentAt.hour}:${sentAt.minute.toString().padLeft(2, '0')}';
    return '$type via $method on $date at $time';
  }
}
