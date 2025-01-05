import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService _instance = SharedPreferencesService._internal();
  SharedPreferences? _preferences;

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Set and get firstVisit
  Future<void> setFirstVisit(bool value) async {
    await _preferences?.setBool('firstVisit', value);
  }

  bool? getFirstVisit() {
    return _preferences?.getBool('firstVisit');
  }

  // Set and get username
  Future<void> setUsername(String value) async {
    await _preferences?.setString('username', value);
  }

  String? getUsername() {
    return _preferences?.getString('username');
  }

  // Set and get habits
  Future<void> setHabits(List<String> value) async {
    await _preferences?.setStringList('habits', value);
  }

  List<String>? getHabits() {
    return _preferences?.getStringList('habits');
  }
}