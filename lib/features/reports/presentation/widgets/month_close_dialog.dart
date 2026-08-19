import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/monthly_report_repository.dart';
import '../../domain/monthly_report_model.dart';

class MonthCloseDialog extends ConsumerStatefulWidget {
  final String monthKey;
  final MonthlyReportModel computedReport;

  const MonthCloseDialog({
    super.key,
    required this.monthKey,
    required this.computedReport,
  });

  @override
  ConsumerState<MonthCloseDialog> createState() => _MonthCloseDialogState();
}

class _MonthCloseDialogState extends ConsumerState<MonthCloseDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final monthName = DateTimeFormatter.formatArabicMonthYear(widget.monthKey);
    final user = ref.watch(currentUserProvider).value;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          const Icon(Icons.lock_clock_rounded, color: AppColors.warning),
          const SizedBox(width: 8),
          Text(
            '${AppStrings.closeMonthButton} ($monthName)',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'هل أنت متأكد من إغلاق شهر $monthName؟',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'سيتم إنشاء لقطة نهائية (Snapshot) لجميع ساعات ونقاط ونسب الشركاء، وتجميد الشهر ضد أي تعديل مباشر مستقبلاً.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملخص اللقطة المحفوظة:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber),
                  ),
                  const SizedBox(height: 6),
                  ...widget.computedReport.partnerSummaries.values.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• ${p.userName}: ${DateTimeFormatter.formatMinutesToArabic(p.workedMinutes)} (${p.totalPoints} نقطة) - مجهود: ${p.effortPercentage}%',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        SizedBox(
          width: 140,
          child: AppButton(
            text: AppStrings.confirm,
            backgroundColor: AppColors.warning,
            isLoading: _isLoading,
            height: 44,
            onPressed: () async {
              if (user == null) return;
              setState(() => _isLoading = true);
              try {
                await ref.read(monthlyReportRepositoryProvider).closeMonth(
                      monthKey: widget.monthKey,
                      closedByUserId: user.id,
                      closedByUserName: user.name,
                      computedReport: widget.computedReport,
                    );
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم إغلاق شهر $monthName بنجاح واعتماد التقرير!'),
                      backgroundColor: AppColors.accent,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e'), backgroundColor: AppColors.danger),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
          ),
        ),
      ],
    );
  }
}
