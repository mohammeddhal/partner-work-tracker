import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/data/auth_repository.dart';
import '../../history/data/daily_summary_repository.dart';
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
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: user.isAdmin ? AppColors.partner1.withAlpha(30) : AppColors.partner2.withAlpha(30),
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
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isWorking ? AppColors.accent.withAlpha(30) : Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isWorking ? AppColors.accent : Colors.grey.shade400,
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
                                color: isWorking ? AppColors.accentDark : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Giant Pulse Timer Action Button
                  PulseTimerButton(
                    activeSession: activeSession,
                    isLoading: controllerState.isLoading,
                  ),

                  const SizedBox(height: 40),

                  // Today Summary Card
                  TodaySummaryCard(
                    user: user,
                    todaySummary: todaySummary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
