import 'package:flutter/material.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final String occurrenceType;
  final String occurrenceNum;
  final int streak;

  const HabitTile({
    Key? key,
    required this.habitName,
    required this.occurrenceType,
    required this.occurrenceNum,
    required this.streak,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline),
        title: Text(
          'Habit: $habitName',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        subtitle: Text(
          occurrenceType == 'Daily'
              ? 'Occurrence: $occurrenceType'
              : 'Occurrence: $occurrenceType - $occurrenceNum',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const Icon(Icons.local_fire_department, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}