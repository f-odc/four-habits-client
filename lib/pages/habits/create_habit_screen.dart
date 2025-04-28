import 'package:flutter/material.dart';
import 'package:four_habits_client/components/custom_app_bar.dart';
import 'package:four_habits_client/components/custom_card.dart';
import 'package:four_habits_client/components/custom_divider.dart';
import 'package:four_habits_client/components/habit_tile.dart';
import 'package:four_habits_client/styles.dart';

import 'create_habit_logic.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  _CreateHabitScreenState createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  String _habitName = '';
  String? _occurrenceType;
  final _occurrenceController = TextEditingController();
  final CreateHabitLogic _logic = CreateHabitLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Create Your Habit!"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // HABIT CARD PREVIEW
              HabitTile(
                habitName: _habitName,
                occurrenceType: _occurrenceType ?? '',
                occurrenceNum: _occurrenceController.text,
                currentCompletedTimes: 0,
                streak: 0,
              ),
              const SizedBox(height: 16),
              const CustomDivider(
                height: 1,
              ),
              const SizedBox(height: 16),
              const Text(
                'Habit Name',
                style: TextStyle(
                    fontSize: Style.cardTextSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              TextFormField(
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
                onSaved: (value) {
                  _habitName = value!;
                },
                onChanged: (value) {
                  setState(() {
                    _habitName = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Occurrence',
                style: TextStyle(
                    fontSize: Style.cardTextSize, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              DropdownButtonFormField<String>(
                value: _occurrenceType,
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
                    _occurrenceType = newValue;
                  });
                },
              ),
              if (_occurrenceType != 'Daily' && _occurrenceType != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextFormField(
                    controller: _occurrenceController,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
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
                      setState(() {});
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const CustomDivider(height: 1),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // save the habit
                            await _logic.saveHabit(_habitName, _occurrenceType!,
                                _occurrenceController.text);
                            Navigator.pop(context, 'saved');
                          }
                        },
                        child: CustomCard(
                            icon: Icons.save,
                            iconColor: Style.orange,
                            cardColor: Style.cardColorOrange,
                            cardText: 'Save Habit',
                            cardTextColor: Style.orange),
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
