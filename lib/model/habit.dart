import 'dart:convert';

class Habit {
  final String id;
  String name;
  String occurrenceType;
  String occurrenceNum;
  List<DateTime> completedDates;
  int highestStreak = 0;

  Habit({
    required this.id,
    required this.name,
    required this.occurrenceType,
    required this.occurrenceNum,
    required this.completedDates,
    highestStreak,
  });

  // Convert a Habit object into a String.
  @override
  String toString() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'occurrence': occurrenceNum,
      'occurrenceType': occurrenceType,
      'completedDates':
          completedDates.map((date) => date.toIso8601String()).toList(),
      'highestStreak': highestStreak,
    };
    return jsonEncode(map);
  }

  // Convert a String into a Habit object.
  static Habit fromString(String habitString) {
    Map<String, dynamic> map = jsonDecode(habitString);
    var completedDatesFromMap = map['completedDates'] as List;
    List<DateTime> completedDates =
        completedDatesFromMap.map((date) => DateTime.parse(date)).toList();
    return Habit(
      id: map['id'],
      name: map['name'],
      occurrenceNum: map['occurrence'],
      occurrenceType: map['occurrenceType'],
      completedDates: completedDates,
      highestStreak: map['highestStreak'],
    );
  }

  // Add the current date as a first element in the completedDates list.
  void addCurrentDate() {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    completedDates.insert(0, date);
  }

  int getStreak() {
    int streak = 0;
    DateTime now = DateTime.now();

    if (occurrenceType == 'Daily') {
      streak = _calculateDailyStreak(now);
    } else if (occurrenceType == 'Weekly') {
      streak = _calculateWeeklyStreak(now, int.parse(occurrenceNum));
    } else if (occurrenceType == 'Monthly') {
      streak = _calculateMonthlyStreak(now, int.parse(occurrenceNum));
    }

    if (streak > highestStreak) {
      highestStreak = streak;
    }
    return streak;
  }

  int _calculateDailyStreak(DateTime now) {
    int streak = 0;
    DateTime currentDate = now;
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // check if today is completed else go one day back
    // important else streak will be 0 if you do not complete today
    if (completedDates.isNotEmpty &&
        completedDates.first.isAtSameMomentAs(currentDate)) {
    } else {
      currentDate = currentDate
          .subtract(const Duration(days: 1)); // start with the day before today
    }

    for (DateTime date in completedDates) {
      if (date.isAtSameMomentAs(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateWeeklyStreak(DateTime now, int timesPerWeek) {
    int streak = 0;
    DateTime startOfWeek = now.subtract(const Duration(days: 7));
    DateTime endOfWeek = now;

    while (
        _countCompletedDatesInRange(startOfWeek, endOfWeek) >= timesPerWeek) {
      streak++;
      startOfWeek = startOfWeek.subtract(const Duration(days: 7));
      endOfWeek = endOfWeek.subtract(const Duration(days: 7));
    }

    return streak;
  }

  int _calculateMonthlyStreak(DateTime now, int timesPerMonth) {
    int streak = 0;
    DateTime startOfMonth = now.subtract(const Duration(days: 30));
    DateTime endOfMonth = now;

    while (_countCompletedDatesInRange(startOfMonth, endOfMonth) >=
        timesPerMonth) {
      streak++;
      startOfMonth = startOfMonth.subtract(const Duration(days: 30));
      endOfMonth = endOfMonth.subtract(const Duration(days: 30));
    }

    return streak;
  }

  int _countCompletedDatesInRange(DateTime start, DateTime end) {
    return completedDates
        .where((date) =>
            date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1))))
        .length;
  }
}
