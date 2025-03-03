import 'package:flutter/material.dart';
import 'package:four_habits_client/components/custom_card.dart';
import 'package:four_habits_client/components/custom_divider.dart';
import 'package:four_habits_client/components/habit_tile.dart';
import 'package:four_habits_client/pages/notification_settings_screen.dart';

import '../model/habit.dart';
import '../model/profile.dart';
import '../services/shared_preferences_service.dart';
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
                color: Colors.orange),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CustomCard(
                icon: Icons.add,
                iconColor: Colors.orange,
                cardColor: Colors.orange[100],
                cardText: 'Create New Habit',
                cardTextColor: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 6),
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
