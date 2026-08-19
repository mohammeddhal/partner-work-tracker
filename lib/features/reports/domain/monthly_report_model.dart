import 'package:cloud_firestore/cloud_firestore.dart';
import 'partner_summary_model.dart';

class MonthlyReportModel {
  final String monthKey; // YYYY-MM
  final String status; // 'open' | 'closed'
  final DateTime? closedAt;
  final String? closedByUserId;
  final String? closedByUserName;
  final Map<String, PartnerSummaryModel> partnerSummaries; // userId -> PartnerSummaryModel
  final double totalPartnersPoints;
  final int totalWorkedMinutes;
  final DateTime? updatedAt;

  const MonthlyReportModel({
    required this.monthKey,
    this.status = 'open',
    this.closedAt,
    this.closedByUserId,
    this.closedByUserName,
    required this.partnerSummaries,
    required this.totalPartnersPoints,
    required this.totalWorkedMinutes,
    this.updatedAt,
  });

  bool get isClosed => status == 'closed';
  bool get isOpen => status == 'open';

  Map<String, dynamic> toMap() {
    final summariesMap = <String, dynamic>{};
    partnerSummaries.forEach((key, val) {
      summariesMap[key] = val.toMap();
    });

    return {
      'monthKey': monthKey,
      'status': status,
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'closedByUserId': closedByUserId,
      'closedByUserName': closedByUserName,
      'partnerSummaries': summariesMap,
      'totalPartnersPoints': totalPartnersPoints,
      'totalWorkedMinutes': totalWorkedMinutes,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory MonthlyReportModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawSummaries = map['partnerSummaries'] as Map<String, dynamic>? ?? {};
    final partnerSummaries = <String, PartnerSummaryModel>{};
    rawSummaries.forEach((key, val) {
      if (val is Map<String, dynamic>) {
        partnerSummaries[key] = PartnerSummaryModel.fromMap(val);
      }
    });

    return MonthlyReportModel(
      monthKey: documentId,
      status: map['status'] as String? ?? 'open',
      closedAt: parseTimestamp(map['closedAt']),
      closedByUserId: map['closedByUserId'] as String?,
      closedByUserName: map['closedByUserName'] as String?,
      partnerSummaries: partnerSummaries,
      totalPartnersPoints: (map['totalPartnersPoints'] as num?)?.toDouble() ?? 0.0,
      totalWorkedMinutes: (map['totalWorkedMinutes'] as num?)?.toInt() ?? 0,
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }
}
