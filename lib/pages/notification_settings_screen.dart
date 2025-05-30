import 'package:flutter/material.dart';
import 'package:four_habits_client/components/custom_app_bar.dart';
import 'package:four_habits_client/components/custom_card.dart';
import 'package:four_habits_client/components/custom_divider.dart';

import '../services/notification_service.dart';
import '../services/shared_preferences_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  final bool initialEnableNotifications;
  final TimeOfDay initialNotificationTime;

  const NotificationSettingsScreen({
    super.key,
    required this.initialEnableNotifications,
    required this.initialNotificationTime,
  });

  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final NotificationService _notificationService = NotificationService();
  final _pref = SharedPreferencesService();
  late bool _enableNotifications;
  late TimeOfDay _notificationTime;

  @override
  void initState() {
    super.initState();
    _enableNotifications = widget.initialEnableNotifications;
    _notificationTime = widget.initialNotificationTime;
  }

  // save notification settings and re-schedule notification depending on the settings
  Future<void> _saveSettings() async {
    _pref.storeNotificationSettings(_enableNotifications, _notificationTime);
    if (_enableNotifications) {
      await _notificationService.scheduleDailyNotification();
    } else {
      await _notificationService.stopNotification();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Daily Notification Settings"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const CustomDivider(height: 1),
              const SizedBox(height: 16),
              const Text(
                'Enable Notifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                title: const Text('Enable Notifications'),
                value: _enableNotifications,
                onChanged: (bool value) async {
                  setState(() {
                    _enableNotifications = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              const CustomDivider(height: 1),
              const SizedBox(height: 16),
              const Text(
                'Notification Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Time: ${_notificationTime.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _notificationTime,
                  );
                  if (picked != null && picked != _notificationTime) {
                    setState(() {
                      _notificationTime = picked;
                    });
                  }
                },
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
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _saveSettings();
                            _formKey.currentState!.save();
                            Navigator.pop(context,
                                true); // Return true to indicate settings were changed
                          }
                        },
                        child: CustomCard(
                          icon: Icons.save,
                          iconColor: Colors.orange,
                          cardColor: Colors.orange[100],
                          cardText: 'Save Settings',
                          cardTextColor: Colors.orange,
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
