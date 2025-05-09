import 'package:flutter/material.dart';
import 'package:four_habits_client/components/connect_four_game.dart';
import 'package:four_habits_client/model/habit.dart';
import 'package:four_habits_client/styles.dart';

import '../../components/custom_card.dart';
import '../../components/custom_divider.dart';
import '../../components/habit_tile.dart';
import '../../model/challenge.dart';
import '../../services/shared_preferences_service.dart';
import 'detailed_habit_logic.dart';
import 'edit_habit_screen.dart';

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
  Challenge? _challenge = null;
  bool _canPerformMove = false;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController(text: widget.habit.name);
    _occurrenceController =
        TextEditingController(text: widget.habit.occurrenceNum);

    _loadChallenge(widget.habit.id);

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

  Future<void> _loadChallenge(String id) async {
    print("Loading challenge for habit $id");

    var challenge = await _habitLogic.getChallenge(id);
    print("Challenge: $challenge");

    if (challenge == null) {
      return;
    }

    var profile = pref.getProfile();
    // Check if the challenge is active
    var correctTime = false;
    DateTime now = DateTime.now();
    if (now.hour >= 20 && now.minute > 0) {
      correctTime = true;
    }
    print("is correct time: $correctTime");

    bool canPerform = await pref.getChallengeBool(challenge.id);

    setState(() {
      _challenge = challenge;
      if (_challenge == null) {
        return;
      }
      // check if the habit was completed and no challenge move was performed
      _canPerformMove = canPerform;
      var yourTurn = _challenge!.lastMoverID != profile.id;
      if (_canPerformMove && (yourTurn || correctTime)) {
        _isActive = true;
      }
    });
    print("Can perform move: $_canPerformMove");
    print("Challenge is Active: $_isActive");
    print("Challenge completed today: ${completedToday()}");
  }

  bool completedToday() {
    DateTime now =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (widget.habit.completedDates.isNotEmpty &&
        widget.habit.completedDates.first.isAtSameMomentAs(now)) {
      return true;
    }
    return false;
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
            ElevatedButton(
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
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Title
            Text(
              'Page Info',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Style.orange,
              ),
            ),
            Divider(thickness: 1),
            SizedBox(height: 8),
            // First Section
            Text(
              'When does the current streak increase?',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Your streak increases when you complete your habit the required number of times within the set timeframe. For example, if your habit is to be completed twice a week, your streak will only grow if you achieve this goal within the week.',
            ),
            SizedBox(height: 12),
            Text(
              'How to challenge someone?',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Click on the "Challenge Your Friends!" button and share the given ID with your friends. With this ID they can join your Challenge by clicking on the "Join Challenge" button in the main menu',
            ),
            SizedBox(height: 12),
            Text(
              'When can make a move in the Connect Four game?',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'If your habit is completed (see "When does the current streak increase?"), you can make a move in the Connect Four game. If you completed your habit successfully but it is not your turn because your opponent has not played yet, you have to wait till 20:00 to make a move, so the opponent gets the chance to catch up.',
            ),
            SizedBox(height: 12),
          ],
        ),
        actions: [
          TextButton(
            child: const Text(
              'Close',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
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
                  // INFO POPUP
                  icon: Icon(
                    Icons.info_outline,
                    color: Style.orange,
                  ),
                  onPressed: () => _showInfoDialog(context),
                ),
                IconButton(
                  // EDIT
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
                  // DELETE
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
      body: RefreshIndicator(
        onRefresh: () => _loadChallenge(widget.habit.id),
        child: Padding(
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
                  currentCompletedTimes:
                      widget.habit.getCompletedCurrentEpoch(),
                ),
                const SizedBox(height: 4),
                // HABIT OPTIONS
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomCard(
                      icon: Icons.local_fire_department_outlined,
                      iconColor: null,
                      cardColor: Style.getBackgroundColor(context),
                      cardText: 'Highest Streak:',
                      cardTextColor: null,
                      trailingIcon: Icons.local_fire_department,
                      trailingIconColor: Colors.orange,
                      trailingText: widget.habit.highestStreak.toString(),
                    ),
                    const SizedBox(height: 4),
                    // SHARE HABIT
                    // TODO: Make CustomCard clickable
                    Card(
                      color: Style.cardColorOrange,
                      child: ListTile(
                        leading: const Icon(Icons.share, color: Colors.orange),
                        title: const Text(
                          'Challenge Your Friends!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Style.orange,
                            fontSize: Style.cardTextSize,
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
                // CONNECT FOUR BOARD
                if (_challenge != null) ...[
                  /* TODO: change here */
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      ConnectFourGame(
                        challenge: _challenge!,
                        onMoveMade: () {
                          // TODO: make own function
                          final profile = pref.getProfile();
                          final correctTime = DateTime.now().hour == 20 &&
                              DateTime.now().minute == 0;
                          setState(() {
                            var yourTurn =
                                _challenge!.lastMoverID != profile.id;
                            _isActive =
                                _canPerformMove && (yourTurn || correctTime);
                          });
                        },
                      ),
                      if (!_isActive)
                        Positioned.fill(
                          child: Container(
                            color: Colors.grey.withOpacity(0.5),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  _canPerformMove
                                      ? 'Waiting for your opponent or until 20:00 to play.'
                                      : completedToday()
                                          ? 'You’ve already completed your Habit today. Great job!'
                                          : 'Complete your Habit to make a move.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const CustomDivider(height: 1), // TODO: maybe delete
                ],
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
                                  // call own function -> check
                                  final profile = pref.getProfile();
                                  final correctTime =
                                      DateTime.now().hour == 20 &&
                                          DateTime.now().minute == 0;

                                  final yourTurn = _challenge == null
                                      ? false
                                      : _challenge!.lastMoverID !=
                                          profile
                                              .id; // if no challenge then false else calculate yourTurn
                                  setState(() {
                                    // TODO: makes this a own function
                                    // Habit Update
                                    var currentStreak =
                                        widget.habit.getStreak();
                                    widget.habit.addCurrentDate();
                                    var newStreak = widget.habit.getStreak();
                                    print(widget.habit.completedDates);
                                    pref.updateHabit(
                                        widget.habit,
                                        widget
                                            .index); // Update habit in shared preferences
                                    _isDismissed = true;

                                    // Challenge Update | If not null
                                    if (_challenge != null) {
                                      // Set canPerformMove to true if streak increases
                                      if (newStreak > currentStreak) {
                                        _canPerformMove = true; // update local
                                        pref.setChallengeBool(_challenge!.id,
                                            true); // update shared pref
                                      }
                                      // Recalculate active status immediately
                                      _isActive = _canPerformMove &&
                                          (yourTurn || correctTime);
                                    }
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
                        const SizedBox(
                            height: 30), // Adjust the height as needed
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
