// new.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/habit.dart';
import 'create_habit_screen.dart';
import 'detailed_habit_screen.dart';

class HabitScreen extends StatefulWidget {
  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  // Use shared preferences to load the habit
  Future<void> _loadHabit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habitStrings = prefs.getStringList('habits') ?? [];

    // Convert each Habit string to a Habit object
    setState(() {
      _habits = habitStrings.map((habitString) {
        return Habit.fromString(habitString);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Habit'),
      ),
      body: ListView.builder(
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          //List<String> habitDetails = _habits[index].split(':');
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
              // load habits again
              _loadHabit();
            },
            child: Card(
              child: ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Habit: ${_habits[index].name}'),
                subtitle: Text(_habits[index].occurrenceType == 'Daily'
                    ? 'Occurrence: ${_habits[index].occurrenceType}'
                    : 'Occurrence: ${_habits[index].occurrenceType} - ${_habits[index].occurrenceNum}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _habits[index].getStreak().toString(), // streak
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    Icon(Icons.local_fire_department), // flame icon
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateHabitScreen()),
          );
          if (result == 'saved') {
            _loadHabit();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Habit',
      ),
    );
  }
}
