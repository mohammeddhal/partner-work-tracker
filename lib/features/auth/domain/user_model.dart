import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final int requiredDailyMinutes; // 120 (Mohammad), 240 (Masoud)
  final int workingDaysPerWeek; // e.g. 5
  final List<int> workingDays; // [1, 2, 3, 4, 5] (Sunday to Thursday)
  final DateTime effectiveStartDate;
  final bool isActive;
  final int? dailyPointsCap; // null = unlimited
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.requiredDailyMinutes,
    this.workingDaysPerWeek = 5,
    this.workingDays = const [7, 1, 2, 3, 4], // Sun, Mon, Tue, Wed, Thu
    required this.effectiveStartDate,
    this.isActive = true,
    this.dailyPointsCap,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == UserRole.admin;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    int? requiredDailyMinutes,
    int? workingDaysPerWeek,
    List<int>? workingDays,
    DateTime? effectiveStartDate,
    bool? isActive,
    int? dailyPointsCap,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      requiredDailyMinutes: requiredDailyMinutes ?? this.requiredDailyMinutes,
      workingDaysPerWeek: workingDaysPerWeek ?? this.workingDaysPerWeek,
      workingDays: workingDays ?? this.workingDays,
      effectiveStartDate: effectiveStartDate ?? this.effectiveStartDate,
      isActive: isActive ?? this.isActive,
      dailyPointsCap: dailyPointsCap ?? this.dailyPointsCap,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toValue(),
      'requiredDailyMinutes': requiredDailyMinutes,
      'workingDaysPerWeek': workingDaysPerWeek,
      'workingDays': workingDays,
      'effectiveStartDate': Timestamp.fromDate(effectiveStartDate),
      'isActive': isActive,
      'dailyPointsCap': dailyPointsCap,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawWorkingDays = map['workingDays'];
    List<int> parsedWorkingDays = [7, 1, 2, 3, 4];
    if (rawWorkingDays is List) {
      parsedWorkingDays = rawWorkingDays.map((e) => (e as num).toInt()).toList();
    }

    return UserModel(
      id: documentId,
      name: map['name'] as String? ?? 'مستخدم',
      email: map['email'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      requiredDailyMinutes: (map['requiredDailyMinutes'] as num?)?.toInt() ?? 120,
      workingDaysPerWeek: (map['workingDaysPerWeek'] as num?)?.toInt() ?? 5,
      workingDays: parsedWorkingDays,
      effectiveStartDate: parseTimestamp(map['effectiveStartDate']),
      isActive: map['isActive'] as bool? ?? true,
      dailyPointsCap: (map['dailyPointsCap'] as num?)?.toInt(),
      createdAt: map['createdAt'] != null ? parseTimestamp(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? parseTimestamp(map['updatedAt']) : null,
    );
  }
}
