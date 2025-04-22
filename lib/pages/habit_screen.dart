import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:four_habits_client/components/custom_card.dart';
import 'package:four_habits_client/components/custom_divider.dart';
import 'package:four_habits_client/components/habit_tile.dart';
import 'package:four_habits_client/pages/notification_settings_screen.dart';
import 'package:four_habits_client/styles.dart';

import '../model/challenge.dart';
import '../model/habit.dart';
import '../model/profile.dart';
import '../services/shared_preferences_service.dart';
import '../websocket/websocket_client.dart';
import 'habits/create_habit_screen.dart';
import 'habits/detailed_habit_screen.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<Habit> _habits = [];
  Profile _profile = Profile(id: '', name: '');
  final pref = SharedPreferencesService();
  DateTime now = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day); // Date without time
  late bool _notificationEnabled = false;
  late TimeOfDay _notificationTime;
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabit();
    _loadProfile();
    _loadNotificationSettings();
  }

  bool isCompletedToday(Habit habit) {
    if (habit.completedDates.isNotEmpty &&
        habit.completedDates.first.isAtSameMomentAs(now)) {
      return true;
    }
    return false;
  }

  Future<void> _loadHabit() async {
    setState(() {
      _habits = pref.getHabits();
    });
  }

  Future<void> _loadProfile() async {
    setState(() {
      _profile = pref.getProfile();
    });
  }

  Future<void> _loadNotificationSettings() async {
    final (notificationStatus, notificationTime) =
        await pref.getNotificationSettings();
    setState(() {
      _notificationEnabled = notificationStatus;
      _notificationTime = notificationTime;
    });
  }

  Future<void> _loadChallenge(String id) async {
    // TODO: use own function for this
    print('User entered ID: $id');
    final String response = await WebSocketClient.get(id);
    final Map<String, dynamic> json = jsonDecode(response);
    if (json.containsKey("error")) {
      print("Error: ${json["error"]}");
      return null;
    }

    Challenge challenge = Challenge.fromJson(json);
    print("Retrieved challenge: $challenge");

    // TODO: create habit from challenge
    Habit newHabit = Habit(
      id: challenge.habitId,
      name: challenge.habitName,
      occurrenceType: challenge.habitOccurrenceType,
      occurrenceNum: challenge.habitOccurrenceNum,
      completedDates: [],
      highestStreak: 0,
    );
    // TODO: create own challenge from challenge
    Challenge newChallenge = Challenge(
      id: challenge.id,
      challenger: challenge.challenger,
      challengerID: challenge.challengerID,
      lastMoverID: challenge.lastMoverID,
      board: challenge.board,
      canPerformMove: true,
      habitId: newHabit.id,
      habitName: newHabit.name,
      habitOccurrenceType: newHabit.occurrenceType,
      habitOccurrenceNum: newHabit.occurrenceNum,
    );

    setState(() {
      pref.addHabit(newHabit);
      _loadHabit();
      pref.addChallenge(newChallenge);
      pref.setChallengeBool(newChallenge.id, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
                _notificationEnabled
                    ? Icons.notifications
                    : Icons.notifications_none_outlined,
                color: Style.orange),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationSettingsScreen(
                    initialEnableNotifications: _notificationEnabled,
                    initialNotificationTime: _notificationTime,
                  ),
                ),
              );
              // update notification settings to update the icon when the user returns
              if (result == true) {
                _loadNotificationSettings();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
              height: 10), // Adjust this value to move the AppBar further down
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome ${_profile.name}',
                  style: Style.titleTextStyle,
                ),
                const Text(
                  '“Great habits are the foundation of great achievements.”',
                  style: Style.subtitleTextStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // CREATE NEW HABIT CARD
          GestureDetector(
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCard(
                icon: Icons.add,
                iconColor: Style.orange,
                cardColor: Style.cardColorOrange,
                cardText: 'Create New Habit',
                cardTextColor: Style.textColor,
              ),
            ),
          ),
          // JOIN CHALLENGE CARD
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Add Challenge ID',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      content: TextField(
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter ID here',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                        ElevatedButton(
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            String enteredID = _idController.text;
                            _loadChallenge(enteredID);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Challenge added if ID is correct! Good Luck!'),
                                backgroundColor: Style.orange,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomCard(
                icon: Icons.add,
                iconColor: Style.orange,
                cardColor: Style.cardColorOrange,
                cardText: 'Join Challenge',
                cardTextColor: Style.textColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const CustomDivider(height: 1), // Top divider
          const SizedBox(height: 12),
          // HABIT LIST
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, // Remove padding
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                // Habit cards
                final habit = _habits[index];
                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedHabitScreen(
                          habit: habit,
                          index: index,
                        ),
                      ),
                    );
                    _loadHabit();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0.0),
                    // HABIT TILE
                    child: HabitTile(
                      habitName: habit.name,
                      occurrenceType: habit.occurrenceType,
                      occurrenceNum: habit.occurrenceNum,
                      streak: habit.getStreak(),
                      highlight: !isCompletedToday(habit),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12), // Adjust the height as needed
          const CustomDivider(height: 1), // Bottom divider
          const SizedBox(height: 30), // Adjust the height as needed
        ],
      ),
    );
  }
}
