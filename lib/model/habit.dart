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

  // Calculate the weekly streak.
  int _calculateWeeklyStreak(DateTime now, int timesPerWeek) {
    int streak = 0;
    int i = 0;

    // get the start and end of the current week (from Monday to Sunday)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    int completedInFirstWeek =
        _calculateHowManyDatesInRange(startOfWeek, endOfWeek);
    // check if this week is completed else go one week back
    // important else streak will be 0 if you do not complete this week
    if (completedDates.isNotEmpty && completedInFirstWeek >= timesPerWeek) {
    } else {
      startOfWeek = startOfWeek.subtract(const Duration(days: 7));
      endOfWeek = endOfWeek.subtract(const Duration(days: 7));
      i = completedInFirstWeek; // ignore the dates in the first week
    }
    for (i; i < completedDates.length; i++) {
      int completedInWeek =
          _calculateHowManyDatesInRange(startOfWeek, endOfWeek);
      if (completedInWeek >= timesPerWeek) {
        streak++;
        startOfWeek = startOfWeek.subtract(const Duration(days: 7));
        endOfWeek = endOfWeek.subtract(const Duration(days: 7));
        i += completedInWeek -
            1; // completedInWeek includes the number of dates in the date, so we skip all dates in the week because they are already analyzed
      } else {
        break;
      }
    }

    return streak;
  }

  // Calculate how many dates are in the range, inclusive start and end dates.
  int _calculateHowManyDatesInRange(DateTime start, DateTime end) {
    return completedDates
        .where((date) =>
            date.isAfter(start.subtract(const Duration(days: 1))) &&
            date.isBefore(end.add(const Duration(days: 1))))
        .length;
  }

  int _calculateMonthlyStreak(DateTime now, int timesPerMonth) {
    int streak = 0;
    int i = 0;

    // get the start and end of the current month (from 1st to last day)
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    print('startOfMonth: $startOfMonth');
    print('endOfMonth: $endOfMonth');

    int completedInFirstWeek =
        _calculateHowManyDatesInRange(startOfMonth, endOfMonth);
    // check if this month is completed else go one month back
    if (completedDates.isNotEmpty && completedInFirstWeek >= timesPerMonth) {
    } else {
      // go back one month
      startOfMonth = _goBackOneMonth(startOfMonth);
      endOfMonth = _goBackOneMonth(endOfMonth);
      print('new startOfMonth: $startOfMonth');
      print('new endOfMonth: $endOfMonth');
      print('completedInFirstWeek: $completedInFirstWeek');
      i = completedInFirstWeek; // ignore the dates in the first week
    }
    for (i; i < completedDates.length; i++) {
      int completedInWeek =
          _calculateHowManyDatesInRange(startOfMonth, endOfMonth);
      if (completedInWeek >= timesPerMonth) {
        streak++;
        startOfMonth = _goBackOneMonth(startOfMonth);
        endOfMonth = _goBackOneMonth(endOfMonth);
        i += completedInWeek -
            1; // completedInWeek includes the number of dates in the date, so we skip all dates in the week because they are already analyzed
      } else {
        break;
      }
    }

    return streak;
  }

  // Go back one month. On January, go back to December of the previous year.
  DateTime _goBackOneMonth(DateTime now) {
    if (now.month == 1) {
      return DateTime(now.year - 1, 12, now.day);
    }
    return DateTime(now.year, now.month - 1, now.day);
  }
}
