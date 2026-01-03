import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // 🚀 App ochilganda initialize
  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
    debugPrint('✅ Notification Service initialized');
  }

  // Notification bosilganda
  void _onNotificationTapped(NotificationResponse response) {
    final taskId = response.payload;
    debugPrint('📱 Notification tapped: Task ID = $taskId');
  }

  // ➕ Task qo'shilganda → schedule notification
  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String description,
    required DateTime scheduledDate,
  }) async {
    try {
      final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);
      final now = tz.TZDateTime.now(tz.local);

      if (scheduledTz.isBefore(now)) {
        debugPrint('⚠️ Scheduled date is in the past, skipping notification');
        return;
      }

      await _notifications.zonedSchedule(
        taskId.hashCode,
        '⏰ $title',
        description,
        scheduledTz,
        _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: taskId,
      );

      debugPrint('✅ Notification scheduled for: $scheduledDate');
    } catch (e) {
      debugPrint('❌ Schedule notification error: $e');
    }
  }

  // ✏️ Task tahrirlanganda → cancel + qayta schedule
  Future<void> rescheduleTaskNotification({
    required String taskId,
    required String title,
    required String description,
    required DateTime scheduledDate,
  }) async {
    await cancelNotification(taskId);

    await scheduleTaskNotification(
      taskId: taskId,
      title: title,
      description: description,
      scheduledDate: scheduledDate,
    );
  }

  // ✅ Task bajarilganda yoki 🗑 o'chirilganda → cancel
  Future<void> cancelNotification(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  // Barcha notificationlarni o'chirish
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Notification details
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Notifications',
        channelDescription: 'Vazifalar uchun eslatmalar',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Darhol notification ko'rsatish (test uchun)
  Future<void> showImmediateNotification({
    required String id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id.hashCode,
      title,
      body,
      _notificationDetails(),
      payload: id,
    );
  }

  // Pending notifications ro'yxati
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Permission so'rash (iOS uchun)
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        debugPrint('🔔 Android Notification Permission: ${granted ?? false}');
        return granted ?? false;
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('🔔 iOS Notification Permission: ${result ?? false}');
      return result ?? false;
    }
    return false;
  }
}
