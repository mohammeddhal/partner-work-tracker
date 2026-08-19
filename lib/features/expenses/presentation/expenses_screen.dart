import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/data/auth_repository.dart';
import '../data/expense_repository.dart';
import '../domain/expense_model.dart';
import 'widgets/add_expense_dialog.dart';

final selectedExpenseMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedExpenseMonthProvider);
    final monthKey = DateTimeFormatter.toMonthKey(selectedDate);
    final monthName = DateTimeFormatter.formatArabicMonthYear(monthKey);
    final currentUser = ref.watch(currentUserProvider).value;

    final expensesAsync = ref.watch(expensesForMonthProvider(monthKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير والمشتريات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primaryLight, size: 28),
            tooltip: 'إضافة فاتورة جديدة',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddExpenseDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),

          // Month Switcher Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () {
                    ref.read(selectedExpenseMonthProvider.notifier).state =
                        DateTime(selectedDate.year, selectedDate.month - 1);
                  },
                ),
                Text(
                  monthName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () {
                    ref.read(selectedExpenseMonthProvider.notifier).state =
                        DateTime(selectedDate.year, selectedDate.month + 1);
                  },
                ),
              ],
            ),
          ),

          // Expenses Content
          Expanded(
            child: expensesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ في تحميل الفواتير: $e')),
              data: (expenses) {
                // Compute totals
                double totalAmount = 0;
                final buyerTotals = <String, double>{};

                for (final e in expenses) {
                  totalAmount += e.amount;
                  buyerTotals[e.buyerName] = (buyerTotals[e.buyerName] ?? 0) + e.amount;
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Top Summary Card
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet_outlined, size: 20, color: AppColors.primaryLight),
                              SizedBox(width: 8),
                              Text(
                                'إجمالي مصروفات ومشتريات الشهر',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${totalAmount.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // Breakdown per partner
                          if (buyerTotals.isEmpty)
                            const Text('لا توجد مشتريات مسجلة لهذا الشهر.', style: TextStyle(fontSize: 12, color: Colors.grey))
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: buyerTotals.entries.map((entry) {
                                final isMohammad = entry.key.contains('محمد');
                                final color = isMohammad ? AppColors.partner1 : AppColors.partner2;

                                return Column(
                                  children: [
                                    Text(
                                      'مدفوعات ${entry.key}:',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${entry.value.toStringAsFixed(2)} ر.س',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'سجل الفواتير والمشتريات:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text(
                                'لا توجد فواتير أو مشتريات مسجلة في هذا الشهر.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...expenses.map((expense) => _buildExpenseItem(context, ref, expense, currentUser?.isAdmin ?? false)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة فاتورة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddExpenseDialog(),
          );
        },
      ),
    );
  }

  Widget _buildExpenseItem(BuildContext context, WidgetRef ref, ExpenseModel expense, bool isAdmin) {
    final isMohammad = expense.buyerName.contains('محمد');
    final buyerColor = isMohammad ? AppColors.partner1 : AppColors.partner2;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buyerColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_bag_outlined, color: buyerColor, size: 20),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: buyerColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expense.buyerName,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: buyerColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateTimeFormatter.formatArabicShortDate(expense.date),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    expense.notes!,
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${expense.amount.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: AppColors.primaryLight,
                ),
              ),
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'حذف الفاتورة',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: Text('هل أنت متأكد من حذف فاتورة "${expense.title}"؟'),
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
                      final currentUser = ref.read(currentUserProvider).value;
                      await ref.read(expenseRepositoryProvider).deleteExpense(
                            expense: expense,
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
    );
  }
}
