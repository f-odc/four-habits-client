// create_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../model/habit.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  _CreateHabitScreenState createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _habitName = '';
  String? _occurrenceType;
  final _occurrenceController = TextEditingController();

  // Use shared preferences to save the habit
  Future<void> _saveHabit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habits = prefs.getStringList('habits') ?? [];

    // Create a new Habit object
    Habit habit = Habit(
      id: const Uuid().v4().toString(),
      name: _habitName,
      occurrenceType: _occurrenceType!,
      occurrenceNum: _occurrenceController.text, // shows # of occurrences
      completedDates: [],
    );

    // Convert the Habit object to a String
    String habitString = habit.toString();

    // Add the Habit string to the list and save it in SharedPreferences
    habits.add(habitString);
    prefs.setStringList('habits', habits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Habit Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
              onSaved: (value) {
                _habitName = value!;
              },
            ),
            DropdownButtonFormField<String>(
              value: _occurrenceType,
              decoration: const InputDecoration(labelText: 'Occurrence'),
              items: <String>['Daily', 'Weekly', 'Monthly']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _occurrenceType = newValue;
                });
              },
            ),
            if (_occurrenceType != 'Daily' && _occurrenceType != null)
              TextFormField(
                controller: _occurrenceController,
                decoration: const InputDecoration(labelText: 'Enter number of times'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number';
                  }
                  return null;
                },
              ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // save the habit
                  await _saveHabit();
                  Navigator.pop(context, 'saved');
                }
              },
              child: const Text('Save Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
