import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/user_model.dart';
import '../../data/audit_log_repository.dart';
import '../../domain/audit_log_model.dart';

class EditPartnerDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const EditPartnerDialog({super.key, required this.user});

  @override
  ConsumerState<EditPartnerDialog> createState() => _EditPartnerDialogState();
}

class _EditPartnerDialogState extends ConsumerState<EditPartnerDialog> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late TextEditingController _daysPerWeekController;
  late TextEditingController _capController;
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final reqMins = widget.user.requiredDailyMinutes;
    _hoursController = TextEditingController(text: (reqMins ~/ 60).toString());
    _minutesController = TextEditingController(text: (reqMins % 60).toString());
    _daysPerWeekController = TextEditingController(text: widget.user.workingDaysPerWeek.toString());
    _capController = TextEditingController(text: widget.user.dailyPointsCap?.toString() ?? '');
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _daysPerWeekController.dispose();
    _capController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        '${AppStrings.editPartnerSettings} (${widget.user.name})',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ساعات العمل اليومية المطلوبة:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الساعات',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'الدقائق',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'أيام العمل في الأسبوع:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _daysPerWeekController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '5',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'سقف النقاط اليومي (اختياري، اتركه فارغاً ليكون بدون حد):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _capController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'مثال: 150 (بدون حد افتراضياً)',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              AppStrings.editReasonLabel,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                hintText: 'مثال: تعديل الاتفاقية أو المهام...',
                hintStyle: TextStyle(fontSize: 12),
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
          width: 130,
          child: AppButton(
            text: AppStrings.saveChanges,
            isLoading: _isLoading,
            height: 42,
            onPressed: () async {
              if (_reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يجب كتابة سبب التعديل لتسجيله في Audit Log.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              final h = int.tryParse(_hoursController.text.trim()) ?? 0;
              final m = int.tryParse(_minutesController.text.trim()) ?? 0;
              final totalMinutes = (h * 60) + m;
              final days = int.tryParse(_daysPerWeekController.text.trim()) ?? 5;
              final cap = int.tryParse(_capController.text.trim());

              if (totalMinutes <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('الساعات المطلوبة يجب أن تكون أكبر من صفر.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              setState(() => _isLoading = true);
              try {
                final updatedUser = widget.user.copyWith(
                  requiredDailyMinutes: totalMinutes,
                  workingDaysPerWeek: days,
                  dailyPointsCap: cap,
                );

                await ref.read(authRepositoryProvider).updateUser(updatedUser);

                await ref.read(auditLogRepositoryProvider).log(
                      action: AuditAction.updateUserSettings,
                      actorId: currentUser?.id ?? '',
                      actorName: currentUser?.name ?? 'المدير',
                      targetUserId: widget.user.id,
                      targetUserName: widget.user.name,
                      details: 'تعديل الساعات المطلوبة لـ (${widget.user.name}) إلى $totalMinutes دقيقة ($h س $m د)، وأيام العمل: $days',
                      reason: _reasonController.text.trim(),
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث إعدادات الشريك بنجاح!'), backgroundColor: AppColors.accent),
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
