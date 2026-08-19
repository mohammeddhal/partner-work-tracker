import 'package:cloud_firestore/cloud_firestore.dart';
import 'work_session_status.dart';

class WorkSessionModel {
  final String id;
  final String userId;
  final String userName;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final String dateKey; // YYYY-MM-DD
  final String monthKey; // YYYY-MM
  final WorkSessionStatus status;
  final bool isManual;
  final String? editReason;
  final String? lastEditedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkSessionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    required this.dateKey,
    required this.monthKey,
    required this.status,
    this.isManual = false,
    this.editReason,
    this.lastEditedBy,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == WorkSessionStatus.active;
  bool get isCompleted => status == WorkSessionStatus.completed;
  bool get needsReview => status == WorkSessionStatus.needsReview;

  WorkSessionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? dateKey,
    String? monthKey,
    WorkSessionStatus? status,
    bool? isManual,
    String? editReason,
    String? lastEditedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      dateKey: dateKey ?? this.dateKey,
      monthKey: monthKey ?? this.monthKey,
      status: status ?? this.status,
      isManual: isManual ?? this.isManual,
      editReason: editReason ?? this.editReason,
      lastEditedBy: lastEditedBy ?? this.lastEditedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
      'dateKey': dateKey,
      'monthKey': monthKey,
      'status': status.toValue(),
      'isManual': isManual,
      'editReason': editReason,
      'lastEditedBy': lastEditedBy,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory WorkSessionModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return WorkSessionModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      startTime: parseTimestamp(map['startTime']),
      endTime: map['endTime'] != null ? parseTimestamp(map['endTime']) : null,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      dateKey: map['dateKey'] as String? ?? '',
      monthKey: map['monthKey'] as String? ?? '',
      status: WorkSessionStatus.fromString(map['status'] as String?),
      isManual: map['isManual'] as bool? ?? false,
      editReason: map['editReason'] as String?,
      lastEditedBy: map['lastEditedBy'] as String?,
      createdAt: map['createdAt'] != null ? parseTimestamp(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? parseTimestamp(map['updatedAt']) : null,
    );
  }
}
