class DateUtils {
  // Month constants in days
  static const int daysInMonth = 30;
  static const int daysIn3Months = 90;
  static const int daysIn6Months = 180;
  static const int daysInYear = 365;

  /// Calculate expiry date based on plan duration
  static DateTime calculateExpiryDate(DateTime joiningDate, String plan) {
    switch (plan) {
      case '1 Day':
        return joiningDate.add(const Duration(days: 1));
      case '1 Month':
        return joiningDate.add(const Duration(days: daysInMonth));
      case '3 Months':
        return joiningDate.add(const Duration(days: daysIn3Months));
      case '6 Months':
        return joiningDate.add(const Duration(days: daysIn6Months));
      case '1 Year':
        return joiningDate.add(const Duration(days: daysInYear));
      default:
        // Default to 1 month if plan is not recognized
        return joiningDate.add(const Duration(days: daysInMonth));
    }
  }

  /// Format date to DD/MM/YYYY
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format date with time to DD/MM/YYYY HH:MM
  static String formatDateTime(DateTime dateTime) {
    final date = formatDate(dateTime);
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$date $hour:$minute';
  }

  /// Format time only to HH:MM
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Check if a date is active (not expired)
  static bool isActive(DateTime expiryDate) {
    return expiryDate.isAfter(DateTime.now());
  }

  /// Calculate days until expiry
  static int daysUntilExpiry(DateTime expiryDate) {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Check if expiry is near (within 7 days)
  static bool isNearExpiry(DateTime expiryDate) {
    final daysLeft = daysUntilExpiry(expiryDate);
    return daysLeft >= 0 && daysLeft <= 7;
  }

  /// Get days remaining text
  static String getDaysRemainingText(DateTime expiryDate) {
    final days = daysUntilExpiry(expiryDate);

    if (days < 0) {
      return 'Expired ${days.abs()} day${days.abs() == 1 ? '' : 's'} ago';
    } else if (days == 0) {
      return 'Expires today';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else if (days <= 7) {
      return 'Expires in $days days';
    } else if (days <= 30) {
      return 'Expires in $days days';
    } else {
      final months = (days / 30).floor();
      return 'Expires in $months month${months == 1 ? '' : 's'}';
    }
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekDay = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekDay - 1)));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final weekDay = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekDay)));
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
    date1.month == date2.month &&
    date1.day == date2.day;
  }

  /// Format month and year (e.g., "November 2025")
  static String formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Get relative time (e.g., "2 hours ago", "yesterday")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes == 1 ? '' : 's'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) {
        return 'Yesterday';
      }
      return '$days days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
      (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
      }

      return age;
  }

  /// Get day name (e.g., "Monday")
  static String getDayName(DateTime date) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[date.weekday - 1];
  }

  /// Get short day name (e.g., "Mon")
  static String getShortDayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  /// Get month name (e.g., "November")
  static String getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  /// Get short month name (e.g., "Nov")
  static String getShortMonthName(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[date.month - 1];
  }

  /// Parse date string (DD/MM/YYYY) to DateTime
  static DateTime? parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get date range text (e.g., "16 Nov - 23 Nov")
  static String formatDateRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatDate(start);
    }

    if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${end.day} ${getShortMonthName(start)} ${start.year}';
    } else if (start.year == end.year) {
      return '${start.day} ${getShortMonthName(start)} - ${end.day} ${getShortMonthName(end)} ${start.year}';
    } else {
      return '${start.day} ${getShortMonthName(start)} ${start.year} - ${end.day} ${getShortMonthName(end)} ${end.year}';
    }
  }
}
