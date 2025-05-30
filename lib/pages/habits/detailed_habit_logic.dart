import 'dart:convert';

import 'package:four_habits_client/services/shared_preferences_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../model/challenge.dart';
import '../../model/habit.dart';
import '../../model/move.dart';
import '../../websocket/websocket_client.dart';

class DetailedHabitLogic {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  Future<void> updateHabit(Habit habit, int index) async {
    await _prefsService.updateHabit(habit, index);
  }

  Future<void> deleteHabit(int index) async {
    await _prefsService.deleteHabit(index);
  }

  Future<void> completeHabit(
      Habit habit, int index, Move? challengeMove) async {
    // Add the current date to the habit's completedDates
    habit.addCurrentDate();

    // Update the habit in SharedPreferences
    await updateHabit(habit, index);
  }

  Future<void> shareHabit(Habit habit) async {
    var uuid = Uuid();

    // get profile
    var profile = _prefsService.getProfile();

    Challenge challenge = Challenge(
      id: uuid.v4(),
      challenger: profile.name,
      challengerID: profile.id,
      lastMoverID: profile.id,
      board:
          List.generate(6, (_) => List.filled(7, 0)), // Initialize empty board
      canPerformMove: true,
      habitId: habit.id,
      habitName: habit.name,
      habitOccurrenceType: habit.occurrenceType,
      habitOccurrenceNum: habit.occurrenceNum,
    );

    _prefsService.addChallenge(challenge);

    Share.share('${challenge.id}');

    await WebSocketClient.post(challenge.toJson());
  }

  Future<Challenge?> getChallenge(String habitID) async {
    var challenge = _prefsService.getChallengeFromHabit(habitID);
    if (challenge == null) {
      print("Challenge not found");
      return null;
    }
    print("Challenge in SharedPreferences: $challenge");

    // load challenge from server and update challenge
    final String response = await WebSocketClient.get(challenge.id);
    print("Response: $response");

    // Check if the response contains an error message
    // TODO: delete
    final Map<String, dynamic> json = jsonDecode(response);
    if (json.containsKey("error")) {
      print("Error: ${json["error"]}");
      return null;
    }

    challenge = Challenge.fromJson(json);
    print("Retrieved challenge: $challenge");
    _prefsService.updateChallenge(challenge);

    return challenge;
  }

  // TODO: bool checkIfActive(Challenge challenge)
}
