import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  // 🔑 KEYS
  static const _keyPlayerName = 'player_name';
  static const _keyThemeDark = 'theme_dark';
  static const _keyLastSearch = 'last_search';

  // =============================
  // 🔹 PLAYER NAME
  // =============================
  Future<String?> loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlayerName);
  }

  Future<void> savePlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerName, name);
  }

  // =============================
  // 🔹 THEME
  // =============================
  Future<bool> loadThemeDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeDark) ?? true;
  }

  Future<void> saveThemeDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeDark, value);
  }

  // =============================
  // 🔹 SEARCH (FIXED)
  // =============================
  Future<void> saveLastSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, query);
  }

  Future<String?> loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch);
  }
}