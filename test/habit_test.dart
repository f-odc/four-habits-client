import 'package:flutter_test/flutter_test.dart';
import 'package:four_habits_client/model/habit.dart';

void main() {
  group('Habit getStreak', () {
    test('Daily streak calculation', () {
      Habit habit = Habit(
        id: '1',
        name: 'Daily Habit',
        occurrenceType: 'Daily',
        occurrenceNum: '1',
        completedDates: [
          DateTime.now(),
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now().subtract(const Duration(days: 2)),
        ],
      );

      expect(habit.getStreak(), 3);
    });

    test('3 times a week streak calculation', () {
      Habit habit = Habit(
        id: '2',
        name: '3 Times a Week Habit',
        occurrenceType: 'Weekly',
        occurrenceNum: '3',
        completedDates: [
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 3)),
          DateTime.now().subtract(const Duration(days: 8)),
          DateTime.now().subtract(const Duration(days: 9)),
          DateTime.now().subtract(const Duration(days: 10)),
        ],
      );

      expect(habit.getStreak(), 2);
    });

    test('6 times a week streak calculation', () {
      Habit habit = Habit(
        id: '3',
        name: '6 Times a Week Habit',
        occurrenceType: 'Weekly',
        occurrenceNum: '6',
        completedDates: [
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now().subtract(const Duration(days: 2)),
          DateTime.now().subtract(const Duration(days: 3)),
          DateTime.now().subtract(const Duration(days: 4)),
          DateTime.now().subtract(const Duration(days: 5)),
          DateTime.now().subtract(const Duration(days: 6)),
          DateTime.now().subtract(const Duration(days: 8)),
          DateTime.now().subtract(const Duration(days: 9)),
          DateTime.now().subtract(const Duration(days: 10)),
          DateTime.now().subtract(const Duration(days: 11)),
          DateTime.now().subtract(const Duration(days: 12)),
          DateTime.now().subtract(const Duration(days: 13)),
        ],
      );

      expect(habit.getStreak(), 2);
    });
  });

}