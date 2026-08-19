import 'package:cloud_firestore/cloud_firestore.dart';

class DailySummaryModel {
  final String id; // userId_dateKey
  final String userId;
  final String userName;
  final String dateKey; // YYYY-MM-DD
  final String monthKey; // YYYY-MM
  final int workedMinutes;
  final int requiredMinutes;
  final int differenceMinutes;
  final double points;
  final double achievementPercentage;
  final int sessionsCount;
  final DateTime? firstCheckIn;
  final DateTime? lastCheckOut;
  final bool isHoliday;
  final DateTime? updatedAt;

  const DailySummaryModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.dateKey,
    required this.monthKey,
    required this.workedMinutes,
    required this.requiredMinutes,
    required this.differenceMinutes,
    required this.points,
    required this.achievementPercentage,
    required this.sessionsCount,
    this.firstCheckIn,
    this.lastCheckOut,
    this.isHoliday = false,
    this.updatedAt,
  });

  bool get isOvertime => differenceMinutes > 0;
  bool get isDeficit => differenceMinutes < 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'dateKey': dateKey,
      'monthKey': monthKey,
      'workedMinutes': workedMinutes,
      'requiredMinutes': requiredMinutes,
      'differenceMinutes': differenceMinutes,
      'points': points,
      'achievementPercentage': achievementPercentage,
      'sessionsCount': sessionsCount,
      'firstCheckIn': firstCheckIn != null ? Timestamp.fromDate(firstCheckIn!) : null,
      'lastCheckOut': lastCheckOut != null ? Timestamp.fromDate(lastCheckOut!) : null,
      'isHoliday': isHoliday,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DailySummaryModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime? parseTimestamp(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return DailySummaryModel(
      id: documentId,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      dateKey: map['dateKey'] as String? ?? '',
      monthKey: map['monthKey'] as String? ?? '',
      workedMinutes: (map['workedMinutes'] as num?)?.toInt() ?? 0,
      requiredMinutes: (map['requiredMinutes'] as num?)?.toInt() ?? 0,
      differenceMinutes: (map['differenceMinutes'] as num?)?.toInt() ?? 0,
      points: (map['points'] as num?)?.toDouble() ?? 0.0,
      achievementPercentage: (map['achievementPercentage'] as num?)?.toDouble() ?? 0.0,
      sessionsCount: (map['sessionsCount'] as num?)?.toInt() ?? 0,
      firstCheckIn: parseTimestamp(map['firstCheckIn']),
      lastCheckOut: parseTimestamp(map['lastCheckOut']),
      isHoliday: map['isHoliday'] as bool? ?? false,
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }
}
