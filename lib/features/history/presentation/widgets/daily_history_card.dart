import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../tracker/data/work_session_repository.dart';
import '../../../tracker/domain/work_session_model.dart';
import '../../domain/daily_summary_model.dart';
import 'session_list_item.dart';

class DailyHistoryCard extends ConsumerStatefulWidget {
  final DailySummaryModel summary;
  final Function(WorkSessionModel session)? onEditSession;

  const DailyHistoryCard({
    super.key,
    required this.summary,
    this.onEditSession,
  });

  @override
  ConsumerState<DailyHistoryCard> createState() => _DailyHistoryCardState();
}

class _DailyHistoryCardState extends ConsumerState<DailyHistoryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final currentUser = ref.watch(currentUserProvider).value;
    final isAdmin = currentUser?.isAdmin ?? false;

    final date = DateTimeFormatter.fromDateKey(summary.dateKey);
    final arabicDate = DateTimeFormatter.formatArabicShortDate(date);
    final dayName = DateTimeFormatter.formatArabicFullDate(date).split('،').first;

    final isOvertime = summary.differenceMinutes > 0;
    final isDeficit = summary.differenceMinutes < 0;
    final diffColor = isOvertime ? AppColors.accent : (isDeficit ? AppColors.danger : Colors.grey);
    final diffSign = isOvertime ? '+' : '';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                // Date Column
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      Text(
                        arabicDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),

                // Summary Stats Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الفعلي: ${DateTimeFormatter.formatMinutesToArabic(summary.workedMinutes)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${summary.points.toStringAsFixed(1)} نقطة',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المطلوب: ${DateTimeFormatter.formatMinutesToArabic(summary.requiredMinutes)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            'الفارق: $diffSign${DateTimeFormatter.formatMinutesToArabic(summary.differenceMinutes)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: diffColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          // Expanded Session Details
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppStrings.firstCheckIn}: ${DateTimeFormatter.formatTime(summary.firstCheckIn)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${AppStrings.lastCheckOut}: ${DateTimeFormatter.formatTime(summary.lastCheckOut)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Consumer(
              builder: (context, ref, child) {
                final sessionsStream = ref.watch(
                  workSessionRepositoryProvider,
                ).watchSessionsForDate(summary.userId, summary.dateKey);

                return StreamBuilder<List<WorkSessionModel>>(
                  stream: sessionsStream,
                  builder: (context, snapshot) {
                    final sessions = snapshot.data ?? [];
                    if (sessions.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'لا توجد تفاصيل جلسات مسجلة.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'قائمة الجلسات:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...sessions.map((s) => SessionListItem(
                              session: s,
                              canEdit: isAdmin,
                              onEdit: widget.onEditSession != null
                                  ? () => widget.onEditSession!(s)
                                  : null,
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
