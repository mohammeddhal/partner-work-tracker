import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/domain/user_role.dart';
import '../../../tracker/data/work_session_repository.dart';
import '../../../tracker/domain/work_session_model.dart';

class ManualSessionDialog extends ConsumerStatefulWidget {
  final WorkSessionModel? sessionToEdit;

  const ManualSessionDialog({super.key, this.sessionToEdit});

  @override
  ConsumerState<ManualSessionDialog> createState() => _ManualSessionDialogState();
}

class _ManualSessionDialogState extends ConsumerState<ManualSessionDialog> {
  late String? _selectedUserId;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sessionToEdit != null) {
      final s = widget.sessionToEdit!;
      _selectedUserId = s.userId;
      _selectedDate = s.startTime;
      _startTime = TimeOfDay.fromDateTime(s.startTime);
      _endTime = TimeOfDay.fromDateTime(s.endTime ?? s.startTime.add(Duration(minutes: s.durationMinutes)));
      _reasonController.text = s.editReason ?? '';
    } else {
      _selectedUserId = null;
      _selectedDate = DateTime.now();
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 11, minute: 0);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final currentUser = ref.watch(currentUserProvider).value;
    final isEditing = widget.sessionToEdit != null;

    if (_selectedUserId == null && allUsers.isNotEmpty) {
      _selectedUserId = allUsers.first.id;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        isEditing ? AppStrings.editSession : AppStrings.addManualSession,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Select Partner (if adding new)
            if (!isEditing) ...[
              const Text('الشريك:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedUserId,
                items: allUsers.map((u) {
                  return DropdownMenuItem(value: u.id, child: Text(u.name));
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedUserId = val);
                },
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              ),
              const SizedBox(height: 16),
            ],

            // Date Picker
            const Text('التاريخ:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2025),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateTimeFormatter.toDateKey(_selectedDate)),
                    const Icon(Icons.calendar_month_outlined, size: 20, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time Pickers (Start & End)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('وقت البدء:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (picked != null) setState(() => _startTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('وقت الانتهاء:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (picked != null) setState(() => _endTime = picked);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(_endTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mandatory Reason Field
            const Text(
              AppStrings.editReasonLabel,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: AppStrings.editReasonHint,
                hintStyle: TextStyle(fontSize: 12),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        if (isEditing)
          TextButton(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_reasonController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يجب كتابة سبب الحذف لتسجيله في Audit Log.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }
                    setState(() => _isLoading = true);
                    try {
                      final selectedUser = allUsers.firstWhere((u) => u.id == _selectedUserId);
                      await ref.read(workSessionRepositoryProvider).deleteSession(
                            session: widget.sessionToEdit!,
                            actorId: currentUser?.id ?? '',
                            actorName: currentUser?.name ?? 'المدير',
                            reason: _reasonController.text.trim(),
                            requiredMinutes: selectedUser.requiredDailyMinutes,
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم حذف الجلسة بنجاح'), backgroundColor: AppColors.accent),
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
            child: const Text(AppStrings.deleteSession, style: TextStyle(color: AppColors.danger)),
          ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(AppStrings.cancel),
        ),
        SizedBox(
          width: 120,
          child: AppButton(
            text: AppStrings.confirm,
            isLoading: _isLoading,
            height: 42,
            onPressed: () async {
              if (_reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يجب كتابة سبب التعديل/الإضافة لتسجيله في Audit Log.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              final startDateTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _startTime.hour,
                _startTime.minute,
              );

              final endDateTime = DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _endTime.hour,
                _endTime.minute,
              );

              if (endDateTime.isBefore(startDateTime)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('وقت الانتهاء يجب أن يكون بعد وقت البدء.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);
              try {
                final targetUser = allUsers.firstWhere(
                  (u) => u.id == _selectedUserId,
                  orElse: () => UserModel(
                    id: _selectedUserId ?? 'unknown',
                    name: 'الشريك',
                    email: '',
                    role: UserRole.partner,
                    requiredDailyMinutes: 120,
                    effectiveStartDate: DateTime.now(),
                  ),
                );

                if (isEditing) {
                  await ref.read(workSessionRepositoryProvider).editSession(
                        originalSession: widget.sessionToEdit!,
                        newStartTime: startDateTime,
                        newEndTime: endDateTime,
                        actorId: currentUser?.id ?? '',
                        actorName: currentUser?.name ?? 'المدير',
                        reason: _reasonController.text.trim(),
                        requiredMinutes: targetUser.requiredDailyMinutes,
                      );
                } else {
                  await ref.read(workSessionRepositoryProvider).addManualSession(
                        userId: targetUser.id,
                        userName: targetUser.name,
                        startTime: startDateTime,
                        endTime: endDateTime,
                        actorId: currentUser?.id ?? '',
                        actorName: currentUser?.name ?? 'المدير',
                        reason: _reasonController.text.trim(),
                        requiredMinutes: targetUser.requiredDailyMinutes,
                      );
                }

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ العملية بنجاح وتسجيلها في Audit Log'), backgroundColor: AppColors.accent),
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
