import 'package:four_habits_client/services/shared_preferences_service.dart';
import '../../model/habit.dart';
import '../../model/move.dart';

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
}
