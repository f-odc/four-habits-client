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

  // --- NOTIFICATION SETTINGS ---
  // Request permissions
  await requestPermissions();
  await requestExactAlarmPermission();

  // initialize timezone
  tz.initializeTimeZones();
  // get current timezone
  print(DateTime.now().timeZoneName);

  // Get system timezone abbreviation (like "CEST", "PST", etc.)
  String systemTimeZone = DateTime.now().timeZoneName;

  // Find a valid mapping or fallback to UTC
  String? validTimeZone = timeZoneMap[systemTimeZone] ?? "UTC";
  tz.setLocalLocation(tz.getLocation(validTimeZone));

  // init Notifications
  NotificationService();

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

// Map of common timezone abbreviations to time zone names used by the timezone package to set Local Location
Map<String, String> timeZoneMap = {
  // Central European Time
  "CEST": "Europe/Berlin",
  "CET": "Europe/Berlin",

  // Pacific Time (US)
  "PDT": "America/Los_Angeles",
  "PST": "America/Los_Angeles",

  // Eastern Time (US)
  "EDT": "America/New_York",
  "EST": "America/New_York",

  // Central Time (US)
  "CDT": "America/Chicago",
  "CST": "America/Chicago",

  // Mountain Time (US)
  "MDT": "America/Denver",
  "MST": "America/Denver",

  // India
  "IST": "Asia/Kolkata",

  // British Time
  "BST": "Europe/London",
  "GMT": "Europe/London",

  // Australia
  "AEST": "Australia/Sydney",
  "AEDT": "Australia/Sydney",
  "ACST": "Australia/Adelaide",
  "ACDT": "Australia/Adelaide",
  "AWST": "Australia/Perth",

  // Brazil
  "BRT": "America/Sao_Paulo",
  "BRST": "America/Sao_Paulo",

  // Japan
  "JST": "Asia/Tokyo",

  // China
  "CST": "Asia/Shanghai", // Be careful, "CST" is also used for US Central Time

  // Russia
  "MSK": "Europe/Moscow",

  // Mexico
  "MST": "America/Mexico_City",
  "CST": "America/Mexico_City",

  // South Africa
  "SAST": "Africa/Johannesburg",

  // New Zealand
  "NZST": "Pacific/Auckland",
  "NZDT": "Pacific/Auckland",

  // Argentina
  "ART": "America/Argentina/Buenos_Aires",

  // Hawaii
  "HST": "Pacific/Honolulu",
};
