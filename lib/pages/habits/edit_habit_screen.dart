import 'package:flutter/material.dart';
import 'package:four_habits_client/model/habit.dart';

import '../../components/custom_app_bar.dart';
import '../../components/custom_card.dart';
import '../../components/custom_divider.dart';
import '../../components/habit_tile.dart';
import 'detailed_habit_logic.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;
  final int index;

  const EditHabitScreen({Key? key, required this.habit, required this.index})
      : super(key: key);

  @override
  _EditHabitScreen createState() => _EditHabitScreen();
}

class _EditHabitScreen extends State<EditHabitScreen> {
  final DetailedHabitLogic _habitLogic = DetailedHabitLogic();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _habitNameController;
  late TextEditingController _occurrenceController;

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController(text: widget.habit.name);
    _occurrenceController =
        TextEditingController(text: widget.habit.occurrenceNum);
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    _occurrenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Update Habit"),
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
              const SizedBox(height: 16),
              const CustomDivider(height: 1),
              const SizedBox(height: 16),
              const Text(
                'Habit Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              TextFormField(
                controller: _habitNameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.orange),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter a Habit Name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    widget.habit.name = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Occurrence',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              DropdownButtonFormField<String>(
                value: widget.habit.occurrenceType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.orange),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                items: <String>['Daily', 'Weekly', 'Monthly']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    widget.habit.occurrenceType = newValue!;
                  });
                },
              ),
              if (widget.habit.occurrenceType != 'Daily')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _occurrenceController,
                    decoration: InputDecoration(
                      labelText: 'Please Enter a Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.orange),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a Number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.habit.occurrenceNum = value;
                      });
                    },
                  ),
                ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.habit.name = _habitNameController.text;
                    widget.habit.occurrenceNum = _occurrenceController.text;
                    await _habitLogic.updateHabit(widget.habit, widget.index);
                    Navigator.pop(context, 'updated');
                  }
                },
                child: CustomCard(
                    icon: Icons.save,
                    iconColor: Colors.orange,
                    cardColor: Colors.orange[100],
                    cardText: 'Update Habit',
                    cardTextColor: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
