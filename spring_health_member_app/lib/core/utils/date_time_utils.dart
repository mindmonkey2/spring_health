import 'package:cloud_firestore/cloud_firestore.dart';

class DateTimeUtils {
  /// Converts a dynamic value (Timestamp, DateTime, String) to DateTime.
  /// Returns [fallback] or DateTime.now() if conversion fails or value is null.
  static DateTime toDateTime(dynamic value, {DateTime? fallback}) {
    final fb = fallback ?? DateTime.now();
    if (value == null) return fb;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? fb;
    }
    return fb;
  }

  /// Converts a dynamic value (Timestamp, DateTime, String, int) to DateTime?.
  /// Returns null if conversion fails or value is null.
  static DateTime? toDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
