import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/partner_summary_model.dart';

class PartnerComparisonCard extends StatelessWidget {
  final PartnerSummaryModel summary;
  final Color accentColor;

  const PartnerComparisonCard({
    super.key,
    required this.summary,
    this.accentColor = AppColors.primaryLight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final workedTime = DateTimeFormatter.formatMinutesToArabic(summary.workedMinutes);
    final requiredTime = DateTimeFormatter.formatMinutesToArabic(summary.requiredMinutes);
    final overtime = DateTimeFormatter.formatMinutesToArabic(summary.overtimeMinutes);
    final deficit = DateTimeFormatter.formatMinutesToArabic(summary.deficitMinutes);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      border: Border.all(color: accentColor.withAlpha(80), width: 1.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Partner Name & Effort Percentage Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    summary.userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor),
                ),
                child: Text(
                  'المجهود: ${summary.effortPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Primary Numbers (Hours & Points)
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'إجمالي ساعات العمل',
                  value: DateTimeFormatter.formatMinutesToDigital(summary.workedMinutes),
                  subtitle: workedTime,
                  color: accentColor,
                ),
              ),
              Container(
                height: 48,
                width: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'مجموع النقاط',
                  value: summary.totalPoints.toStringAsFixed(1),
                  subtitle: 'متوسط: ${summary.averageDailyPoints}/يوم',
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Detailed Breakdown Metrics
          _buildDetailRow('الساعات المطلوبة في الشهر:', requiredTime),
          const SizedBox(height: 6),
          _buildDetailRow(
            'الساعات الإضافية (Overtime):',
            '+$overtime',
            valueColor: AppColors.accent,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            'الساعات الناقصة (Deficit):',
            '-$deficit',
            valueColor: summary.deficitMinutes > 0 ? AppColors.danger : Colors.grey,
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            'أيام العمل والحضور:',
            '${summary.attendanceDaysCount} حضور / ${summary.workingDaysCount} مطلوب',
          ),
          const SizedBox(height: 6),
          _buildDetailRow(
            AppStrings.commitmentRatio,
            '${summary.commitmentPercentage.toStringAsFixed(1)}%',
            valueColor: summary.commitmentPercentage >= 100 ? AppColors.accent : Colors.amber.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
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
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: color,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
