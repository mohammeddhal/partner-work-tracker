import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/task_repository.dart';
import '../../domain/task_model.dart';

class TaskListItem extends ConsumerWidget {
  final TaskModel task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isMohammad = task.assignedToName.contains('محمد');
    final assignedColor = isMohammad ? AppColors.partner1 : AppColors.partner2;

    final startDateStr = DateTimeFormatter.formatArabicShortDate(task.startDate);
    final dueDateStr = DateTimeFormatter.formatArabicShortDate(task.dueDate);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      border: Border.all(
        color: task.isOverdue
            ? AppColors.danger
            : (task.isCompleted ? Colors.grey.shade400 : AppColors.primaryLight.withAlpha(80)),
        width: task.isOverdue ? 1.5 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Checkbox + Title + Status Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: task.isCompleted,
                  activeColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  onChanged: (val) async {
                    await ref.read(taskRepositoryProvider).toggleTaskCompleted(
                          task: task,
                          actorId: currentUser?.id ?? '',
                          actorName: currentUser?.name ?? 'المستخدم',
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey : null,
                      ),
                    ),
                    if (task.description != null && task.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: task.isCompleted ? Colors.grey.shade400 : Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Overdue or Completed Badge
              if (task.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.danger),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.danger),
                      SizedBox(width: 4),
                      Text(
                        'متأخرة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                )
              else if (task.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accent),
                  ),
                  child: const Text(
                    'مكتملة ✓',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Footer: Assigned to + Date range (من - إلى) + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Assigned Partner Chip
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: assignedColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 12, color: assignedColor),
                        const SizedBox(width: 4),
                        Text(
                          task.assignedToName,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: assignedColor),
                        ),
                      ],
                    ),
                  ),
                  if (task.priority == 'urgent') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('عاجلة ⚡', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.danger)),
                    ),
                  ],
                ],
              ),

              // Dates: From - To
              Row(
                children: [
                  const Icon(Icons.date_range_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'من $startDateStr إلى $dueDateStr',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: task.isOverdue ? AppColors.danger : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete Button (Admin)
                  if (currentUser?.isAdmin ?? false)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'حذف المهمة',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تأكيد حذف المهمة'),
                            content: Text('هل أنت متأكد من حذف مهمة "${task.title}"؟'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('حذف', style: TextStyle(color: AppColors.danger)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await ref.read(taskRepositoryProvider).deleteTask(
                                task: task,
                                actorId: currentUser?.id ?? '',
                                actorName: currentUser?.name ?? 'المدير',
                              );
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
