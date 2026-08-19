import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/domain/user_role.dart';
import '../../data/task_repository.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  const AddTaskDialog({super.key});

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedAssignedId;
  DateTime _startDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));
  String _priority = 'normal';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final currentUser = ref.watch(currentUserProvider).value;

    if (_selectedAssignedId == null && allUsers.isNotEmpty) {
      _selectedAssignedId = currentUser?.id ?? allUsers.first.id;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.add_task_rounded, color: AppColors.primaryLight),
          SizedBox(width: 8),
          Text(
            'إنشاء مهمة جديدة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Title
            const Text('عنوان المهمة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'مثال: تسليم التقرير المالي، مراجعة العقد...',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Assigned Partner
            const Text('الشخص المكلف بالمهمة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedAssignedId,
              items: allUsers.map((u) {
                return DropdownMenuItem(value: u.id, child: Text(u.name));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedAssignedId = val);
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Date Range (From - To)
            Row(
              children: [
                // Start Date (من)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تاريخ البدء (من):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(2025),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _startDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateTimeFormatter.formatArabicShortDate(_startDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primaryLight),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Due Date (إلى)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تاريخ الانتهاء (إلى):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate,
                            firstDate: _startDate,
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _dueDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(DateTimeFormatter.formatArabicShortDate(_dueDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              const Icon(Icons.event_busy_rounded, size: 16, color: AppColors.danger),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Priority
            const Text('الأولوية:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('عادية'),
                  selected: _priority == 'normal',
                  onSelected: (selected) {
                    if (selected) setState(() => _priority = 'normal');
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('عاجلة ⚡'),
                  selected: _priority == 'urgent',
                  selectedColor: AppColors.danger.withAlpha(40),
                  onSelected: (selected) {
                    if (selected) setState(() => _priority = 'urgent');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Description (Optional)
            const Text('التفاصيل / ملاحظات:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'وصف المهمة والمطلوب تنفيذه...',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              maxLines: 2,
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
          width: 120,
          child: AppButton(
            text: 'إنشاء المهمة',
            isLoading: _isLoading,
            height: 42,
            onPressed: () async {
              final title = _titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال عنوان المهمة.'), backgroundColor: AppColors.danger),
                );
                return;
              }

              final assignedUser = allUsers.firstWhere(
                (u) => u.id == _selectedAssignedId,
                orElse: () => currentUser ?? UserModel(
                  id: 'unknown',
                  name: 'الشريك',
                  email: '',
                  role: UserRole.partner,
                  requiredDailyMinutes: 120,
                  effectiveStartDate: DateTime.now(),
                ),
              );

              setState(() => _isLoading = true);
              try {
                await ref.read(taskRepositoryProvider).addTask(
                      title: title,
                      description: _descriptionController.text,
                      assignedToId: assignedUser.id,
                      assignedToName: assignedUser.name,
                      startDate: _startDate,
                      dueDate: _dueDate,
                      priority: _priority,
                      actorId: currentUser?.id ?? '',
                      actorName: currentUser?.name ?? 'المستخدم',
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة المهمة بنجاح!'), backgroundColor: AppColors.accent),
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
