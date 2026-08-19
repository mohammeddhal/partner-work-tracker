import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title; // عنوان المهمة
  final String? description; // التفاصيل
  final String assignedToId; // معرف الشريك
  final String assignedToName; // اسم الشريك (محمد / مسعود)
  final DateTime startDate; // من تاريخ
  final DateTime dueDate; // إلى تاريخ
  final bool isCompleted; // هل تم الإنجاز
  final DateTime? completedAt;
  final String priority; // 'normal' | 'urgent'
  final DateTime? createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.assignedToId,
    required this.assignedToName,
    required this.startDate,
    required this.dueDate,
    this.isCompleted = false,
    this.completedAt,
    this.priority = 'normal',
    this.createdAt,
  });

  /// Automatically marks as overdue if current time passed dueDate and not completed
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return now.isAfter(dueDate);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedToId': assignedToId,
      'assignedToName': assignedToName,
      'startDate': Timestamp.fromDate(startDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'priority': priority,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return TaskModel(
      id: documentId,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      assignedToId: map['assignedToId'] as String? ?? '',
      assignedToName: map['assignedToName'] as String? ?? '',
      startDate: parseTimestamp(map['startDate']),
      dueDate: parseTimestamp(map['dueDate']),
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: map['completedAt'] != null ? parseTimestamp(map['completedAt']) : null,
      priority: map['priority'] as String? ?? 'normal',
      createdAt: map['createdAt'] != null ? parseTimestamp(map['createdAt']) : null,
    );
  }
}
