import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditAction {
  login,
  clockIn,
  clockOut,
  editSession,
  deleteSession,
  addManualSession,
  updateUserSettings,
  closeMonth,
  reopenMonth;

  static AuditAction fromString(String? action) {
    switch (action) {
      case 'login':
        return AuditAction.login;
      case 'clock_in':
        return AuditAction.clockIn;
      case 'clock_out':
        return AuditAction.clockOut;
      case 'edit_session':
        return AuditAction.editSession;
      case 'delete_session':
        return AuditAction.deleteSession;
      case 'add_manual_session':
        return AuditAction.addManualSession;
      case 'update_user_settings':
        return AuditAction.updateUserSettings;
      case 'close_month':
        return AuditAction.closeMonth;
      case 'reopen_month':
        return AuditAction.reopenMonth;
      default:
        return AuditAction.editSession;
    }
  }

  String toValue() {
    switch (this) {
      case AuditAction.login:
        return 'login';
      case AuditAction.clockIn:
        return 'clock_in';
      case AuditAction.clockOut:
        return 'clock_out';
      case AuditAction.editSession:
        return 'edit_session';
      case AuditAction.deleteSession:
        return 'delete_session';
      case AuditAction.addManualSession:
        return 'add_manual_session';
      case AuditAction.updateUserSettings:
        return 'update_user_settings';
      case AuditAction.closeMonth:
        return 'close_month';
      case AuditAction.reopenMonth:
        return 'reopen_month';
    }
  }

  String get displayNameArabic {
    switch (this) {
      case AuditAction.login:
        return 'تسجيل الدخول';
      case AuditAction.clockIn:
        return 'بدء جلسة عمل';
      case AuditAction.clockOut:
        return 'إنهاء جلسة عمل';
      case AuditAction.editSession:
        return 'تعديل جلسة عمل';
      case AuditAction.deleteSession:
        return 'حذف جلسة عمل';
      case AuditAction.addManualSession:
        return 'إضافة جلسة يدوية';
      case AuditAction.updateUserSettings:
        return 'تعديل إعدادات الشريك';
      case AuditAction.closeMonth:
        return 'إغلاق الشهر واعتماد التقرير';
      case AuditAction.reopenMonth:
        return 'إعادة فتح الشهر';
    }
  }
}

class AuditLogModel {
  final String id;
  final AuditAction action;
  final String actorId;
  final String actorName;
  final String? targetUserId;
  final String? targetUserName;
  final String details;
  final String? reason;
  final DateTime timestamp;

  const AuditLogModel({
    required this.id,
    required this.action,
    required this.actorId,
    required this.actorName,
    this.targetUserId,
    this.targetUserName,
    required this.details,
    this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action.toValue(),
      'actorId': actorId,
      'actorName': actorName,
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'details': details,
      'reason': reason,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return AuditLogModel(
      id: documentId,
      action: AuditAction.fromString(map['action'] as String?),
      actorId: map['actorId'] as String? ?? '',
      actorName: map['actorName'] as String? ?? 'مجهول',
      targetUserId: map['targetUserId'] as String?,
      targetUserName: map['targetUserName'] as String?,
      details: map['details'] as String? ?? '',
      reason: map['reason'] as String?,
      timestamp: parseTimestamp(map['timestamp']),
    );
  }
}
