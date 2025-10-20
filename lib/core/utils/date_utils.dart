import 'package:intl/intl.dart';

class DateUtils {
  // Format date to readable string
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date, {String format = 'MMM dd, yyyy hh:mm a'}) {
    return DateFormat(format).format(date);
  }

  // Get relative time (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final daysToSubtract = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysToSubtract)));
  }

  // Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final daysToAdd = 7 - date.weekday;
    return endOfDay(date.add(Duration(days: daysToAdd)));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  // Get start of year
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  // Get end of year
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  // Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  // Get number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return to.difference(from).inDays;
  }

  // Get list of dates in a range
  static List<DateTime> getDatesInRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = startOfDay(start);
    final endDay = startOfDay(end);

    while (current.isBefore(endDay) || current.isAtSameMomentAs(endDay)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  // Get ISO 8601 string
  static String toIso8601String(DateTime date) {
    return date.toIso8601String();
  }

  // Parse ISO 8601 string
  static DateTime fromIso8601String(String dateString) {
    return DateTime.parse(dateString);
  }

  // Format for GitHub API (ISO 8601 with timezone)
  static String formatForGitHubApi(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  // Get week number of year
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  // Get month name
  static String getMonthName(int month, {bool short = false}) {
    final date = DateTime(2000, month);
    return DateFormat(short ? 'MMM' : 'MMMM').format(date);
  }

  // Get day name
  static String getDayName(int weekday, {bool short = false}) {
    final date = DateTime(2000, 1, weekday);
    return DateFormat(short ? 'E' : 'EEEE').format(date);
  }
}