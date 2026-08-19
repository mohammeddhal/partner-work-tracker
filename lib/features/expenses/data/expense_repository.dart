import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../admin/data/audit_log_repository.dart';
import '../../admin/domain/audit_log_model.dart';
import '../domain/expense_model.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(
    firestore: FirebaseFirestore.instance,
    auditLogRepo: ref.watch(auditLogRepositoryProvider),
  );
});

final expensesForMonthProvider = StreamProvider.family<List<ExpenseModel>, String>((ref, monthKey) {
  return ref.watch(expenseRepositoryProvider).watchExpensesForMonth(monthKey);
});

class ExpenseRepository {
  final FirebaseFirestore firestore;
  final AuditLogRepository auditLogRepo;
  final _uuid = const Uuid();

  ExpenseRepository({
    required this.firestore,
    required this.auditLogRepo,
  });

  CollectionReference<Map<String, dynamic>> get _expensesCol =>
      firestore.collection('expenses');

  Stream<List<ExpenseModel>> watchExpensesForMonth(String monthKey) {
    return _expensesCol
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => ExpenseModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required String buyerId,
    required String buyerName,
    String? notes,
    required String actorId,
    required String actorName,
  }) async {
    final expenseId = _uuid.v4();
    final dateKey = DateTimeFormatter.toDateKey(date);
    final monthKey = DateTimeFormatter.toMonthKey(date);

    final expense = ExpenseModel(
      id: expenseId,
      title: title.trim(),
      amount: amount,
      date: date,
      dateKey: dateKey,
      monthKey: monthKey,
      buyerId: buyerId,
      buyerName: buyerName,
      notes: notes?.trim(),
      createdAt: DateTime.now(),
    );

    await _expensesCol.doc(expenseId).set(expense.toMap());

    // Audit Log
    await auditLogRepo.log(
      action: AuditAction.editSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: buyerId,
      targetUserName: buyerName,
      details: 'إضافة فاتورة/مشتريات: $title بمبلغ $amount ر.س (المشتري: $buyerName)',
    );
  }

  Future<void> deleteExpense({
    required ExpenseModel expense,
    required String actorId,
    required String actorName,
  }) async {
    await _expensesCol.doc(expense.id).delete();

    // Audit Log
    await auditLogRepo.log(
      action: AuditAction.deleteSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: expense.buyerId,
      targetUserName: expense.buyerName,
      details: 'حذف فاتورة: ${expense.title} بمبلغ ${expense.amount} ر.س',
    );
  }
}
