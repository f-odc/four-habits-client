import 'package:flutter/material.dart';
import 'package:four_habits_client/components/custom_card.dart';
import 'package:four_habits_client/components/custom_divider.dart';
import 'package:four_habits_client/components/habit_tile.dart';

import '../model/habit.dart';
import '../services/shared_preferences_service.dart';
import 'habits/create_habit_screen.dart';
import 'habits/detailed_habit_screen2.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<Habit> _habits = [];
  String _username = '';
  final pref = SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _loadHabit();
    _loadUsername();
  }

  Future<void> _loadHabit() async {
    setState(() {
      _habits = pref.getHabits();
    });
  }

  Future<void> _loadUsername() async {
    setState(() {
      _username = pref.getUsername() ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
              height: 80), // Adjust this value to move the AppBar further down
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome $_username',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const Text(
                  '“Great habits are the foundation of great achievements.”',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  _habits.length + 1, // Add one for the "Create New Habit" card
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Create New Habit card
                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateHabitScreen()),
                      );
                      if (result == 'saved') {
                        _loadHabit();
                      }
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: CustomCard(
                            icon: Icons.add,
                            iconColor: Colors.orange,
                            cardColor: Colors.orange[100],
                            cardText: 'Create New Habit',
                            cardTextColor: Colors.orange)),
                  );
                } else if (index == 1) {
                  // Divider
                  return CustomDivider(height: null);
                } else {
                  // Habit cards
                  final habit = _habits[index - 1];
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedHabitScreen2(
                            habit: habit,
                            index: index - 1,
                          ),
                        ),
                      );
                      _loadHabit();
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        // HABIT TILE
                        child: HabitTile(
                            habitName: habit.name,
                            occurrenceType: habit.occurrenceType,
                            occurrenceNum: habit.occurrenceNum,
                            streak: habit.getStreak())),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
