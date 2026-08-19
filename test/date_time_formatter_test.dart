import 'package:flutter_test/flutter_test.dart';
import 'package:partner_work_tracker/core/utils/date_time_formatter.dart';

void main() {
  group('DateTimeFormatter Tests', () {
    test('formatMinutesToArabic converts exact minutes into Arabic string', () {
      expect(DateTimeFormatter.formatMinutesToArabic(150), '2 ساعة و 30 دقيقة');
      expect(DateTimeFormatter.formatMinutesToArabic(60), '1 ساعة');
      expect(DateTimeFormatter.formatMinutesToArabic(45), '45 دقيقة');
      expect(DateTimeFormatter.formatMinutesToArabic(0), '0 دقيقة');
      expect(DateTimeFormatter.formatMinutesToArabic(-30), '- 30 دقيقة');
    });

    test('formatMinutesToDigital formats minutes into HH:MM digital string', () {
      expect(DateTimeFormatter.formatMinutesToDigital(150), '02:30');
      expect(DateTimeFormatter.formatMinutesToDigital(60), '01:00');
      expect(DateTimeFormatter.formatMinutesToDigital(45), '00:45');
      expect(DateTimeFormatter.formatMinutesToDigital(-30), '-00:30');
    });

    test('formatSecondsToStopwatch formats seconds into HH:MM:SS', () {
      // 01:42:18 = 3600 + 42*60 + 18 = 3600 + 2520 + 18 = 6138 seconds
      expect(DateTimeFormatter.formatSecondsToStopwatch(6138), '01:42:18');
      expect(DateTimeFormatter.formatSecondsToStopwatch(0), '00:00:00');
    });

    test('Date key conversion and round-trip', () {
      final date = DateTime(2026, 8, 19);
      final key = DateTimeFormatter.toDateKey(date);
      expect(key, '2026-08-19');

      final parsed = DateTimeFormatter.fromDateKey(key);
      expect(parsed.year, 2026);
      expect(parsed.month, 8);
      expect(parsed.day, 19);
    });

    test('Month key conversion and round-trip', () {
      final date = DateTime(2026, 8, 1);
      final monthKey = DateTimeFormatter.toMonthKey(date);
      expect(monthKey, '2026-08');

      final parsed = DateTimeFormatter.fromMonthKey(monthKey);
      expect(parsed.year, 2026);
      expect(parsed.month, 8);
    });
  });
}
