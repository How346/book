import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationService {
  static final plugin=FlutterLocalNotificationsPlugin();
  static Future<void> init() async {
    const settings=InitializationSettings(android:AndroidInitializationSettings('@mipmap/ic_launcher'));
    await plugin.initialize(settings);
  }
}
