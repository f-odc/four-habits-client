import 'package:flutter/material.dart';
import 'package:four_habits_client/model/habit.dart';

import '../../components/custom_card.dart';
import '../../components/custom_divider.dart';
import '../../components/habit_tile.dart';
import '../../services/shared_preferences_service.dart';
import 'detailed_habit_logic.dart';
import 'edit_habit_screen.dart';

// TODO: check if habit can be made final
// ignore: must_be_immutable
class DetailedHabitScreen extends StatefulWidget {
  Habit habit;
  final int index;

  DetailedHabitScreen({Key? key, required this.habit, required this.index})
      : super(key: key);

  @override
  _DetailedHabitScreenState createState() => _DetailedHabitScreenState();
}

class _DetailedHabitScreenState extends State<DetailedHabitScreen> {
  final DetailedHabitLogic _habitLogic = DetailedHabitLogic();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _habitNameController;
  late TextEditingController _occurrenceController;
  final pref = SharedPreferencesService();
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController(text: widget.habit.name);
    _occurrenceController =
        TextEditingController(text: widget.habit.occurrenceNum);
    // Check if the habit was completed today
    List<DateTime> lastCompletedDate = widget.habit.completedDates;
    if (lastCompletedDate.isNotEmpty) {
      DateTime now = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      if (lastCompletedDate.first.isAtSameMomentAs(now)) {
        _isDismissed = true;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
    setState(() {
      widget.habit = pref.getHabit(widget.index);
      _habitNameController.text = widget.habit.name;
      _occurrenceController.text = widget.habit.occurrenceNum;
    });
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    _occurrenceController.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Delete Habit",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this habit?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    _habitLogic.deleteHabit(widget.index);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Column(
          children: [
            AppBar(
              iconTheme: const IconThemeData(
                  color: Colors.orange), // Set back button color to orange
              title: Text(
                "Habit View",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              centerTitle: true, // Center the title
              elevation: 0, // Add a small shadow
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: Colors.orange,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHabitScreen(
                          habit: widget.habit,
                          index: widget.index,
                        ),
                      ),
                    ).then((value) => _loadHabit());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.orange,
                  onPressed: () {
                    _showDeleteConfirmationDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // HABIT CARD PREVIEW
              HabitTile(
                habitName: _habitNameController.text,
                occurrenceType: widget.habit.occurrenceType,
                occurrenceNum: _occurrenceController.text,
                streak: widget.habit.getStreak(),
              ),
              const SizedBox(height: 4),
              // HABIT OPTIONS
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCard(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: null,
                    cardColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow, // TODO: create color file
                    cardText: 'Highest Streak:',
                    cardTextColor: null,
                    trailingIcon: Icons.local_fire_department,
                    trailingIconColor: Colors.orange,
                    trailingText: widget.habit.highestStreak.toString(),
                  ),
                  const SizedBox(height: 4),
                  // TODO: Make CustomCard clickable
                  Card(
                    color: Colors.orange[100],
                    child: ListTile(
                      leading: const Icon(Icons.share, color: Colors.orange),
                      title: const Text(
                        'Challenge Your Friends!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 20.0,
                        ),
                      ),
                      onTap: () {
                        _habitLogic.shareHabit(widget.habit);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const CustomDivider(height: 1),
              // COMPLETE HABIT
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CustomDivider(height: 1),
                      const SizedBox(height: 8),
                      _isDismissed
                          ? CustomCard(
                              // DISPLAY CARD IF HABIT IS DISMISSED
                              icon: Icons.check,
                              iconColor: Colors.orange,
                              cardColor: null,
                              cardText: 'Habit Already Completed!',
                              cardTextColor: Colors.orange,
                              trailingIcon: Icons.check,
                              trailingIconColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              //centerText: true,
                            )
                          : Dismissible(
                              // DISPLAY DISMISSIBLE CARD
                              key: const Key('add-date-swipe'),
                              direction: DismissDirection.startToEnd,
                              onDismissed: (direction) {
                                setState(() {
                                  widget.habit.addCurrentDate();
                                  print(widget.habit.completedDates);
                                  pref.updateHabit(
                                      widget.habit,
                                      widget
                                          .index); // Update habit in shared preferences
                                  _isDismissed = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Hurrah! You completed your habit today! Keep the streak going!'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              background: CustomCard(
                                icon: Icons.check,
                                iconColor: Colors.orange[100],
                                cardColor: Colors.orange,
                                cardText: '',
                                cardTextColor: Colors.orange,
                              ),
                              child: CustomCard(
                                icon: Icons.swipe_right,
                                iconColor: Colors.orange,
                                cardColor: Colors.orange[100],
                                cardText: 'Swipe to complete Habit',
                                cardTextColor: Colors.orange,
                                trailingIcon: Icons.swipe_right,
                                trailingIconColor: Colors.orange[100],
                                centerText: true,
                              ),
                            ),
                      const SizedBox(height: 30), // Adjust the height as needed
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
