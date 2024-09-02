// NotificationService.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // IOS was deleted
  NotificationService() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        '0', 'Connect 4',
        channelDescription: 'A move was performed',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: null);
    await flutterLocalNotificationsPlugin.show(
        0, 'Connect 4', 'A move was performed', platformChannelSpecifics,
        payload: 'item x');
  }
}
