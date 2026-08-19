import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/domain/user_role.dart';
import '../../data/expense_repository.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateTextController = TextEditingController(text: DateTimeFormatter.toDateKey(DateTime.now()));
  final _notesController = TextEditingController();
  String? _selectedBuyerId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateTextController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = ref.watch(allUsersProvider).value ?? [];
    final currentUser = ref.watch(currentUserProvider).value;

    if (_selectedBuyerId == null && allUsers.isNotEmpty) {
      _selectedBuyerId = currentUser?.id ?? allUsers.first.id;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: AppColors.primaryLight),
          SizedBox(width: 8),
          Text(
            'إضافة فاتورة / مشتريات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Service / Item Name
            const Text('اسم الخدمة أو السلعة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'مثال: اشتراك برنامج، أدوات مكتبية...',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Amount
            const Text('السعر / المبلغ:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: '0.00',
                suffixText: 'ر.س',
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Date (Manual Text + Calendar Picker button)
            const Text('التاريخ (يدوي أو من التقويم):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateTextController,
                    decoration: const InputDecoration(
                      hintText: 'YYYY-MM-DD',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onChanged: (val) {
                      try {
                        _selectedDate = DateTimeFormatter.fromDateKey(val.trim());
                      } catch (_) {}
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryLight.withAlpha(30),
                    foregroundColor: AppColors.primaryLight,
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  tooltip: 'اختيار من التقويم',
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2025),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        _dateTextController.text = DateTimeFormatter.toDateKey(picked);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Buyer Partner Selector
            const Text('الشخص الذي اشترى / دفع:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedBuyerId,
              items: allUsers.map((u) {
                return DropdownMenuItem(value: u.id, child: Text(u.name));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedBuyerId = val);
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Notes (Optional)
            const Text('ملاحظات (اختياري):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'رقم الفاتورة، تفاصيل إضافية...',
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
            text: 'حفظ الفاتورة',
            isLoading: _isLoading,
            height: 42,
            onPressed: () async {
              final title = _titleController.text.trim();
              final amountStr = _amountController.text.trim();

              if (title.isEmpty || amountStr.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى إدخال اسم السلعة والمبلغ.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              final amount = double.tryParse(amountStr);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('المبلغ يجب أن يكون رقماً صحيحاً وأكبر من الصفر.'),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              try {
                _selectedDate = DateTimeFormatter.fromDateKey(_dateTextController.text.trim());
              } catch (_) {
                _selectedDate = DateTime.now();
              }

              final buyer = allUsers.firstWhere(
                (u) => u.id == _selectedBuyerId,
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
                await ref.read(expenseRepositoryProvider).addExpense(
                      title: title,
                      amount: amount,
                      date: _selectedDate,
                      buyerId: buyer.id,
                      buyerName: buyer.name,
                      notes: _notesController.text,
                      actorId: currentUser?.id ?? '',
                      actorName: currentUser?.name ?? 'المستخدم',
                    );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تمت إضافة الفاتورة بنجاح!'),
                      backgroundColor: AppColors.accent,
                    ),
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
