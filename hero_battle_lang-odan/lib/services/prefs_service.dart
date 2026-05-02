import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyPlayerName = 'player_name';
  static const _keyThemeDark = 'theme_dark';
  static const _keyLastSearch = 'last_search';
  static const _keyOnboarded = 'onboarded';

  Future<String?> loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlayerName);
  }

  Future<void> savePlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerName, name);
  }

  Future<bool> loadThemeDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeDark) ?? true;
  }

  Future<void> saveThemeDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeDark, value);
  }

  Future<String?> loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch);
  }

  Future<void> saveLastSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, query);
  }

  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }
}
