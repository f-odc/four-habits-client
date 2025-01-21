import 'package:flutter_test/flutter_test.dart';
import 'package:four_habits_client/model/habit.dart';

void main() {
  DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime nowMinus1 = now.subtract(const Duration(days: 1));
  DateTime nowMinus2 = now.subtract(const Duration(days: 2));
  DateTime nowMinus3 = now.subtract(const Duration(days: 3));
  DateTime nowMinus4 = now.subtract(const Duration(days: 4));
  DateTime nowMinus7 = now.subtract(const Duration(days: 7));
  DateTime nowMinus8 = now.subtract(const Duration(days: 8));

  group('Habit getStreak', () {
    test('Empty list', () {
      Habit habit = Habit(
        id: '1',
        name: 'Daily Habit',
        occurrenceType: 'Daily',
        occurrenceNum: '1',
        completedDates: [],
      );

      expect(habit.getStreak(), 0);
    });

    test('Daily streak calculation - Normal', () {
      Habit habit = Habit(
        id: '2',
        name: 'Daily Habit',
        occurrenceType: 'Daily',
        occurrenceNum: '1',
        completedDates: [
          now,
          nowMinus1,
          nowMinus2,
        ],
      );

      expect(habit.getStreak(), 3);
    });

    test('Daily streak calculation - Skipped the first day', () {
      Habit habit = Habit(
        id: '3',
        name: 'Daily Habit',
        occurrenceType: 'Daily',
        occurrenceNum: '1',
        completedDates: [
          nowMinus1,
          nowMinus2,
        ],
      );

      expect(habit.getStreak(), 2);
    });

    test('Daily streak calculation - Skipped another day', () {
      Habit habit = Habit(
        id: '3',
        name: 'Daily Habit',
        occurrenceType: 'Daily',
        occurrenceNum: '1',
        completedDates: [
          now,
          nowMinus2,
        ],
      );

      expect(habit.getStreak(), 1);
    });

    test('Weekly streak calculation - Empty', () {
      Habit habit = Habit(
        id: '3',
        name: '3 times the Week - Habit',
        occurrenceType: 'Weekly',
        occurrenceNum: '3',
        completedDates: [],
      );

      expect(habit.getStreak(), 0);
    });

    test('Weekly streak calculation - Normal', () {
      Habit habit = Habit(
        id: '3',
        name: '3 times the Week - Habit',
        occurrenceType: 'Weekly',
        occurrenceNum: '3',
        completedDates: [
          now,
          nowMinus1,
          nowMinus2,
        ],
      );

      expect(habit.getStreak(), 1);
    });
  });
}
