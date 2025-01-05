import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../model/habit.dart';

class CreateHabitLogic {
  Future<void> saveHabit(String habitName, String occurrenceType, String occurrenceNum) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> habits = prefs.getStringList('habits') ?? [];

    // Create a new Habit object
    Habit habit = Habit(
      id: const Uuid().v4().toString(),
      name: habitName,
      occurrenceType: occurrenceType,
      occurrenceNum: occurrenceNum,
      completedDates: [],
    );

    // Convert the Habit object to a String
    String habitString = habit.toString();

    // Add the Habit string to the list and save it in SharedPreferences
    habits.add(habitString);
    prefs.setStringList('habits', habits);
  }
}