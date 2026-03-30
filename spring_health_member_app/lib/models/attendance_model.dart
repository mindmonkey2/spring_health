import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String memberId;
  final String memberName;
  final String branch;
  final DateTime checkInTime;
  final DateTime date;
  final DateTime? checkOutTime;

  const AttendanceModel({
    required this.id, // ✅ FIX 7: const constructor
    required this.memberId,
    required this.memberName,
    required this.branch,
    required this.checkInTime,
    required this.date,
    this.checkOutTime,
  });

  // ══════════════════════════════════════════════════════════
  // SAFE DATE PARSING HELPERS
  // ══════════════════════════════════════════════════════════

  // ✅ FIX 1: Handles Timestamp, ISO String, AND null — never crashes
  static DateTime _toDateTime(dynamic value, {DateTime? fallback}) {
    final fb = fallback ?? DateTime.now();
    if (value == null) return fb;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? fb;
    }
    return fb;
  }

  // ✅ FIX 1: Nullable variant — safe for checkOutTime
  static DateTime? _toDateTimeNullable(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  // ══════════════════════════════════════════════════════════
  // SERIALISATION
  // ══════════════════════════════════════════════════════════

  // ✅ FIX 4: Typed Map<String, dynamic>
  // ✅ FIX 3: Does NOT write 'id' — Firestore doc ID is separate
  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'memberName': memberName,
      'branch': branch,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'date': Timestamp.fromDate(date),
      'checkOutTime': checkOutTime != null
          ? Timestamp.fromDate(checkOutTime!)
          : null,
    };
  }

  // ✅ FIX 2 & 3: Accepts explicit docId — Firestore never stores ID inside data
  // ✅ FIX 1: Uses safe _toDateTime helpers
  // ✅ FIX 4: Typed Map<String, dynamic>
  factory AttendanceModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AttendanceModel(
      // Prefer the explicit docId; fall back to map key (admin-written records)
      id: docId ?? map['id']?.toString() ?? '',
      memberId: map['memberId']?.toString() ?? '',
      memberName: map['memberName']?.toString() ?? 'Unknown',
      branch: map['branch']?.toString() ?? '',
      checkInTime: _toDateTime(
        map['checkInTime'] ??
            map['timestamp'], // also handles 'timestamp' alias
      ),
      date: _toDateTime(map['date'] ?? map['checkInTime'] ?? map['timestamp']),
      checkOutTime: _toDateTimeNullable(map['checkOutTime']),
    );
  }

  // ✅ FIX 5: fromFirestore — clean Firestore DocumentSnapshot integration
  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AttendanceModel.fromMap(data, doc.id);
  }

  // ✅ JSON (local storage / REST APIs)
  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      AttendanceModel.fromMap(json);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'branch': branch,
      'checkInTime': checkInTime.toIso8601String(),
      'date': date.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
    };
  }

  // ══════════════════════════════════════════════════════════
  // COPY WITH
  // ══════════════════════════════════════════════════════════

  // ✅ FIX 6: Uses Object? sentinel so checkOutTime CAN be explicitly set to null
  AttendanceModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? branch,
    DateTime? checkInTime,
    DateTime? date,
    Object? checkOutTime = _sentinel, // allows null to be passed explicitly
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      branch: branch ?? this.branch,
      checkInTime: checkInTime ?? this.checkInTime,
      date: date ?? this.date,
      checkOutTime: checkOutTime == _sentinel
          ? this.checkOutTime
          : checkOutTime as DateTime?,
    );
  }

  // ══════════════════════════════════════════════════════════
  // COMPUTED GETTERS
  // ══════════════════════════════════════════════════════════

  bool get isCheckedOut => checkOutTime != null;

  Duration? get workoutDuration => checkOutTime?.difference(checkInTime);

  // ✅ FIX 8: Shows duration even for old sessions without checkout
  String get formattedDuration {
    if (checkOutTime == null) {
      // If check-in was today, it's still in progress; otherwise it's unknown
      return isToday ? 'In Progress' : '—';
    }
    final d = workoutDuration!;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  bool get isToday {
    final now = DateTime.now();
    return checkInTime.year == now.year &&
        checkInTime.month == now.month &&
        checkInTime.day == now.day;
  }

  bool get isThisWeek {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return checkInTime.isAfter(weekAgo);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return checkInTime.year == now.year && checkInTime.month == now.month;
  }

  // Time of day label for stats
  String get timeOfDay {
    final h = checkInTime.hour;
    if (h < 7) return 'Early Bird ';
    if (h < 12) return 'Morning ';
    if (h < 17) return 'Afternoon ';
    if (h < 20) return 'Evening ';
    return 'Night Owl ';
  }

  // ══════════════════════════════════════════════════════════
  // EQUALITY & DEBUG
  // ══════════════════════════════════════════════════════════

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel &&
        other.id == id &&
        other.memberId == memberId &&
        other.memberName == memberName &&
        other.branch == branch &&
        other.checkInTime == checkInTime &&
        other.date == date &&
        other.checkOutTime == checkOutTime;
  }

  @override
  int get hashCode => Object.hash(
    id,
    memberId,
    memberName,
    branch,
    checkInTime,
    date,
    checkOutTime,
  ); // ✅ Object.hash is safer than manual XOR chains

  @override
  String toString() =>
      'AttendanceModel('
      'id: $id, '
      'memberId: $memberId, '
      'memberName: $memberName, '
      'branch: $branch, '
      'checkInTime: $checkInTime, '
      'date: $date, '
      'checkOutTime: $checkOutTime'
      ')';
}

// Sentinel for copyWith null-clearing support
const Object _sentinel = Object();
