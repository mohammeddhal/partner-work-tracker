import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/data/auth_repository.dart';
import '../data/monthly_report_repository.dart';
import 'widgets/effort_ratio_chart.dart';
import 'widgets/month_close_dialog.dart';
import 'widgets/partner_comparison_card.dart';
import 'widgets/previous_months_tab.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isAdmin = currentUser?.isAdmin ?? false;
    final now = DateTime.now();
    final currentMonthKey = DateTimeFormatter.toMonthKey(now);
    final monthName = DateTimeFormatter.formatArabicMonthYear(currentMonthKey);

    final report = ref.watch(liveMonthlyReportProvider(currentMonthKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.monthlyReportTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryLight,
          labelColor: AppColors.primaryLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'الشهر الحالي'),
            Tab(text: AppStrings.previousMonthsTitle),
          ],
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Current Month Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  monthName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: report.isClosed ? Colors.grey : AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      report.isClosed ? AppStrings.closedMonthTag : AppStrings.openMonthTag,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: report.isClosed ? Colors.grey : AppColors.accentDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Close Month Button (Admin Only)
                            if (isAdmin && !report.isClosed)
                              SizedBox(
                                width: 140,
                                child: AppButton(
                                  text: AppStrings.closeMonthButton,
                                  icon: Icons.lock_clock_rounded,
                                  backgroundColor: AppColors.warning,
                                  height: 42,
                                  fontSize: 13,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => MonthCloseDialog(
                                        monthKey: currentMonthKey,
                                        computedReport: report,
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Effort Ratio Section & Pie Chart
                      const Text(
                        AppStrings.effortRatio,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      AppCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            EffortRatioChart(report: report),
                            const SizedBox(height: 12),
                            const Text(
                              AppStrings.effortShareDisclaimer,
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Partners Individual Comparison Cards
                      const Text(
                        AppStrings.partnerComparison,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (report.partnerSummaries.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'جاري تحميل بيانات الشركاء...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else ...[
                        ...report.partnerSummaries.values.map((summary) {
                          final isMohammad = summary.userName.contains('محمد');
                          return PartnerComparisonCard(
                            summary: summary,
                            accentColor: isMohammad ? AppColors.partner1 : AppColors.partner2,
                          );
                        }),
                      ],
                    ],
                  ),
                ),

                // 2. Previous Closed Months Tab
                const PreviousMonthsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
