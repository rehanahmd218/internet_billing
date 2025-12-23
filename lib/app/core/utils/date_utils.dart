import 'package:intl/intl.dart';

class DateUtils {
  // Format date to readable string
  static String formatDate(DateTime date, {String format = 'MMM dd, yyyy'}) {
    return DateFormat(format).format(date);
  }

  // Format date to short format
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  // Get month name from number (1-12)
  static String getMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return DateFormat('MMMM').format(DateTime(2024, month));
  }

  // Get month abbreviation from number (1-12)
  static String getMonthAbbr(int month) {
    if (month < 1 || month > 12) return '';
    return DateFormat('MMM').format(DateTime(2024, month)).toUpperCase();
  }

  // Get current month number
  static int getCurrentMonth() {
    return DateTime.now().month;
  }

  // Get current year
  static int getCurrentYear() {
    return DateTime.now().year;
  }

  // Check if date is in current month
  static bool isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get month number from name
  static int getMonthNumber(String monthName) {
    final months = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];
    final index = months.indexOf(monthName.toLowerCase());
    return index >= 0 ? index + 1 : 0;
  }

  // Get list of years for dropdown
  static List<int> getYearsList({int pastYears = 5, int futureYears = 2}) {
    final currentYear = getCurrentYear();
    final years = <int>[];
    for (int i = currentYear - pastYears; i <= currentYear + futureYears; i++) {
      years.add(i);
    }
    return years;
  }

  // Check if date is overdue
  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  // Get relative time (e.g., "2 days ago")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
