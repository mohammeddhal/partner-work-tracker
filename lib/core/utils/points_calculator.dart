class PointsCalculator {
  /// Calculates daily points based on exact minutes:
  /// (Actual Worked Minutes / Required Daily Minutes) * 100
  /// If [pointsCap] is set, points cannot exceed the cap.
  static double calculateDailyPoints({
    required int actualWorkedMinutes,
    required int requiredDailyMinutes,
    int? pointsCap,
  }) {
    if (requiredDailyMinutes <= 0) return 0.0;
    if (actualWorkedMinutes <= 0) return 0.0;

    final rawPoints = (actualWorkedMinutes / requiredDailyMinutes) * 100.0;

    if (pointsCap != null && pointsCap > 0 && rawPoints > pointsCap) {
      return pointsCap.toDouble();
    }

    // Return with 1 decimal precision rounded
    return double.parse(rawPoints.toStringAsFixed(1));
  }

  /// Calculates daily achievement percentage:
  /// (Actual Worked Minutes / Required Daily Minutes) * 100%
  static double calculateAchievementPercentage({
    required int actualWorkedMinutes,
    required int requiredDailyMinutes,
  }) {
    if (requiredDailyMinutes <= 0) return 0.0;
    if (actualWorkedMinutes <= 0) return 0.0;

    final rawPercentage = (actualWorkedMinutes / requiredDailyMinutes) * 100.0;
    return double.parse(rawPercentage.toStringAsFixed(1));
  }

  /// Calculates the difference in minutes between actual worked and required:
  /// positive = overtime, negative = deficit
  static int calculateDifferenceMinutes({
    required int actualWorkedMinutes,
    required int requiredDailyMinutes,
  }) {
    return actualWorkedMinutes - requiredDailyMinutes;
  }

  /// Calculates a partner's monthly effort contribution share:
  /// (Partner Points / Total Points of all Partners) * 100%
  static double calculatePartnerEffortPercentage({
    required double partnerPoints,
    required double totalPartnersPoints,
  }) {
    if (totalPartnersPoints <= 0.0 || partnerPoints <= 0.0) {
      return 0.0;
    }
    final rawRatio = (partnerPoints / totalPartnersPoints) * 100.0;
    return double.parse(rawRatio.toStringAsFixed(1));
  }

  /// Calculates monthly commitment ratio:
  /// (Actual Worked Minutes / Total Required Working Days Minutes) * 100%
  static double calculateCommitmentRatio({
    required int actualWorkedMinutes,
    required int totalRequiredMinutes,
  }) {
    if (totalRequiredMinutes <= 0) return 0.0;
    if (actualWorkedMinutes <= 0) return 0.0;

    final rawRatio = (actualWorkedMinutes / totalRequiredMinutes) * 100.0;
    return double.parse(rawRatio.toStringAsFixed(1));
  }
}
