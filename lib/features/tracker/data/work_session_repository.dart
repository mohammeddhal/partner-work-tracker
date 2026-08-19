import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/utils/points_calculator.dart';
import '../../admin/data/audit_log_repository.dart';
import '../../admin/domain/audit_log_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../history/domain/daily_summary_model.dart';
import '../domain/work_session_model.dart';
import '../domain/work_session_status.dart';

final workSessionRepositoryProvider = Provider<WorkSessionRepository>((ref) {
  return WorkSessionRepository(
    firestore: FirebaseFirestore.instance,
    auditLogRepo: ref.watch(auditLogRepositoryProvider),
  );
});

final activeSessionProvider = StreamProvider<WorkSessionModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(workSessionRepositoryProvider).watchActiveSession(user.id);
});

final todaySessionsProvider = StreamProvider<List<WorkSessionModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  final todayKey = DateTimeFormatter.toDateKey(DateTime.now());
  return ref.watch(workSessionRepositoryProvider).watchSessionsForDate(user.id, todayKey);
});

class WorkSessionRepository {
  final FirebaseFirestore firestore;
  final AuditLogRepository auditLogRepo;
  final _uuid = const Uuid();

  WorkSessionRepository({
    required this.firestore,
    required this.auditLogRepo,
  });

  CollectionReference<Map<String, dynamic>> get _sessionsCol =>
      firestore.collection('workSessions');

  CollectionReference<Map<String, dynamic>> get _dailySummariesCol =>
      firestore.collection('dailySummaries');

  /// Stream of active session for a specific user
  Stream<WorkSessionModel?> watchActiveSession(String userId) {
    return _sessionsCol
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: WorkSessionStatus.active.toValue())
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return WorkSessionModel.fromMap(doc.data(), doc.id);
    });
  }

  /// Stream of sessions for a user on a given date key
  Stream<List<WorkSessionModel>> watchSessionsForDate(String userId, String dateKey) {
    return _sessionsCol
        .where('userId', isEqualTo: userId)
        .where('dateKey', isEqualTo: dateKey)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => WorkSessionModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.startTime.compareTo(a.startTime));
      return list;
    });
  }

  /// Stream of all sessions for a specific month
  Stream<List<WorkSessionModel>> watchSessionsForMonth(String monthKey) {
    return _sessionsCol
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => WorkSessionModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.startTime.compareTo(a.startTime));
      return list;
    });
  }

  /// Starts a new work session with Server Timestamp
  Future<WorkSessionModel> startSession({
    required String userId,
    required String userName,
  }) async {
    // 1. Verify no existing active session
    final activeSnapshot = await _sessionsCol
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: WorkSessionStatus.active.toValue())
        .limit(1)
        .get();

    if (activeSnapshot.docs.isNotEmpty) {
      throw Exception('لديك جلسة عمل نشطة بالفعل. قم بإنهائها أولاً.');
    }

    final now = DateTime.now();
    final dateKey = DateTimeFormatter.toDateKey(now);
    final monthKey = DateTimeFormatter.toMonthKey(now);
    final sessionId = _uuid.v4();

    final session = WorkSessionModel(
      id: sessionId,
      userId: userId,
      userName: userName,
      startTime: now,
      durationMinutes: 0,
      dateKey: dateKey,
      monthKey: monthKey,
      status: WorkSessionStatus.active,
      createdAt: now,
    );

    // Save to Firestore with Server Timestamp
    final map = session.toMap();
    map['startTime'] = FieldValue.serverTimestamp();
    await _sessionsCol.doc(sessionId).set(map);

    // Log Audit
    await auditLogRepo.log(
      action: AuditAction.clockIn,
      actorId: userId,
      actorName: userName,
      targetUserId: userId,
      targetUserName: userName,
      details: 'بدء جلسة عمل جديدة في $dateKey',
    );

    return session;
  }

  /// Ends an active session, computes duration, and recalculates DailySummary
  Future<void> endSession({
    required WorkSessionModel activeSession,
    required int requiredDailyMinutes,
    int? dailyPointsCap,
  }) async {
    final now = DateTime.now();
    final endTime = now;
    final start = activeSession.startTime;

    // Compute exact minutes
    final durationSeconds = endTime.difference(start).inSeconds;
    final durationMinutes = (durationSeconds / 60).round().clamp(1, 1440);

    // Check if session exceeded midnight or unusually long (> 16 hours)
    final needsReview = durationMinutes > 960;
    final newStatus = needsReview ? WorkSessionStatus.needsReview : WorkSessionStatus.completed;

    await _sessionsCol.doc(activeSession.id).update({
      'endTime': FieldValue.serverTimestamp(),
      'durationMinutes': durationMinutes,
      'status': newStatus.toValue(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Recompute Daily Summary
    await recalculateDailySummary(
      userId: activeSession.userId,
      userName: activeSession.userName,
      dateKey: activeSession.dateKey,
      monthKey: activeSession.monthKey,
      requiredMinutes: requiredDailyMinutes,
      pointsCap: dailyPointsCap,
    );

    // Log Audit
    await auditLogRepo.log(
      action: AuditAction.clockOut,
      actorId: activeSession.userId,
      actorName: activeSession.userName,
      targetUserId: activeSession.userId,
      targetUserName: activeSession.userName,
      details: 'إنهاء جلسة العمل، المدة: $durationMinutes دقيقة',
    );
  }

  /// Recalculates DailySummary for a specific user and date
  Future<void> recalculateDailySummary({
    required String userId,
    required String userName,
    required String dateKey,
    required String monthKey,
    required int requiredMinutes,
    int? pointsCap,
  }) async {
    final summaryId = '${userId}_$dateKey';

    // Fetch all completed/review sessions for this day
    final snapshot = await _sessionsCol
        .where('userId', isEqualTo: userId)
        .where('dateKey', isEqualTo: dateKey)
        .get();

    final sessions = snapshot.docs
        .map((d) => WorkSessionModel.fromMap(d.data(), d.id))
        .where((s) => s.isCompleted || s.needsReview)
        .toList();

    int totalWorkedMinutes = 0;
    DateTime? firstCheckIn;
    DateTime? lastCheckOut;

    for (final s in sessions) {
      totalWorkedMinutes += s.durationMinutes;
      if (firstCheckIn == null || s.startTime.isBefore(firstCheckIn)) {
        firstCheckIn = s.startTime;
      }
      if (s.endTime != null) {
        if (lastCheckOut == null || s.endTime!.isAfter(lastCheckOut)) {
          lastCheckOut = s.endTime;
        }
      }
    }

    final points = PointsCalculator.calculateDailyPoints(
      actualWorkedMinutes: totalWorkedMinutes,
      requiredDailyMinutes: requiredMinutes,
      pointsCap: pointsCap,
    );

    final achievement = PointsCalculator.calculateAchievementPercentage(
      actualWorkedMinutes: totalWorkedMinutes,
      requiredDailyMinutes: requiredMinutes,
    );

    final difference = PointsCalculator.calculateDifferenceMinutes(
      actualWorkedMinutes: totalWorkedMinutes,
      requiredDailyMinutes: requiredMinutes,
    );

    final summary = DailySummaryModel(
      id: summaryId,
      userId: userId,
      userName: userName,
      dateKey: dateKey,
      monthKey: monthKey,
      workedMinutes: totalWorkedMinutes,
      requiredMinutes: requiredMinutes,
      differenceMinutes: difference,
      points: points,
      achievementPercentage: achievement,
      sessionsCount: sessions.length,
      firstCheckIn: firstCheckIn,
      lastCheckOut: lastCheckOut,
      updatedAt: DateTime.now(),
    );

    await _dailySummariesCol.doc(summaryId).set(summary.toMap(), SetOptions(merge: true));
  }

  /// Admin edits a session with mandatory reason
  Future<void> editSession({
    required WorkSessionModel originalSession,
    required DateTime newStartTime,
    required DateTime newEndTime,
    required String actorId,
    required String actorName,
    required String reason,
    required int requiredMinutes,
  }) async {
    if (reason.trim().isEmpty) {
      throw Exception('يجب كتابة سبب التعديل.');
    }

    final durationMinutes = newEndTime.difference(newStartTime).inMinutes.clamp(1, 1440);
    final dateKey = DateTimeFormatter.toDateKey(newStartTime);
    final monthKey = DateTimeFormatter.toMonthKey(newStartTime);

    await _sessionsCol.doc(originalSession.id).update({
      'startTime': Timestamp.fromDate(newStartTime),
      'endTime': Timestamp.fromDate(newEndTime),
      'durationMinutes': durationMinutes,
      'dateKey': dateKey,
      'monthKey': monthKey,
      'status': WorkSessionStatus.completed.toValue(),
      'isManual': true,
      'editReason': reason.trim(),
      'lastEditedBy': actorName,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await recalculateDailySummary(
      userId: originalSession.userId,
      userName: originalSession.userName,
      dateKey: dateKey,
      monthKey: monthKey,
      requiredMinutes: requiredMinutes,
    );

    await auditLogRepo.log(
      action: AuditAction.editSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: originalSession.userId,
      targetUserName: originalSession.userName,
      details: 'تعديل الجلسة (${originalSession.durationMinutes} دقيقة -> $durationMinutes دقيقة)',
      reason: reason.trim(),
    );
  }

  /// Admin adds a manual session
  Future<void> addManualSession({
    required String userId,
    required String userName,
    required DateTime startTime,
    required DateTime endTime,
    required String actorId,
    required String actorName,
    required String reason,
    required int requiredMinutes,
  }) async {
    if (reason.trim().isEmpty) {
      throw Exception('يجب كتابة سبب الإضافة.');
    }

    final durationMinutes = endTime.difference(startTime).inMinutes.clamp(1, 1440);
    final dateKey = DateTimeFormatter.toDateKey(startTime);
    final monthKey = DateTimeFormatter.toMonthKey(startTime);
    final sessionId = _uuid.v4();

    final session = WorkSessionModel(
      id: sessionId,
      userId: userId,
      userName: userName,
      startTime: startTime,
      endTime: endTime,
      durationMinutes: durationMinutes,
      dateKey: dateKey,
      monthKey: monthKey,
      status: WorkSessionStatus.completed,
      isManual: true,
      editReason: reason.trim(),
      lastEditedBy: actorName,
      createdAt: DateTime.now(),
    );

    await _sessionsCol.doc(sessionId).set(session.toMap());

    await recalculateDailySummary(
      userId: userId,
      userName: userName,
      dateKey: dateKey,
      monthKey: monthKey,
      requiredMinutes: requiredMinutes,
    );

    await auditLogRepo.log(
      action: AuditAction.addManualSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: userId,
      targetUserName: userName,
      details: 'إضافة جلسة يدوية بمدة $durationMinutes دقيقة في $dateKey',
      reason: reason.trim(),
    );
  }

  /// Admin deletes an invalid session
  Future<void> deleteSession({
    required WorkSessionModel session,
    required String actorId,
    required String actorName,
    required String reason,
    required int requiredMinutes,
  }) async {
    if (reason.trim().isEmpty) {
      throw Exception('يجب كتابة سبب الحذف.');
    }

    await _sessionsCol.doc(session.id).delete();

    await recalculateDailySummary(
      userId: session.userId,
      userName: session.userName,
      dateKey: session.dateKey,
      monthKey: session.monthKey,
      requiredMinutes: requiredMinutes,
    );

    await auditLogRepo.log(
      action: AuditAction.deleteSession,
      actorId: actorId,
      actorName: actorName,
      targetUserId: session.userId,
      targetUserName: session.userName,
      details: 'حذف جلسة عمل (${session.durationMinutes} دقيقة) لتاريخ ${session.dateKey}',
      reason: reason.trim(),
    );
  }
}
