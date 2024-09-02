// detailed_habit_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

import '../../model/habit.dart';

class DetailedHabitScreen extends StatefulWidget {
  Habit habit;
  final int index;

  DetailedHabitScreen({required this.habit, required this.index});

  @override
  _DetailedHabitScreenState createState() => _DetailedHabitScreenState();
}

class _DetailedHabitScreenState extends State<DetailedHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _habitName = '';
  String? _occurrenceType;
  int _streak = 0;
  final _occurrenceController = TextEditingController();

  String _username = '';

  @override
  void initState() {
    super.initState();
    _habitName = widget.habit.name;
    _streak = widget.habit.getStreak();
    _occurrenceType = widget.habit.occurrenceType;
    _occurrenceController.text =
        widget.habit.occurrenceNum; // shows # of occurrences
    _streak = widget.habit.getStreak();
  }

  Future<void> _updateHabit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habits = prefs.getStringList('habits') ?? [];

    // Update habit fields
    widget.habit.name = _habitName;
    widget.habit.occurrenceNum = _occurrenceController.text!;
    widget.habit.occurrenceType = _occurrenceType!;

    // Convert the Habit object to a String
    String habitString = widget.habit.toString();

    // Update the Habit string in the list and save it in SharedPreferences
    habits[widget.index] = habitString;
    prefs.setStringList('habits', habits);
  }

  Future<void> _completeHabit() async {
    // Add the current date to the habit's completedDates
    widget.habit.addCurrentDate();
    _streak = widget.habit.getStreak();

    // Update the habit in SharedPreferences
    await _updateHabit();
  }

  Future<void> _deleteHabit() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habits = prefs.getStringList('habits') ?? [];

    // Remove the Habit string from the list and save it in SharedPreferences
    habits.removeAt(widget.index);
    prefs.setStringList('habits', habits);
  }

  // Check if the current date is in the list of completed dates
  bool isCurrentDateInList(List<DateTime> dateList) {
    DateTime currentDate = DateTime.now();
    for (DateTime dateInList in dateList) {
      if (dateInList.year == currentDate.year &&
          dateInList.month == currentDate.month &&
          dateInList.day == currentDate.day) {
        return true;
      }
    }
    return false;
  }

  Future<void> _showShareDialog() async {
    var uuid = Uuid();
    String habitUuid = uuid.v4();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('UUID: $habitUuid'),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Enter your Playername'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Share'),
              onPressed: () {
                // TODO: store shared habit in the backend
                Share.share(habitUuid);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentDateCompleted =
        isCurrentDateInList(widget.habit.completedDates);
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed Habit'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Habit'),
                    content:
                        Text('Are you sure you want to delete this habit?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () async {
                          await _deleteHabit();
                          Navigator.of(context).pop();
                          Navigator.pop(context, 'deleted');
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _showShareDialog,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              initialValue: _habitName,
              decoration: InputDecoration(labelText: 'Habit Name'),
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
              decoration: InputDecoration(labelText: 'Occurrence'),
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
                decoration: InputDecoration(labelText: 'Enter number of times'),
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
                  // update the habit
                  await _updateHabit();
                  // TODO: do not close the screen
                  Navigator.pop(context, 'updated');
                }
              },
              child: Text('Update Habit'),
            ),
            Text('Streak: $_streak'),
            if (!isCurrentDateCompleted)
              Dismissible(
                key: Key('SwipeKey'),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {
                  // TODO: include some checks to prevent multiple swipes
                  setState(() {
                    _completeHabit();
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.blue,
                  child: Center(
                      child: Text('Swipe to increase streak',
                          style: TextStyle(color: Colors.white))),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey,
                child: Center(
                    child: Text('You already completed your challenge today!',
                        style: TextStyle(color: Colors.white))),
              ),
          ],
        ),
      ),
    );
  }
}
