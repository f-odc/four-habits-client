import 'dart:convert';

class Habit {
  final String id;
  String name;
  String occurrenceType;
  String occurrenceNum;
  List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.name,
    required this.occurrenceType,
    required this.occurrenceNum,
    required this.completedDates,
  });

  // Convert a Habit object into a String.
  String toString() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'occurrence': occurrenceNum,
      'occurrenceType': occurrenceType,
      'completedDates':
          completedDates.map((date) => date.toIso8601String()).toList(),
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
    );
  }

  // Method to add the current date
  void addCurrentDate() {
    completedDates.add(DateTime.now());
  }

  int getStreak() {
    int streak = 0;

    if (completedDates.isEmpty) {
      return streak;
    }

    if (occurrenceNum.contains('Daily')) {
      DateTime currentDate = DateTime.now();
      // calculate the streak as the number of reoccurring dates without a day in between
      for (int i = completedDates.length - 1; i >= 0; i--) {
        if (currentDate.difference(completedDates[i]).inDays > 1) {
          // if the last date is over the allowed time difference, the streak is 0
          if (i == completedDates.length - 1) {
            return 0;
          }
          break;
        }
        streak++;
      }
      return streak;
    }

    // TODO: implement streak calculation for weekly and monthly habits

    return streak;
  }
}
