import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/domain/user_model.dart';
import '../../../history/domain/daily_summary_model.dart';

class TodaySummaryCard extends StatelessWidget {
  final UserModel? user;
  final DailySummaryModel? todaySummary;

  const TodaySummaryCard({
    super.key,
    required this.user,
    required this.todaySummary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final workedMinutes = todaySummary?.workedMinutes ?? 0;
    final requiredMinutes = user?.requiredDailyMinutes ?? 120;
    final points = todaySummary?.points ?? 0.0;
    final achievement = todaySummary?.achievementPercentage ?? 0.0;
    final difference = todaySummary?.differenceMinutes ?? (workedMinutes - requiredMinutes);
    final sessionsCount = todaySummary?.sessionsCount ?? 0;

    final isOvertime = difference > 0;
    final diffColor = isOvertime ? AppColors.accent : (difference < 0 ? AppColors.danger : Colors.grey);
    final diffPrefix = isOvertime ? '+' : '';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 20, color: AppColors.primaryLight),
                  SizedBox(width: 8),
                  Text(
                    'ملخص اليوم',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$sessionsCount ${AppStrings.sessionsCount}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Stats Grid
          Row(
            children: [
              // 1. Worked Time
              Expanded(
                child: _buildMetric(
                  context,
                  title: AppStrings.todayWorkTime,
                  value: DateTimeFormatter.formatMinutesToDigital(workedMinutes),
                  subtitle: DateTimeFormatter.formatMinutesToArabic(workedMinutes),
                  color: AppColors.primaryLight,
                ),
              ),
              Container(height: 48, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),

              // 2. Required Time
              Expanded(
                child: _buildMetric(
                  context,
                  title: AppStrings.requiredTime,
                  value: DateTimeFormatter.formatMinutesToDigital(requiredMinutes),
                  subtitle: DateTimeFormatter.formatMinutesToArabic(requiredMinutes),
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Points and Achievement
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Points
              Column(
                children: [
                  const Text(
                    AppStrings.todayPoints,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    points.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ],
              ),

              // Achievement %
              Column(
                children: [
                  const Text(
                    AppStrings.achievementRatio,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${achievement.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: achievement >= 100 ? AppColors.accent : Colors.amber.shade700,
                    ),
                  ),
                ],
              ),

              // Difference
              Column(
                children: [
                  const Text(
                    AppStrings.differenceTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$diffPrefix${DateTimeFormatter.formatMinutesToArabic(difference)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: diffColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
