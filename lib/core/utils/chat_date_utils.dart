/// Utility class providing robust calendar-accurate date, day, and time formatting for Chat.
class ChatDateUtils {
  ChatDateUtils._();

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _monthShortNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// Converts a [DateTime] to local timezone and strips time components to return pure calendar date.
  static DateTime toDateOnly(DateTime dt) {
    final local = dt.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Calculates the difference in calendar days between [date] and [relativeTo] (defaults to now).
  ///
  /// Returns:
  /// - 0 for today
  /// - 1 for yesterday
  /// - 2 for 2 days ago, etc.
  static int calendarDaysAgo(DateTime date, {DateTime? relativeTo}) {
    final nowOnly = toDateOnly(relativeTo ?? DateTime.now());
    final dateOnly = toDateOnly(date);
    return nowOnly.difference(dateOnly).inDays;
  }

  /// Checks if two [DateTime] instances fall on the same calendar day in local time.
  static bool isSameDay(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }

  /// Formats time in standard 12-hour format with AM/PM (e.g. "5:31 PM", "10:46 AM", "12:00 PM").
  static String formatMessageTime(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Formats date for conversation list preview timestamps (e.g. "5:31 PM", "Yesterday", "Wednesday", "Aug 26").
  static String formatConversationTime(DateTime dt) {
    final local = dt.toLocal();
    final daysAgo = calendarDaysAgo(local);

    if (daysAgo == 0) {
      return formatMessageTime(local);
    } else if (daysAgo == 1) {
      return 'Yesterday';
    } else if (daysAgo >= 2 && daysAgo < 7) {
      return _weekdayNames[local.weekday - 1];
    } else {
      final now = DateTime.now();
      final month = _monthShortNames[local.month - 1];
      if (local.year == now.year) {
        return '$month ${local.day}';
      } else {
        return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
      }
    }
  }

  /// Formats date for message list date chips (e.g. "Today", "Yesterday", "Wednesday, Aug 26", "August 26, 2026").
  static String formatDateHeader(DateTime dt) {
    final local = dt.toLocal();
    final daysAgo = calendarDaysAgo(local);
    final now = DateTime.now();

    if (daysAgo == 0) {
      return 'Today';
    } else if (daysAgo == 1) {
      return 'Yesterday';
    } else if (daysAgo >= 2 && daysAgo < 7) {
      final weekday = _weekdayNames[local.weekday - 1];
      final month = _monthShortNames[local.month - 1];
      return '$weekday, $month ${local.day}';
    } else if (local.year == now.year) {
      final month = _monthNames[local.month - 1];
      return '$month ${local.day}, ${local.year}';
    } else {
      final month = _monthNames[local.month - 1];
      return '$month ${local.day}, ${local.year}';
    }
  }
}
