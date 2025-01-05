import 'package:flutter/material.dart';
import 'package:four_habits_client/pages/habit_screen.dart';
import 'package:four_habits_client/pages/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('firstVisit')) {
    await prefs.setBool('firstVisit', true);
  }
  await prefs.setBool('firstVisit', true);
  final bool firstVisit = prefs.getBool('firstVisit') ?? true;

  runApp(MyApp(firstVisit: firstVisit));
}

class MyApp extends StatelessWidget {
  final bool firstVisit;

  const MyApp({super.key, required this.firstVisit});

  // This widget is the root of your application.
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