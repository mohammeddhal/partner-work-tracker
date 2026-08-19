import 'package:intl/intl.dart';

class DateTimeFormatter {
  static final DateFormat _dateKeyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _monthKeyFormat = DateFormat('yyyy-MM');
  static final DateFormat _arabicDateFormat = DateFormat('EEEE، d MMMM yyyy', 'ar');
  static final DateFormat _arabicShortDateFormat = DateFormat('d MMMM', 'ar');
  static final DateFormat _arabicMonthYearFormat = DateFormat('MMMM yyyy', 'ar');
  static final DateFormat _timeFormat = DateFormat('hh:mm a', 'ar');
  static final DateFormat _time24Format = DateFormat('HH:mm');

  /// Converts a DateTime into 'YYYY-MM-DD' key
  static String toDateKey(DateTime date) {
    return _dateKeyFormat.format(date);
  }

  /// Converts a DateTime into 'YYYY-MM' key
  static String toMonthKey(DateTime date) {
    return _monthKeyFormat.format(date);
  }

  /// Parses 'YYYY-MM-DD' key to DateTime
  static DateTime fromDateKey(String key) {
    return _dateKeyFormat.parse(key);
  }

  /// Parses 'YYYY-MM' key to DateTime
  static DateTime fromMonthKey(String key) {
    return _monthKeyFormat.parse(key);
  }

  /// Formats date to Arabic full text e.g. "الأربعاء، 19 أغسطس 2026"
  static String formatArabicFullDate(DateTime date) {
    try {
      return _arabicDateFormat.format(date);
    } catch (_) {
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  /// Formats date to Arabic short text e.g. "19 أغسطس"
  static String formatArabicShortDate(DateTime date) {
    try {
      return _arabicShortDateFormat.format(date);
    } catch (_) {
      return "${date.day}/${date.month}";
    }
  }

  /// Formats month key to Arabic month year e.g. "أغسطس 2026"
  static String formatArabicMonthYear(String monthKey) {
    try {
      final date = fromMonthKey(monthKey);
      return _arabicMonthYearFormat.format(date);
    } catch (_) {
      return monthKey;
    }
  }

  /// Formats DateTime to localized time string e.g. "08:30 ص"
  static String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    try {
      return _timeFormat.format(time);
    } catch (_) {
      return _time24Format.format(time);
    }
  }

  /// Formats an integer amount of minutes into clear Arabic words:
  /// Examples:
  /// 150 mins -> "2 ساعة و30 دقيقة"
  /// 60 mins -> "1 ساعة"
  /// 45 mins -> "45 دقيقة"
  /// 0 mins -> "0 دقيقة"
  static String formatMinutesToArabic(int totalMinutes) {
    final isNegative = totalMinutes < 0;
    final absMinutes = totalMinutes.abs();

    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    String result = '';
    if (hours > 0 && minutes > 0) {
      result = '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      result = '$hours ساعة';
    } else {
      result = '$minutes دقيقة';
    }

    return isNegative ? '- $result' : result;
  }

  /// Formats total minutes into digital time string e.g. "02:30"
  static String formatMinutesToDigital(int totalMinutes) {
    final isNegative = totalMinutes < 0;
    final absMinutes = totalMinutes.abs();

    final hours = absMinutes ~/ 60;
    final minutes = absMinutes % 60;

    final formatted = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    return isNegative ? '-$formatted' : formatted;
  }

  /// Formats seconds into "HH:MM:SS" digital stopwatch string
  static String formatSecondsToStopwatch(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
