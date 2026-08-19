import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/daily_summary_model.dart';

final dailySummaryRepositoryProvider = Provider<DailySummaryRepository>((ref) {
  return DailySummaryRepository(firestore: FirebaseFirestore.instance);
});

final todaySummaryProvider = StreamProvider<DailySummaryModel?>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(null);
  final todayKey = DateTimeFormatter.toDateKey(DateTime.now());
  return ref.watch(dailySummaryRepositoryProvider).watchSummaryForDate(user.id, todayKey);
});

final userMonthSummariesProvider = StreamProvider.family<List<DailySummaryModel>, String>((ref, monthKey) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(dailySummaryRepositoryProvider).watchUserSummariesForMonth(user.id, monthKey);
});

final allMonthSummariesProvider = StreamProvider.family<List<DailySummaryModel>, String>((ref, monthKey) {
  return ref.watch(dailySummaryRepositoryProvider).watchAllSummariesForMonth(monthKey);
});

class DailySummaryRepository {
  final FirebaseFirestore firestore;

  DailySummaryRepository({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _summariesCol =>
      firestore.collection('dailySummaries');

  Stream<DailySummaryModel?> watchSummaryForDate(String userId, String dateKey) {
    final summaryId = '${userId}_$dateKey';
    return _summariesCol.doc(summaryId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return DailySummaryModel.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Stream<List<DailySummaryModel>> watchUserSummariesForMonth(String userId, String monthKey) {
    return _summariesCol
        .where('userId', isEqualTo: userId)
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => DailySummaryModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
      return list;
    });
  }

  Stream<List<DailySummaryModel>> watchAllSummariesForMonth(String monthKey) {
    return _summariesCol
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => DailySummaryModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.dateKey.compareTo(a.dateKey));
      return list;
    });
  }

  Future<void> markHoliday(String userId, String dateKey, bool isHoliday) async {
    final summaryId = '${userId}_$dateKey';
    await _summariesCol.doc(summaryId).set({
      'isHoliday': isHoliday,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
