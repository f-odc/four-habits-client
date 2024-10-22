// edit_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditHabitScreen extends StatefulWidget {
  final String habit;
  final int index;

  const EditHabitScreen({super.key, required this.habit, required this.index});

  @override
  _EditHabitScreenState createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _habitName = '';
  String? _occurrence;
  final _occurrenceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    List<String> habitDetails = widget.habit.split(':');
    _habitName = habitDetails[0];
    // set the occurrence
    if (habitDetails[1] == 'Daily') {
      _occurrence = 'Daily';
    } else if (habitDetails[1].contains('week')) {
      _occurrence = 'x times a week';
      _occurrenceController.text = habitDetails[1].split(' ')[0];
    } else if (habitDetails[1].contains('month')) {
      _occurrence = 'x times a month';
      _occurrenceController.text = habitDetails[1].split(' ')[0];
    }
  }

  Future<void> _updateHabit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habits = prefs.getStringList('habits') ?? [];
    habits[widget.index] = '$_habitName:$_occurrence';
    prefs.setStringList('habits', habits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Habit'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              initialValue: _habitName,
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
              value: _occurrence,
              decoration: const InputDecoration(labelText: 'Occurrence'),
              items: <String>['Daily', 'x times a week', 'x times a month']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _occurrence = newValue;
                });
              },
            ),
            if (_occurrence != 'Daily' && _occurrence != null)
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
                  if (_occurrence != 'Daily' && _occurrence != null) {
                    _occurrence = _occurrence!
                        .replaceFirst('x', _occurrenceController.text);
                  }
                  // update the habit
                  await _updateHabit();
                  Navigator.pop(context, 'updated');
                }
              },
              child: const Text('Update Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
