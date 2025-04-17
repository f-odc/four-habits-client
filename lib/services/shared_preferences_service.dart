import 'package:flutter/material.dart';
import 'package:four_habits_client/model/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/challenge.dart';
import '../model/profile.dart';

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

  Future<void> setProfile(Profile profile) async {
    await _preferences?.setString('profile', profile.toString());
  }

  Profile getProfile() {
    String? profileString = _preferences?.getString('profile');
    return Profile.fromString(profileString ?? '');
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

  // TODO: store for each challenge canPerformMove
  // Set a boolean value
  Future<void> setChallengeBool(String key, bool value) async {
    print("SharedPreferences: setChallengeBool: $key = $value");
    await _preferences?.setBool(key, value);
  }

  // Get a boolean value
  Future<bool> getChallengeBool(String key) async {
    print("SharedPreferences: getChallengeBool: ${_preferences?.getBool(key)}");
    return _preferences?.getBool(key) ?? false;
  }

  Future<void> addChallenge(Challenge challenge) async {
    // delete challenge list
    //_preferences?.remove('challenges');

    print('Adding challenge: $challenge');
    List<String> challengeList =
        _preferences?.getStringList('challenges') ?? [];
    challengeList.add(challenge.toString());
    print('Challenge list: $challengeList');
    await _preferences?.setStringList('challenges', challengeList);
  }

  Future<void> updateChallenge(Challenge challenge) async {
    print('Updating challenge: $challenge');
    List<String> challengeList =
        _preferences?.getStringList('challenges') ?? [];
    for (var storedChallenge in challengeList) {
      var storedChallengeObject = Challenge.fromString(storedChallenge);
      if (storedChallengeObject.id == challenge.id) {
        challengeList.remove(storedChallenge);
        challengeList.add(challenge.toString());
        await _preferences?.setStringList('challenges', challengeList);
        return;
      }
    }
  }

  Challenge? getChallengeFromHabit(String habitID) {
    print('Getting challenge with id: $habitID');
    List<String> challengeList =
        _preferences?.getStringList('challenges') ?? [];
    for (var challengeString in challengeList) {
      var challenge = Challenge.fromString(challengeString);
      if (challenge.habitId == habitID) {
        return challenge;
      }
    }
    return null;
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
