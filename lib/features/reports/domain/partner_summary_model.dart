class PartnerSummaryModel {
  final String userId;
  final String userName;
  final int requiredMinutes;
  final int workedMinutes;
  final int overtimeMinutes;
  final int deficitMinutes;
  final int workingDaysCount;
  final int attendanceDaysCount;
  final int absentDaysCount;
  final double totalPoints;
  final double averageDailyPoints;
  final double commitmentPercentage;
  final double effortPercentage;

  const PartnerSummaryModel({
    required this.userId,
    required this.userName,
    required this.requiredMinutes,
    required this.workedMinutes,
    required this.overtimeMinutes,
    required this.deficitMinutes,
    required this.workingDaysCount,
    required this.attendanceDaysCount,
    required this.absentDaysCount,
    required this.totalPoints,
    required this.averageDailyPoints,
    required this.commitmentPercentage,
    required this.effortPercentage,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'requiredMinutes': requiredMinutes,
      'workedMinutes': workedMinutes,
      'overtimeMinutes': overtimeMinutes,
      'deficitMinutes': deficitMinutes,
      'workingDaysCount': workingDaysCount,
      'attendanceDaysCount': attendanceDaysCount,
      'absentDaysCount': absentDaysCount,
      'totalPoints': totalPoints,
      'averageDailyPoints': averageDailyPoints,
      'commitmentPercentage': commitmentPercentage,
      'effortPercentage': effortPercentage,
    };
  }

  factory PartnerSummaryModel.fromMap(Map<String, dynamic> map) {
    return PartnerSummaryModel(
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      requiredMinutes: (map['requiredMinutes'] as num?)?.toInt() ?? 0,
      workedMinutes: (map['workedMinutes'] as num?)?.toInt() ?? 0,
      overtimeMinutes: (map['overtimeMinutes'] as num?)?.toInt() ?? 0,
      deficitMinutes: (map['deficitMinutes'] as num?)?.toInt() ?? 0,
      workingDaysCount: (map['workingDaysCount'] as num?)?.toInt() ?? 0,
      attendanceDaysCount: (map['attendanceDaysCount'] as num?)?.toInt() ?? 0,
      absentDaysCount: (map['absentDaysCount'] as num?)?.toInt() ?? 0,
      totalPoints: (map['totalPoints'] as num?)?.toDouble() ?? 0.0,
      averageDailyPoints: (map['averageDailyPoints'] as num?)?.toDouble() ?? 0.0,
      commitmentPercentage: (map['commitmentPercentage'] as num?)?.toDouble() ?? 0.0,
      effortPercentage: (map['effortPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
