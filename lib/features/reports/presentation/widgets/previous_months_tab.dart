import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/monthly_report_repository.dart';
import 'effort_ratio_chart.dart';
import 'partner_comparison_card.dart';

class PreviousMonthsTab extends ConsumerWidget {
  const PreviousMonthsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final closedReportsAsync = ref.watch(closedReportsProvider);

    return closedReportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل السجل: $e')),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.archive_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد أشهر مغلقة سابقة حتى الآن.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'عند قيام المدير بإغلاق أي شهر ستظهر تقاريره المعتمدة هنا بشكل دائم.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final monthName = DateTimeFormatter.formatArabicMonthYear(report.monthKey);

            return AppCard(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, color: Colors.grey),
                ),
                title: Text(
                  monthName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'أغلق بواسطة: ${report.closedByUserName ?? "المدير"} • إجمالي النقاط: ${report.totalPartnersPoints}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                children: [
                  const SizedBox(height: 12),
                  EffortRatioChart(report: report),
                  const SizedBox(height: 16),
                  ...report.partnerSummaries.values.map((summary) {
                    return PartnerComparisonCard(summary: summary);
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
