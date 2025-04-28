import 'package:flutter/material.dart';
import 'package:four_habits_client/styles.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final String occurrenceType;
  final String occurrenceNum;
  final int streak;
  final int currentCompletedTimes;
  final bool highlight;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.occurrenceType,
    required this.occurrenceNum,
    required this.currentCompletedTimes,
    required this.streak,
    this.highlight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: highlight
            ? BorderSide(color: Style.cardColorOrange, width: 3.0)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(
          '$habitName',
          style: Style.cardTextStyle,
        ),
        subtitle: Text(
          occurrenceType == 'Daily'
              ? 'Occurrence: $occurrenceType'
              : occurrenceType == 'Weekly' || occurrenceType == 'Monthly'
                  ? 'Occurrence: $occurrenceType $currentCompletedTimes/$occurrenceNum'
                  : 'Occurrence:',
          style: TextStyle(
            fontSize: Style.cardSubTextSize,
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '$streak',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Style.cardTextSize,
              ),
            ),
            const Icon(Icons.local_fire_department, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
