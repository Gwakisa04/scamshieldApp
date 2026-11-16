import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'platform.dart';

class GuardService {
  static const _channelSms = 'sms_alerts';
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized || !isAndroid) return;
    _initialized = true;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      settings: const InitializationSettings(android: android),
    );

    final impl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await impl?.createNotificationChannel(AndroidNotificationChannel(
      _channelSms,
      'Scam alerts',
      description: 'Alerts when incoming SMS may be a scam',
      importance: Importance.max,
    ));
  }

  /// Warns the user the moment a call from an unsaved number rings.
  static Future<void> requestCallWatchPermission() async {
    if (!isAndroid) return;
    await Permission.phone.request();
  }
}
