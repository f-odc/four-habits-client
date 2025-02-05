import 'package:flutter/material.dart';
import 'package:four_habits_client/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'pages/habit_screen.dart';
import 'pages/welcome_screen.dart';
import 'services/shared_preferences_service.dart';

Future<void> requestPermissions() async {
  await Permission.notification.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = SharedPreferencesService();
  await prefs.init();
  bool firstVisit = prefs.getFirstVisit() ?? true;
  firstVisit = true;

  // Request permissions
  await requestPermissions();
  await requestExactAlarmPermission();

  // init Notifications
  final notificationService = NotificationService();

  // TODO: if enableNotifications is true, schedule daily notification
  //await notificationService.periodicNotification();

  runApp(MyApp(firstVisit: firstVisit));
}

Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatelessWidget {
  final bool firstVisit;

  const MyApp({super.key, required this.firstVisit});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '4Habits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: firstVisit
          ? const WelcomeScreen()
          : const HabitScreen(), // select home screen
    );
  }
}
