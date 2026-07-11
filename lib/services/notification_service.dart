import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;
  String? _deviceToken;

  bool get isInitialized => _initialized;
  String? get deviceToken => _deviceToken;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermission();

    _deviceToken = await _messaging.getToken();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTapData);

    if (await _messaging.getInitialMessage() != null) {
      _onNotificationTapData(null);
    }

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: notification.title ?? '',
        body: notification.body ?? '',
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {}

  void _onNotificationTapData(RemoteMessage? message) {
    if (message?.data.isNotEmpty == true) {}
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'study_channel',
      'Recordatorios de Estudio',
      channelDescription: 'Notificaciones relacionadas con tu estudio',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload,
    );
  }

  Future<void> scheduleStudyReminder({
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = DateTime.now();
    final delay = scheduledTime.difference(now);

    if (delay.isNegative) return;

    await Future.delayed(delay, () {
      _showLocalNotification(
        id: scheduledTime.millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
      );
    });
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    for (int i = 0; i < 30; i++) {
      final dayTime = scheduledTime.add(Duration(days: i));
      scheduleStudyReminder(
        title: title,
        body: body,
        scheduledTime: dayTime,
      );
    }
  }

  Future<void> showQuizReminder(String quizTitle) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '¿Listo para practicar?',
      body: 'Tienes un quiz pendiente: $quizTitle',
    );
  }

  Future<void> showStreakReminder(int streak) async {
    await _showLocalNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '¡Racha de $streak días!',
      body: 'No pierdas tu racha. Estudia hoy 5 minutos.',
    );
  }
}
