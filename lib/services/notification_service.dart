import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:four_habits_client/services/shared_preferences_service.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final pref = SharedPreferencesService();

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

    // request permissions
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification() async {
    print("Showing notification");
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

  Future<void> scheduleDailyNotification() async {
    final (_, notificationTime) = pref.getNotificationSettings();
    final scheduledTime =
        _nextInstanceOfTime(notificationTime.hour, notificationTime.minute);

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'daily_notification_channel_id', 'Daily Notifications',
        channelDescription: 'Channel for daily notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(0, 'Daily Reminder',
        'This is your daily reminder!', scheduledTime, platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> periodicNotification() async {
    print("Scheduling periodic notification");
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        '1', 'Connect 8',
        channelDescription: 'No move was performed',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: null);
    await flutterLocalNotificationsPlugin.periodicallyShow(
        1,
        'Connect 8',
        'No move was performed',
        RepeatInterval.everyMinute,
        platformChannelSpecifics,
        payload: 'item x',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  Future<void> stopNotification() async {
    await flutterLocalNotificationsPlugin
        .cancel(1); // Cancel specific notification
    // Or to cancel all notifications
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
