import 'package:flutter_test/flutter_test.dart';
import 'package:partner_work_tracker/features/tasks/domain/task_model.dart';

void main() {
  group('TaskModel & Overdue Logic Tests', () {
    test('Task correctly identifies overdue status based on dueDate', () {
      final now = DateTime.now();

      // 1. Task with past dueDate (Overdue)
      final overdueTask = TaskModel(
        id: 'task_1',
        title: 'مهمة متأخرة',
        assignedToId: 'user_1',
        assignedToName: 'محمد',
        startDate: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 1)),
        isCompleted: false,
      );
      expect(overdueTask.isOverdue, true);

      // 2. Task with past dueDate but isCompleted = true (Not Overdue)
      final completedTask = TaskModel(
        id: 'task_2',
        title: 'مهمة مكتملة في الموعد',
        assignedToId: 'user_1',
        assignedToName: 'محمد',
        startDate: now.subtract(const Duration(days: 5)),
        dueDate: now.subtract(const Duration(days: 1)),
        isCompleted: true,
      );
      expect(completedTask.isOverdue, false);

      // 3. Task with future dueDate (Not Overdue / In Progress)
      final futureTask = TaskModel(
        id: 'task_3',
        title: 'مهمة جارية',
        assignedToId: 'user_2',
        assignedToName: 'مسعود',
        startDate: now,
        dueDate: now.add(const Duration(days: 3)),
        isCompleted: false,
      );
      expect(futureTask.isOverdue, false);
    });
  });
}
