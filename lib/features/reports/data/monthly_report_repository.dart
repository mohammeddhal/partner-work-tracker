import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/utils/points_calculator.dart';
import '../../admin/data/audit_log_repository.dart';
import '../../admin/domain/audit_log_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../history/data/daily_summary_repository.dart';
import '../../history/domain/daily_summary_model.dart';
import '../domain/monthly_report_model.dart';
import '../domain/partner_summary_model.dart';

final monthlyReportRepositoryProvider = Provider<MonthlyReportRepository>((ref) {
  return MonthlyReportRepository(
    firestore: FirebaseFirestore.instance,
    auditLogRepo: ref.watch(auditLogRepositoryProvider),
  );
});

final selectedMonthKeyProvider = StateProvider<String>((ref) {
  return DateTimeFormatter.toMonthKey(DateTime.now());
});

final monthlyReportStreamProvider = StreamProvider.family<MonthlyReportModel?, String>((ref, monthKey) {
  return ref.watch(monthlyReportRepositoryProvider).watchMonthlyReport(monthKey);
});

final closedReportsProvider = StreamProvider<List<MonthlyReportModel>>((ref) {
  return ref.watch(monthlyReportRepositoryProvider).watchClosedReports();
});

/// Combined provider that returns either the closed snapshot or live calculated report
final liveMonthlyReportProvider = Provider.family<MonthlyReportModel, String>((ref, monthKey) {
  // 1. Check if an official closed report exists in Firestore
  final existingReport = ref.watch(monthlyReportStreamProvider(monthKey)).value;
  if (existingReport != null && existingReport.isClosed) {
    return existingReport;
  }

  // 2. Compute dynamic live report from users and daily summaries
  final users = ref.watch(allUsersProvider).value ?? [];
  final summaries = ref.watch(allMonthSummariesProvider(monthKey)).value ?? [];

  return MonthlyReportRepository.computeMonthlyReport(
    monthKey: monthKey,
    users: users,
    summaries: summaries,
    existingClosedReport: existingReport,
  );
});

class MonthlyReportRepository {
  final FirebaseFirestore firestore;
  final AuditLogRepository auditLogRepo;

  MonthlyReportRepository({
    required this.firestore,
    required this.auditLogRepo,
  });

  CollectionReference<Map<String, dynamic>> get _reportsCol =>
      firestore.collection('monthlyReports');

  Stream<MonthlyReportModel?> watchMonthlyReport(String monthKey) {
    return _reportsCol.doc(monthKey).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return MonthlyReportModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Stream<List<MonthlyReportModel>> watchClosedReports() {
    return _reportsCol
        .where('status', isEqualTo: 'closed')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => MonthlyReportModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.monthKey.compareTo(a.monthKey));
      return list;
    });
  }

  /// Calculates real-time metrics for a month
  static MonthlyReportModel computeMonthlyReport({
    required String monthKey,
    required List<UserModel> users,
    required List<DailySummaryModel> summaries,
    MonthlyReportModel? existingClosedReport,
  }) {
    if (existingClosedReport != null && existingClosedReport.isClosed) {
      return existingClosedReport;
    }

    final date = DateTimeFormatter.fromMonthKey(monthKey);
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final now = DateTime.now();
    final isCurrentMonth = now.year == date.year && now.month == date.month;
    final maxDayToCheck = isCurrentMonth ? now.day : daysInMonth;

    final partnerSummaries = <String, PartnerSummaryModel>{};
    double totalPartnersPoints = 0.0;
    int totalWorkedMinutesAll = 0;

    for (final user in users) {
      // 1. Calculate required working days in this month
      int expectedWorkingDays = 0;
      for (int d = 1; d <= maxDayToCheck; d++) {
        final dayDate = DateTime(date.year, date.month, d);
        // Only count if on or after effectiveStartDate
        if (dayDate.isBefore(DateTime(user.effectiveStartDate.year, user.effectiveStartDate.month, user.effectiveStartDate.day))) {
          continue;
        }
        // DateTime.weekday: 1 = Mon, 7 = Sun. user.workingDays contains day numbers (e.g. 7=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu)
        if (user.workingDays.contains(dayDate.weekday)) {
          expectedWorkingDays++;
        }
      }

      final totalRequiredMinutes = expectedWorkingDays * user.requiredDailyMinutes;

      // 2. Aggregate user's summaries for this month
      final userSummaries = summaries.where((s) => s.userId == user.id).toList();

      int workedMinutes = 0;
      int overtimeMinutes = 0;
      int deficitMinutes = 0;
      double totalPoints = 0.0;
      int attendanceDays = 0;

      for (final s in userSummaries) {
        workedMinutes += s.workedMinutes;
        totalPoints += s.points;
        if (s.workedMinutes > 0) {
          attendanceDays++;
        }
        if (s.differenceMinutes > 0) {
          overtimeMinutes += s.differenceMinutes;
        } else if (s.differenceMinutes < 0 && !s.isHoliday) {
          deficitMinutes += s.differenceMinutes.abs();
        }
      }

      final absentDays = (expectedWorkingDays - attendanceDays).clamp(0, 31);
      final avgPoints = expectedWorkingDays > 0
          ? double.parse((totalPoints / expectedWorkingDays).toStringAsFixed(1))
          : totalPoints;

      final commitment = PointsCalculator.calculateCommitmentRatio(
        actualWorkedMinutes: workedMinutes,
        totalRequiredMinutes: totalRequiredMinutes,
      );

      partnerSummaries[user.id] = PartnerSummaryModel(
        userId: user.id,
        userName: user.name,
        requiredMinutes: totalRequiredMinutes,
        workedMinutes: workedMinutes,
        overtimeMinutes: overtimeMinutes,
        deficitMinutes: deficitMinutes,
        workingDaysCount: expectedWorkingDays,
        attendanceDaysCount: attendanceDays,
        absentDaysCount: absentDays,
        totalPoints: double.parse(totalPoints.toStringAsFixed(1)),
        averageDailyPoints: avgPoints,
        commitmentPercentage: commitment,
        effortPercentage: 0.0, // calculated below in 2nd pass
      );

      totalPartnersPoints += totalPoints;
      totalWorkedMinutesAll += workedMinutes;
    }

    // 2nd pass: Compute % Effort Share for each partner
    final updatedPartnerSummaries = <String, PartnerSummaryModel>{};
    partnerSummaries.forEach((userId, summary) {
      final effortShare = PointsCalculator.calculatePartnerEffortPercentage(
        partnerPoints: summary.totalPoints,
        totalPartnersPoints: totalPartnersPoints,
      );
      updatedPartnerSummaries[userId] = PartnerSummaryModel(
        userId: summary.userId,
        userName: summary.userName,
        requiredMinutes: summary.requiredMinutes,
        workedMinutes: summary.workedMinutes,
        overtimeMinutes: summary.overtimeMinutes,
        deficitMinutes: summary.deficitMinutes,
        workingDaysCount: summary.workingDaysCount,
        attendanceDaysCount: summary.attendanceDaysCount,
        absentDaysCount: summary.absentDaysCount,
        totalPoints: summary.totalPoints,
        averageDailyPoints: summary.averageDailyPoints,
        commitmentPercentage: summary.commitmentPercentage,
        effortPercentage: effortShare,
      );
    });

    return MonthlyReportModel(
      monthKey: monthKey,
      status: 'open',
      partnerSummaries: updatedPartnerSummaries,
      totalPartnersPoints: double.parse(totalPartnersPoints.toStringAsFixed(1)),
      totalWorkedMinutes: totalWorkedMinutesAll,
    );
  }

  /// Freezes and closes the month snapshot
  Future<void> closeMonth({
    required String monthKey,
    required String closedByUserId,
    required String closedByUserName,
    required MonthlyReportModel computedReport,
  }) async {
    final now = DateTime.now();
    final closedReport = MonthlyReportModel(
      monthKey: monthKey,
      status: 'closed',
      closedAt: now,
      closedByUserId: closedByUserId,
      closedByUserName: closedByUserName,
      partnerSummaries: computedReport.partnerSummaries,
      totalPartnersPoints: computedReport.totalPartnersPoints,
      totalWorkedMinutes: computedReport.totalWorkedMinutes,
      updatedAt: now,
    );

    await _reportsCol.doc(monthKey).set(closedReport.toMap());

    // Audit Log
    await auditLogRepo.log(
      action: AuditAction.closeMonth,
      actorId: closedByUserId,
      actorName: closedByUserName,
      details: 'إغلاق شهر $monthKey واعتماد التقرير النهائي (مجموع النقاط: ${computedReport.totalPartnersPoints})',
    );
  }

  /// Reopens a closed month
  Future<void> reopenMonth({
    required String monthKey,
    required String actorId,
    required String actorName,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) {
      throw Exception('يجب كتابة سبب إعادة فتح الشهر.');
    }

    await _reportsCol.doc(monthKey).update({
      'status': 'open',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await auditLogRepo.log(
      action: AuditAction.reopenMonth,
      actorId: actorId,
      actorName: actorName,
      details: 'إعادة فتح شهر $monthKey للتعديل',
      reason: reason.trim(),
    );
  }
}
