import 'package:flutter/material.dart';
import 'package:four_habits_client/model/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();
  SharedPreferences? _preferences;

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Set and get firstVisit
  Future<void> setFirstVisit(bool value) async {
    await _preferences?.setBool('firstVisit', value);
  }

  bool? getFirstVisit() {
    return _preferences?.getBool('firstVisit');
  }

  // Set and get username
  Future<void> setUsername(String value) async {
    await _preferences?.setString('username', value);
  }

  String? getUsername() {
    return _preferences?.getString('username');
  }

  // Set habit list
  Future<void> setHabits(List<String> value) async {
    await _preferences?.setStringList('habits', value);
  }

  // Add habit to habit list
  Future<void> addHabit(Habit habit) async {
    // Get the current list of habits
    List<String> habits = _preferences?.getStringList('habits') ?? [];
    // Add the new habit to the list
    habits.add(habit.toString());
    // Save the updated list
    await _preferences?.setStringList('habits', habits);
  }

  Future<void> updateHabit(Habit habit, int index) async {
    List<String> habits = _preferences?.getStringList('habits') ?? [];
    habits[index] = habit.toString();
    await _preferences?.setStringList('habits', habits);
  }

  Future<void> deleteHabit(int index) async {
    List<String> habits = _preferences?.getStringList('habits') ?? [];
    habits.removeAt(index);
    await _preferences?.setStringList('habits', habits);
  }

  Habit getHabit(int index) {
    List<String> habitList = _preferences?.getStringList('habits') ?? [];
    return Habit.fromString(habitList[index]);
  }

  // get habit list
  List<Habit> getHabits() {
    List<String> habitList = _preferences?.getStringList('habits') ?? [];
    List<Habit> habits = [];
    for (var habitString in habitList) {
      habits.add(Habit.fromString(habitString));
    }
    return habits;
  }

  void storeNotificationSettings(
      bool enableNotifications, TimeOfDay notificationTime) {
    _preferences?.setBool('enableNotifications', enableNotifications);
    _preferences?.setInt('notificationHour', notificationTime.hour);
    _preferences?.setInt('notificationMinute', notificationTime.minute);
  }

  (bool, TimeOfDay) getNotificationSettings() {
    bool enableNotifications =
        _preferences?.getBool('enableNotifications') ?? true;
    int hour = _preferences?.getInt('notificationHour') ?? 18;
    int minute = _preferences?.getInt('notificationMinute') ?? 0;
    return (enableNotifications, TimeOfDay(hour: hour, minute: minute));
  }
}
