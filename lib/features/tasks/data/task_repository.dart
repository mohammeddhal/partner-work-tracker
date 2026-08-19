import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/notification_service.dart';
import '../../admin/data/audit_log_repository.dart';
import '../../admin/domain/audit_log_model.dart';
import '../domain/task_model.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    firestore: FirebaseFirestore.instance,
    auditLogRepo: ref.watch(auditLogRepositoryProvider),
  );
});

final allTasksProvider = StreamProvider<List<TaskModel>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAllTasks();
});

class TaskRepository {
  final FirebaseFirestore firestore;
  final AuditLogRepository auditLogRepo;
  final _uuid = const Uuid();

  TaskRepository({
    required this.firestore,
    required this.auditLogRepo,
  });

  CollectionReference<Map<String, dynamic>> get _tasksCol =>
      firestore.collection('tasks');

  Stream<List<TaskModel>> watchAllTasks() {
    return _tasksCol
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();

      // Check for overdue tasks to trigger notification
      final overdueCount = list.where((t) => t.isOverdue).length;
      if (overdueCount > 0) {
        NotificationService().showOverdueTaskWarning(overdueCount);
      }

      return list;
    });
  }

  Future<void> addTask({
    required String title,
    String? description,
    required String assignedToId,
    required String assignedToName,
    required DateTime startDate,
    required DateTime dueDate,
    String priority = 'normal',
    required String actorId,
    required String actorName,
  }) async {
    final taskId = _uuid.v4();

    final task = TaskModel(
      id: taskId,
      title: title.trim(),
      description: description?.trim(),
      assignedToId: assignedToId,
      assignedToName: assignedToName,
      startDate: startDate,
      dueDate: dueDate,
      isCompleted: false,
      priority: priority,
      createdAt: DateTime.now(),
    );

    await _tasksCol.doc(taskId).set(task.toMap());

    // Audit Log
    await auditLogRepo.log(
      action: AuditAction.addManualSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: assignedToId,
      targetUserName: assignedToName,
      details: 'إنشاء مهمة جديدة: "$title" مسندة إلى $assignedToName',
    );
  }

  Future<void> toggleTaskCompleted({
    required TaskModel task,
    required String actorId,
    required String actorName,
  }) async {
    final newStatus = !task.isCompleted;
    await _tasksCol.doc(task.id).update({
      'isCompleted': newStatus,
      'completedAt': newStatus ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Audit Log
    await auditLogRepo.log(
      action: AuditAction.editSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: task.assignedToId,
      targetUserName: task.assignedToName,
      details: newStatus
          ? 'تم إنجاز المهمة: "${task.title}"'
          : 'إعادة فتح المهمة: "${task.title}"',
    );
  }

  Future<void> deleteTask({
    required TaskModel task,
    required String actorId,
    required String actorName,
  }) async {
    await _tasksCol.doc(task.id).delete();

    // Audit Log
    await auditLogRepo.log(
      action: AuditAction.deleteSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: task.assignedToId,
      targetUserName: task.assignedToName,
      details: 'حذف المهمة: "${task.title}"',
    );
  }
}
