import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../history/data/daily_summary_repository.dart';
import '../data/work_session_repository.dart';
import '../domain/work_session_model.dart';

final trackerControllerProvider = StateNotifierProvider<TrackerController, AsyncValue<void>>((ref) {
  return TrackerController(
    ref: ref,
    workSessionRepo: ref.watch(workSessionRepositoryProvider),
  );
});

/// Live Seconds Provider: updates every 1 second when there is an active session
final liveElapsedSecondsProvider = StreamProvider.autoDispose<int>((ref) {
  final activeSession = ref.watch(activeSessionProvider).value;
  if (activeSession == null) return Stream.value(0);

  return Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    final diff = now.difference(activeSession.startTime).inSeconds;
    return diff > 0 ? diff : 0;
  });
});

class TrackerController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  final WorkSessionRepository workSessionRepo;
  Timer? _longSessionCheckTimer;

  TrackerController({
    required this.ref,
    required this.workSessionRepo,
  }) : super(const AsyncValue.data(null)) {
    _startLongSessionMonitor();
  }

  void _startLongSessionMonitor() {
    _longSessionCheckTimer = Timer.periodic(const Duration(minutes: 15), (_) {
      final activeSession = ref.read(activeSessionProvider).value;
      if (activeSession != null) {
        final hours = DateTime.now().difference(activeSession.startTime).inHours;
        if (hours >= 4) {
          NotificationService().showLongSessionWarning();
        }
      }
    });
  }

  @override
  void dispose() {
    _longSessionCheckTimer?.cancel();
    super.dispose();
  }

  Future<bool> startWork(BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider).value;
      if (user == null) {
        throw Exception('المستخدم غير مسجل الدخول.');
      }

      await workSessionRepo.startSession(
        userId: user.id,
        userName: user.name,
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }

  Future<bool> endWork(BuildContext context, WorkSessionModel activeSession) async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(currentUserProvider).value;
      final requiredMinutes = user?.requiredDailyMinutes ?? 120;
      final pointsCap = user?.dailyPointsCap;

      await workSessionRepo.endSession(
        activeSession: activeSession,
        requiredDailyMinutes: requiredMinutes,
        dailyPointsCap: pointsCap,
      );

      // Force refresh daily summary
      ref.invalidate(todaySummaryProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return false;
    }
  }
}
