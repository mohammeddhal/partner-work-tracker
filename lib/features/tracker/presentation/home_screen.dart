import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../admin/presentation/widgets/manual_session_dialog.dart';
import '../../auth/data/auth_repository.dart';
import '../../history/data/daily_summary_repository.dart';
import '../../history/presentation/history_screen.dart';
import '../application/tracker_controller.dart';
import '../data/work_session_repository.dart';
import 'widgets/pulse_timer_button.dart';
import 'widgets/today_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final activeSession = ref.watch(activeSessionProvider).value;
    final todaySummary = ref.watch(todaySummaryProvider).value;
    final todaySessions = ref.watch(todaySessionsProvider).value ?? [];
    final controllerState = ref.watch(trackerControllerProvider);

    final now = DateTime.now();
    final fullDate = DateTimeFormatter.formatArabicFullDate(now);
    final isWorking = activeSession != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.name != null ? '${AppStrings.welcomeBack}${user!.name}' : AppStrings.appName),
        actions: [
          if (user != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.isAdmin ? AppColors.partner1.withAlpha(25) : AppColors.partner2.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user.isAdmin ? AppColors.partner1 : AppColors.partner2,
                  width: 1,
                ),
              ),
              child: Text(
                user.role.displayNameArabic,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: user.isAdmin ? AppColors.partner1 : AppColors.partner2,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.history_edu_rounded, color: AppColors.primaryLight),
            tooltip: 'السجل والتعديلات',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Date Header & Status Tag
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        fullDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isWorking ? AppColors.accent.withAlpha(25) : Colors.grey.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isWorking ? AppColors.accent : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isWorking ? AppColors.accent : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isWorking ? AppStrings.currentlyWorking : AppStrings.notWorkingYet,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isWorking ? AppColors.accentDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Giant Pulse Timer Action Button
                  PulseTimerButton(
                    activeSession: activeSession,
                    isLoading: controllerState.isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Quick Action Buttons (Manual Entry & Audit Log)
                  Row(
                    children: [
                      // Manual Session Retrospective
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => const ManualSessionDialog(),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primaryLight.withAlpha(80)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'إضافة يدوي بأثر رجعي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Audit Log Quick Access
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const HistoryScreen(initialTabIndex: 1)),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fact_check_outlined, color: AppColors.textSecondary, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'سجل التعديلات والتدقيق',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Today Summary Card
                  TodaySummaryCard(
                    user: user,
                    todaySummary: todaySummary,
                  ),

                  const SizedBox(height: 24),

                  // Today's Logged Sessions
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.access_time_filled_rounded, size: 18, color: AppColors.primaryLight),
                                SizedBox(width: 8),
                                Text(
                                  'جلسات عمل اليوم',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                );
                              },
                              child: const Text('عرض السجل الكامل', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        if (todaySessions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'لا توجد جلسات مسجلة اليوم حتى الآن.',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ...todaySessions.map((session) {
                            final startTimeStr = DateTimeFormatter.formatTime(session.startTime);
                            final endTimeStr = session.endTime != null
                                ? DateTimeFormatter.formatTime(session.endTime!)
                                : 'جارية الآن';
                            final durationStr = session.isActive
                                ? 'جارية'
                                : DateTimeFormatter.formatMinutesToArabic(session.durationMinutes);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: session.isActive
                                    ? AppColors.accent.withAlpha(15)
                                    : AppColors.cardAlt,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: session.isActive
                                      ? AppColors.accent.withAlpha(60)
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        session.isActive
                                            ? Icons.play_circle_fill_rounded
                                            : Icons.check_circle_outline_rounded,
                                        size: 20,
                                        color: session.isActive ? AppColors.accent : AppColors.primaryLight,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$startTimeStr - $endTimeStr',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          if (session.isManual)
                                            const Text(
                                              'أضيفت يدوياً بأثر رجعي',
                                              style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: session.isActive
                                              ? AppColors.accent.withAlpha(30)
                                              : AppColors.primaryLight.withAlpha(20),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          durationStr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: session.isActive ? AppColors.accentDark : AppColors.primaryLight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                                        tooltip: 'تعديل',
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => ManualSessionDialog(sessionToEdit: session),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
