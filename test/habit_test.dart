import 'package:flutter_test/flutter_test.dart';
import 'package:four_habits_client/model/habit.dart';

void main() {
  DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  DateTime nowDaily = now;
  DateTime nowMinus1Daily = now.subtract(const Duration(days: 1));
  DateTime nowMinus2Daily = now.subtract(const Duration(days: 2));
  // ---------------------------------------------------------------------
  now = now.add(Duration(days: 6 - now.weekday)); // Start from Monday
  DateTime nowMinus1 = now.subtract(const Duration(days: 1));
  DateTime nowMinus2 = now.subtract(const Duration(days: 2));
  DateTime nowMinus7 = now.subtract(const Duration(days: 7));
  DateTime nowMinus8 = now.subtract(const Duration(days: 8));
  DateTime nowMinus9 = now.subtract(const Duration(days: 9));
  DateTime nowMinus10 = now.subtract(const Duration(days: 10));
  DateTime nowMinus11 = now.subtract(const Duration(days: 11));
  DateTime nowMinus12 = now.subtract(const Duration(days: 12));
  DateTime nowMinus16 = now.subtract(const Duration(days: 16));
  DateTime nowMinus30 = now.subtract(const Duration(days: 30));
  DateTime nowMinus31 = now.subtract(const Duration(days: 31));
  DateTime nowMinus32 = now.subtract(const Duration(days: 32));

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
          nowDaily,
          nowMinus1Daily,
          nowMinus2Daily,
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
          nowMinus1Daily,
          nowMinus2Daily,
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
          nowDaily,
          nowMinus2Daily,
        ],
      );

      expect(habit.getStreak(), 1);
    });

    // ---------------------------------------------------------------------

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

    test('Weekly 3 Streak calculation - One week completed', () {
      Habit habit = Habit(
        id: '3',
        name: '',
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

    test('Weekly 3 Streak calculation - No complete Week', () {
      Habit habit = Habit(
        id: '3',
        name: '',
        occurrenceType: 'Weekly',
        occurrenceNum: '3',
        completedDates: [
          nowMinus1,
          nowMinus2,
        ],
      );

      expect(habit.getStreak(), 0);
    });

    test('Weekly 3 Streak calculation - In current week, one week completed',
        () {
      Habit habit = Habit(
        id: '3',
        name: '',
        occurrenceType: 'Weekly',
        occurrenceNum: '3',
        completedDates: [
          nowMinus1,
          nowMinus2,
          nowMinus8,
          nowMinus10,
          nowMinus12,
        ],
      );

      expect(habit.getStreak(), 1);
    });

    test('Weekly 3 Streak calculation - Two weeks completed', () {
      Habit habit = Habit(
        id: '3',
        name: '',
        occurrenceType: 'Weekly',
        occurrenceNum: '3',
        completedDates: [
          now,
          nowMinus1,
          nowMinus2,
          nowMinus7,
          nowMinus8,
          nowMinus12,
        ],
      );

      expect(habit.getStreak(), 2);
    });
  });

  test(
      'Weekly 6 Streak calculation - In current week, 1 weeks completed, more then occurrence num',
      () {
    Habit habit = Habit(
      id: '3',
      name: '',
      occurrenceType: 'Weekly',
      occurrenceNum: '4',
      completedDates: [
        nowMinus1,
        nowMinus2,
        nowMinus7,
        nowMinus8,
        nowMinus9,
        nowMinus10,
        nowMinus11,
        nowMinus12,
        nowMinus16,
        nowMinus30,
      ],
    );

    expect(habit.getStreak(), 1);
  });

  // ---------------------------------------------------------------------

  test('Monthly streak calculation - Empty', () {
    Habit habit = Habit(
      id: '3',
      name: 'Monthly Habit',
      occurrenceType: 'Monthly',
      occurrenceNum: '1',
      completedDates: [],
    );

    expect(habit.getStreak(), 0);
  });

  test('Monthly streak calculation - Normal', () {
    Habit habit = Habit(
      id: '3',
      name: 'Monthly Habit',
      occurrenceType: 'Monthly',
      occurrenceNum: '2',
      completedDates: [
        now,
        nowMinus1,
        nowMinus2,
      ],
    );

    expect(habit.getStreak(), 1);
  });

  test('Monthly streak calculation - In current Month', () {
    Habit habit = Habit(
      id: '3',
      name: 'Monthly Habit',
      occurrenceType: 'Monthly',
      occurrenceNum: '2',
      completedDates: [
        nowMinus2,
        nowMinus31,
        nowMinus32,
      ],
    );

    expect(habit.getStreak(), 1);
  });

  test(
      'Monthly streak calculation - 2 Months completed, more than occurrence num',
      () {
    Habit habit = Habit(
      id: '3',
      name: 'Monthly Habit',
      occurrenceType: 'Monthly',
      occurrenceNum: '1',
      completedDates: [
        nowMinus2,
        nowMinus16,
        nowMinus31,
        nowMinus32,
      ],
    );

    expect(habit.getStreak(), 2);
  });
}
