import 'package:uuid/uuid.dart';
import '../../model/habit.dart';
import '../../services/shared_preferences_service.dart';

class CreateHabitLogic {
  final SharedPreferencesService _prefsService = SharedPreferencesService();

  Future<void> saveHabit(String habitName, String occurrenceType, String occurrenceNum) async {
    await _prefsService.init();

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