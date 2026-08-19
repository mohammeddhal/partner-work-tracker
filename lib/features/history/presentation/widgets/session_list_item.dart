import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../tracker/domain/work_session_model.dart';

class SessionListItem extends StatelessWidget {
  final WorkSessionModel session;
  final VoidCallback? onEdit;
  final bool canEdit;

  const SessionListItem({
    super.key,
    required this.session,
    this.onEdit,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final startStr = DateTimeFormatter.formatTime(session.startTime);
    final endStr = session.endTime != null ? DateTimeFormatter.formatTime(session.endTime) : 'جارية الآن...';
    final durationStr = DateTimeFormatter.formatMinutesToArabic(session.durationMinutes);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.access_time_filled_rounded,
              size: 18,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$startStr  ←  $endStr',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (session.isManual) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'تعديل إداري',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'المدة: $durationStr',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (session.editReason != null && session.editReason!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'السبب: ${session.editReason}',
                    style: const TextStyle(fontSize: 11, color: Colors.amber, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          if (canEdit && onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryLight),
              onPressed: onEdit,
              tooltip: 'تعديل الجلسة',
            ),
        ],
      ),
    );
  }
}
