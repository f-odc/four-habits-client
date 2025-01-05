import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/habit.dart';
import 'habits/create_habit_screen.dart';
import 'habits/detailed_habit_screen.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<Habit> _habits = [];
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadHabit();
    _loadUsername();
  }

  Future<void> _loadHabit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habitStrings = prefs.getStringList('habits') ?? [];

    setState(() {
      _habits = habitStrings.map((habitString) {
        return Habit.fromString(habitString);
      }).toList();
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 80), // Adjust this value to move the AppBar further down
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
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedHabitScreen(
                          habit: _habits[index],
                          index: index,
                        ),
                      ),
                    );
                    _loadHabit();
                  },
                  child: Padding (
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(
                          'Habit: ${_habits[index].name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                      ),
                      subtitle: Text(
                        _habits[index].occurrenceType == 'Daily'
                          ? 'Occurrence: ${_habits[index].occurrenceType}'
                          : 'Occurrence: ${_habits[index].occurrenceType} - ${_habits[index].occurrenceNum}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _habits[index].getStreak().toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                          const Icon(Icons.local_fire_department),
                        ],
                      ),
                    ),
                  ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton : Padding (
        padding: const EdgeInsets.only(bottom: 30.0),
      child: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateHabitScreen()),
          );
          if (result == 'saved') {
            _loadHabit();
          }
        },
        tooltip: 'Add Habit',
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
        label: Text(
            'Add new Habit',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
        ),
      ),
      ),
    );
  }
}