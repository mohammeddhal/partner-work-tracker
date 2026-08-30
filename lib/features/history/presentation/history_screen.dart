import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../admin/presentation/widgets/audit_logs_tab.dart';
import '../../admin/presentation/widgets/manual_session_dialog.dart';
import '../../auth/data/auth_repository.dart';
import '../../tracker/domain/work_session_model.dart';
import '../data/daily_summary_repository.dart';
import 'widgets/daily_history_card.dart';

final historySelectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final historySelectedUserProvider = StateProvider<String?>((ref) => null);

class HistoryScreen extends ConsumerWidget {
  final int initialTabIndex;

  const HistoryScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final selectedDate = ref.watch(historySelectedMonthProvider);
    final monthKey = DateTimeFormatter.toMonthKey(selectedDate);
    final selectedUserId = ref.watch(historySelectedUserProvider) ?? currentUser?.id ?? '';

    final summariesAsync = ref.watch(dailySummaryRepositoryProvider)
        .watchUserSummariesForMonth(selectedUserId, monthKey);

    return DefaultTabController(
      length: 2,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('السجل والتدقيق'),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryLight,
            labelColor: AppColors.primaryLight,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(
                icon: Icon(Icons.history_toggle_off_rounded, size: 20),
                text: 'سجل ساعات العمل',
              ),
              Tab(
                icon: Icon(Icons.fact_check_outlined, size: 20),
                text: 'سجل التعديلات والتدقيق',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight),
              tooltip: 'إضافة جلسة بأثر رجعي (يدوي)',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const ManualSessionDialog(),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Work Sessions History
            Column(
              children: [
                const OfflineBanner(),

                // Month Switcher Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          ref.read(historySelectedMonthProvider.notifier).state =
                              DateTime(selectedDate.year, selectedDate.month - 1);
                        },
                      ),
                      Text(
                        DateTimeFormatter.formatArabicMonthYear(monthKey),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          ref.read(historySelectedMonthProvider.notifier).state =
                              DateTime(selectedDate.year, selectedDate.month + 1);
                        },
                      ),
                    ],
                  ),
                ),

                // Partner Selector Chip Bar (Visible for Mohammed & Masoud)
                if (allUsers.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: AppColors.background,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const Text('عرض سجل: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          ...allUsers.map((u) {
                            final isSelected = u.id == selectedUserId;
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text(u.name),
                                selected: isSelected,
                                selectedColor: AppColors.primaryLight.withAlpha(40),
                                labelStyle: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primaryLight : AppColors.textPrimary,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(historySelectedUserProvider.notifier).state = u.id;
                                  }
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                // Daily Summaries List
                Expanded(
                  child: StreamBuilder(
                    stream: summariesAsync,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final summaries = snapshot.data ?? [];
                      if (summaries.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                AppStrings.noSessions,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة جلسة بأثر رجعي'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const ManualSessionDialog(),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: summaries.length,
                        itemBuilder: (context, index) {
                          final summary = summaries[index];
                          return DailyHistoryCard(
                            summary: summary,
                            onEditSession: (WorkSessionModel session) {
                              showDialog(
                                context: context,
                                builder: (context) => ManualSessionDialog(sessionToEdit: session),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // Tab 2: Audit Logs Tab (Visible to both Mohammed and Masoud)
            const AuditLogsTab(),
          ],
        ),
      ),
    );
  }
}
