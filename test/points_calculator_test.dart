import 'package:flutter_test/flutter_test.dart';
import 'package:partner_work_tracker/core/utils/points_calculator.dart';

void main() {
  group('PointsCalculator Tests', () {
    test('Mohammad (2h required = 120 mins) points & achievement calculations', () {
      const requiredMinutes = 120;

      // 1. Exactly 2 hours (120 mins) -> 100 points, 100%
      final points100 = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 120,
        requiredDailyMinutes: requiredMinutes,
      );
      final achievement100 = PointsCalculator.calculateAchievementPercentage(
        actualWorkedMinutes: 120,
        requiredDailyMinutes: requiredMinutes,
      );
      expect(points100, 100.0);
      expect(achievement100, 100.0);

      // 2. 1 hour (60 mins) -> 50 points, 50%
      final points50 = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 60,
        requiredDailyMinutes: requiredMinutes,
      );
      final achievement50 = PointsCalculator.calculateAchievementPercentage(
        actualWorkedMinutes: 60,
        requiredDailyMinutes: requiredMinutes,
      );
      expect(points50, 50.0);
      expect(achievement50, 50.0);

      // 3. 3 hours (180 mins) -> 150 points, 150%
      final points150 = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 180,
        requiredDailyMinutes: requiredMinutes,
      );
      final achievement150 = PointsCalculator.calculateAchievementPercentage(
        actualWorkedMinutes: 180,
        requiredDailyMinutes: requiredMinutes,
      );
      expect(points150, 150.0);
      expect(achievement150, 150.0);
    });

    test('Masoud (4h required = 240 mins) points & achievement calculations', () {
      const requiredMinutes = 240;

      // 1. 4 hours (240 mins) -> 100 points, 100%
      final points100 = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 240,
        requiredDailyMinutes: requiredMinutes,
      );
      expect(points100, 100.0);

      // 2. 2 hours (120 mins) -> 50 points, 50%
      final points50 = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 120,
        requiredDailyMinutes: requiredMinutes,
      );
      expect(points50, 50.0);

      // 3. 5 hours (300 mins) -> 125 points, 125%
      final points125 = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 300,
        requiredDailyMinutes: requiredMinutes,
      );
      expect(points125, 125.0);
    });

    test('Equal hours yield proportional points based on distinct commitment', () {
      // 1 hour (60 mins) for Mohammad (2h req) vs Masoud (4h req)
      final mohammadPoints = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 60,
        requiredDailyMinutes: 120,
      );
      final masoudPoints = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 60,
        requiredDailyMinutes: 240,
      );

      expect(mohammadPoints, 50.0);
      expect(masoudPoints, 25.0);
    });

    test('Daily Points Cap restriction', () {
      // Worked 4 hours (240 mins) when required 2 hours (120 mins) -> Raw 200 points
      final uncapped = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 240,
        requiredDailyMinutes: 120,
      );
      expect(uncapped, 200.0);

      // With cap of 150
      final capped = PointsCalculator.calculateDailyPoints(
        actualWorkedMinutes: 240,
        requiredDailyMinutes: 120,
        pointsCap: 150,
      );
      expect(capped, 150.0);
    });

    test('Monthly Effort Share Percentage', () {
      // Mohammad 2,400 points, Masoud 3,600 points -> Total 6,000 points
      const mohammadPoints = 2400.0;
      const masoudPoints = 3600.0;
      const totalPoints = 6000.0;

      final mohammadEffort = PointsCalculator.calculatePartnerEffortPercentage(
        partnerPoints: mohammadPoints,
        totalPartnersPoints: totalPoints,
      );
      final masoudEffort = PointsCalculator.calculatePartnerEffortPercentage(
        partnerPoints: masoudPoints,
        totalPartnersPoints: totalPoints,
      );

      expect(mohammadEffort, 40.0);
      expect(masoudEffort, 60.0);
      expect(mohammadEffort + masoudEffort, 100.0);
    });

    test('Difference calculation (Overtime vs Deficit)', () {
      // Overtime: worked 157 mins when required 120 mins -> +37 mins
      final overtime = PointsCalculator.calculateDifferenceMinutes(
        actualWorkedMinutes: 157,
        requiredDailyMinutes: 120,
      );
      expect(overtime, 37);

      // Deficit: worked 90 mins when required 120 mins -> -30 mins
      final deficit = PointsCalculator.calculateDifferenceMinutes(
        actualWorkedMinutes: 90,
        requiredDailyMinutes: 120,
      );
      expect(deficit, -30);
    });
  });
}
