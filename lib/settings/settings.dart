import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  Settings._singleton();
  static final Settings instance = Settings._singleton();

  /// Instance of SharedPreferences for getting and setting preferences.
  late SharedPreferences _prefs;

  /// Initialize should only need to be called once, in main().
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isDarkTheme => _prefs.getBool('isDarkTheme') ?? true;

  set isDarkTheme(bool isDarkTheme) {
    _prefs.setBool('isDarkTheme', isDarkTheme);
  }
}
