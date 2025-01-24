import 'package:uuid/uuid.dart';

import '../../model/habit.dart';
import '../../services/shared_preferences_service.dart';

class CreateHabitLogic {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  Future<void> saveHabit(
      String habitName, String occurrenceType, String occurrenceNum) async {
    // Default occurrenceNum to '1' if it is empty
    if (occurrenceNum.isEmpty) {
      occurrenceNum = '1';
    }

    // Create a new Habit object
    Habit habit = Habit(
      id: const Uuid().v4().toString(),
      name: habitName,
      occurrenceType: occurrenceType,
      occurrenceNum: occurrenceNum,
      completedDates: [],
    );

    // add habit
    _prefsService.addHabit(habit);
  }
}
