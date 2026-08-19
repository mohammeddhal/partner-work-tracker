import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/audit_log_repository.dart';
import '../../domain/audit_log_model.dart';

class AuditLogsTab extends ConsumerWidget {
  const AuditLogsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(auditLogsProvider);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('خطأ في تحميل سجل التدقيق: $e')),
      data: (logs) {
        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_edu_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد عمليات مسجلة في سجل التدقيق حتى الآن.',
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final dateStr = DateTimeFormatter.formatArabicFullDate(log.timestamp);
            final timeStr = DateTimeFormatter.formatTime(log.timestamp);

            return AppCard(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getActionColor(log.action).withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getActionIcon(log.action),
                              size: 16,
                              color: _getActionColor(log.action),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            log.action.displayNameArabic,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getActionColor(log.action),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$timeStr • $dateStr',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    log.details,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'المنفّذ: ${log.actorName}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  if (log.reason != null && log.reason!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withAlpha(60)),
                      ),
                      child: Text(
                        'سبب العملية: ${log.reason}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getActionColor(AuditAction action) {
    switch (action) {
      case AuditAction.clockIn:
      case AuditAction.clockOut:
        return AppColors.accent;
      case AuditAction.editSession:
      case AuditAction.addManualSession:
      case AuditAction.updateUserSettings:
        return AppColors.primaryLight;
      case AuditAction.deleteSession:
        return AppColors.danger;
      case AuditAction.closeMonth:
      case AuditAction.reopenMonth:
        return AppColors.warning;
      case AuditAction.login:
        return Colors.blueGrey;
    }
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.clockIn:
        return Icons.play_arrow_rounded;
      case AuditAction.clockOut:
        return Icons.stop_rounded;
      case AuditAction.editSession:
        return Icons.edit_rounded;
      case AuditAction.deleteSession:
        return Icons.delete_rounded;
      case AuditAction.addManualSession:
        return Icons.add_circle_outline_rounded;
      case AuditAction.updateUserSettings:
        return Icons.tune_rounded;
      case AuditAction.closeMonth:
        return Icons.lock_rounded;
      case AuditAction.reopenMonth:
        return Icons.lock_open_rounded;
      case AuditAction.login:
        return Icons.login_rounded;
    }
  }
}
