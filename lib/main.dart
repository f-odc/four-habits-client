import 'package:flutter/material.dart';
import 'package:four_habits_client/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

  // --- NOTIFICATION SETTINGS ---
  // Request permissions
  await requestPermissions();
  await requestExactAlarmPermission();

  // initialize timezone
  tz.initializeTimeZones();
  // get current timezone
  tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));

  // init Notifications
  final notificationService = NotificationService();

  // --- END NOTIFICATION SETTINGS ---

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
