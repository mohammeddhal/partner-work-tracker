import 'package:flutter_test/flutter_test.dart';
import 'package:partner_work_tracker/features/auth/domain/user_model.dart';
import 'package:partner_work_tracker/features/auth/domain/user_role.dart';
import 'package:partner_work_tracker/features/history/domain/daily_summary_model.dart';
import 'package:partner_work_tracker/features/reports/data/monthly_report_repository.dart';

void main() {
  group('Monthly Report Computation & Aggregation Tests', () {
    test('Calculates partner metrics and effort shares correctly for multiple partners', () {
      final mohammad = UserModel(
        id: 'user_mohammad',
        name: 'محمد',
        email: 'mohammad@partner.com',
        role: UserRole.admin,
        requiredDailyMinutes: 120, // 2 Hours
        workingDaysPerWeek: 5,
        workingDays: [7, 1, 2, 3, 4], // Sun to Thu
        effectiveStartDate: DateTime(2026, 8, 1),
      );

      final masoud = UserModel(
        id: 'user_masoud',
        name: 'مسعود',
        email: 'masoud@partner.com',
        role: UserRole.partner,
        requiredDailyMinutes: 240, // 4 Hours
        workingDaysPerWeek: 5,
        workingDays: [7, 1, 2, 3, 4], // Sun to Thu
        effectiveStartDate: DateTime(2026, 8, 1),
      );

      final summaries = [
        // Mohammad worked 2h on day 1 (100 pts) and 3h on day 2 (150 pts) -> 250 pts total
        DailySummaryModel(
          id: 'mohammad_day1',
          userId: 'user_mohammad',
          userName: 'محمد',
          dateKey: '2026-08-03',
          monthKey: '2026-08',
          workedMinutes: 120,
          requiredMinutes: 120,
          differenceMinutes: 0,
          points: 100.0,
          achievementPercentage: 100.0,
          sessionsCount: 1,
        ),
        DailySummaryModel(
          id: 'mohammad_day2',
          userId: 'user_mohammad',
          userName: 'محمد',
          dateKey: '2026-08-04',
          monthKey: '2026-08',
          workedMinutes: 180,
          requiredMinutes: 120,
          differenceMinutes: 60,
          points: 150.0,
          achievementPercentage: 150.0,
          sessionsCount: 2,
        ),

        // Masoud worked 4h on day 1 (100 pts) and 6h on day 2 (150 pts) -> 250 pts total
        DailySummaryModel(
          id: 'masoud_day1',
          userId: 'user_masoud',
          userName: 'مسعود',
          dateKey: '2026-08-03',
          monthKey: '2026-08',
          workedMinutes: 240,
          requiredMinutes: 240,
          differenceMinutes: 0,
          points: 100.0,
          achievementPercentage: 100.0,
          sessionsCount: 1,
        ),
        DailySummaryModel(
          id: 'masoud_day2',
          userId: 'user_masoud',
          userName: 'مسعود',
          dateKey: '2026-08-04',
          monthKey: '2026-08',
          workedMinutes: 360,
          requiredMinutes: 240,
          differenceMinutes: 120,
          points: 150.0,
          achievementPercentage: 150.0,
          sessionsCount: 2,
        ),
      ];

      final report = MonthlyReportRepository.computeMonthlyReport(
        monthKey: '2026-08',
        users: [mohammad, masoud],
        summaries: summaries,
      );

      // Total points: 250 + 250 = 500
      expect(report.totalPartnersPoints, 500.0);

      final mohammadSummary = report.partnerSummaries['user_mohammad']!;
      final masoudSummary = report.partnerSummaries['user_masoud']!;

      expect(mohammadSummary.workedMinutes, 300); // 120 + 180 = 300 mins (5 hours)
      expect(mohammadSummary.totalPoints, 250.0);
      expect(mohammadSummary.effortPercentage, 50.0);

      expect(masoudSummary.workedMinutes, 600); // 240 + 360 = 600 mins (10 hours)
      expect(masoudSummary.totalPoints, 250.0);
      expect(masoudSummary.effortPercentage, 50.0);
    });
  });
}
