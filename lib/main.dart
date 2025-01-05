import 'package:flutter/material.dart';
import 'services/shared_preferences_service.dart';
import 'pages/welcome_screen.dart';
import 'pages/habit_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService().init();
  final prefs = SharedPreferencesService();
  bool firstVisit = prefs.getFirstVisit() ?? true;

  runApp(MyApp(firstVisit: firstVisit));
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: firstVisit ? const WelcomeScreen() : const HabitScreen(), // select home screen
    );
  }
}