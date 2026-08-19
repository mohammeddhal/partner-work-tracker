import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/app_strings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  Future<void> showLongSessionWarning() async {
    const androidDetails = AndroidNotificationDetails(
      'work_session_channel',
      'جلسات العمل',
      channelDescription: 'تنبيهات استمرار جلسات العمل المفتوحة',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1001,
      AppStrings.longSessionWarningTitle,
      AppStrings.longSessionWarningBody,
      details,
    );
  }

  Future<void> showOverdueTaskWarning(int overdueCount) async {
    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'تنبيهات المهام',
      channelDescription: 'تنبيهات استحقاق وتأخر المهام',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      2002,
      'تنبيه: لديك $overdueCount مهام متأخرة ⚠️',
      'يرجى مراجعة قائمة المهام وإنجاز المهام التي تجاوزت موعدها المحدد.',
      details,
    );
  }
}
