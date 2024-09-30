import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../components/connect_four_game.dart';
import '../../model/challenge.dart';
import '../../model/habit.dart';
import '../../websocket/websocket_client.dart';

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
  Challenge? _challenge;
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
    _loadChallenge();
  }

  Future<void> _loadChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> challenges = prefs.getStringList('challenges') ?? [];
    for (String challengeString in challenges) {
      Challenge challenge = Challenge.fromString(challengeString);
      if (challenge.habitId == widget.habit.id) {
        setState(() {
          _challenge = challenge;
        });
        break;
      }
    }
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

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Share Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('UUID: ${widget.habit.id}'),
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
              onPressed: () async {
                // Create a Challenge object with an empty board
                Challenge challenge = Challenge(
                  habitId: widget.habit.id,
                  habitName: widget.habit.name,
                  habitOccurrenceType: widget.habit.occurrenceType,
                  habitOccurrenceNum: widget.habit.occurrenceNum,
                  board: List.generate(6, (_) => List.filled(7, 0)), // 6x7 empty board
                  challengerID: 1,
                );
                _challenge = challenge;
                log('Challenge: $challenge');

                // TODO: do we want to save the challenge in the shared preferences?
                // Save the Challenge object (this example uses SharedPreferences)
                final prefs = await SharedPreferences.getInstance();
                List<String> challenges = prefs.getStringList('challenges') ?? [];
                challenges.add(challenge.toString());
                prefs.setStringList('challenges', challenges);

                // Send the challenge
                await WebSocketClient.post('http://192.168.0.112:8080', challenge.toJson());

                Share.share(widget.habit.id);
                Navigator.of(context).pop();
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
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
            ),
            if (_occurrenceType != 'Daily' && _occurrenceType != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
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
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Streak: $_streak'),
            ),
            // Connect Four board
            if (_challenge != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConnectFourGame(
                  challenge: _challenge,
                  isCurrentDateCompleted: isCurrentDateCompleted,
                ),
              ),
            // Swipe to complete the habit widget
            if (!isCurrentDateCompleted)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Dismissible(
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
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  color: Colors.grey,
                  child: Center(
                      child: Text('You already completed your challenge today!',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
