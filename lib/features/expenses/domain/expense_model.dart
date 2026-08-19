import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String title; // اسم الخدمة أو السلعة
  final double amount; // السعر
  final DateTime date; // التاريخ
  final String dateKey; // YYYY-MM-DD
  final String monthKey; // YYYY-MM
  final String buyerId;
  final String buyerName; // محمد أو مسعود
  final String? notes;
  final DateTime? createdAt;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.dateKey,
    required this.monthKey,
    required this.buyerId,
    required this.buyerName,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'dateKey': dateKey,
      'monthKey': monthKey,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map, String documentId) {
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ExpenseModel(
      id: documentId,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parseTimestamp(map['date']),
      dateKey: map['dateKey'] as String? ?? '',
      monthKey: map['monthKey'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      notes: map['notes'] as String?,
      createdAt: map['createdAt'] != null ? parseTimestamp(map['createdAt']) : null,
    );
  }
}
