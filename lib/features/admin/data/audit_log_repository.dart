import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/audit_log_model.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  return AuditLogRepository(firestore: FirebaseFirestore.instance);
});

final auditLogsProvider = StreamProvider<List<AuditLogModel>>((ref) {
  return ref.watch(auditLogRepositoryProvider).watchAuditLogs();
});

class AuditLogRepository {
  final FirebaseFirestore firestore;
  final _uuid = const Uuid();

  AuditLogRepository({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _logsCol =>
      firestore.collection('auditLogs');

  Stream<List<AuditLogModel>> watchAuditLogs({int limit = 50}) {
    return _logsCol
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AuditLogModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> log({
    required AuditAction action,
    required String actorId,
    required String actorName,
    String? targetUserId,
    String? targetUserName,
    required String details,
    String? reason,
  }) async {
    try {
      final logId = _uuid.v4();
      final logItem = AuditLogModel(
        id: logId,
        action: action,
        actorId: actorId,
        actorName: actorName,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        details: details,
        reason: reason,
        timestamp: DateTime.now(),
      );

      final map = logItem.toMap();
      map['timestamp'] = FieldValue.serverTimestamp();
      await _logsCol.doc(logId).set(map);
    } catch (_) {
      // Keep silent if network is currently offline, Firestore will queue locally
    }
  }
}
