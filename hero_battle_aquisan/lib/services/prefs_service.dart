
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _playerNameKey = 'player_name';
  static const _themeDarkKey = 'theme_dark';
  static const _totalWinsKey = 'total_wins';
  static const _totalBattlesKey = 'total_battles';
  static const _highScoreKey = 'high_score';
  static const _soundEnabledKey = 'sound_enabled';
  static const _vibrationEnabledKey = 'vibration_enabled';
  static const _onboardedKey = 'onboarded';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  Future<String?> loadPlayerName() async {
    final prefs = await _prefs();
    return prefs.getString(_playerNameKey);
  }

  Future<void> savePlayerName(String name) async {
    final prefs = await _prefs();
    await prefs.setString(_playerNameKey, name);
  }

  Future<bool> loadThemeDark() async {
    final prefs = await _prefs();
    return prefs.getBool(_themeDarkKey) ?? true;
  }

  Future<void> saveThemeDark(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_themeDarkKey, value);
  }

  Future<int> getTotalWins() async {
    final prefs = await _prefs();
    return prefs.getInt(_totalWinsKey) ?? 0;
  }

  Future<int> getTotalBattles() async {
    final prefs = await _prefs();
    return prefs.getInt(_totalBattlesKey) ?? 0;
  }

  Future<void> incrementTotalWins() async {
    final prefs = await _prefs();
    final wins = await getTotalWins() + 1;
    await prefs.setInt(_totalWinsKey, wins);
  }

  Future<void> incrementTotalBattles() async {
    final prefs = await _prefs();
    final battles = await getTotalBattles() + 1;
    await prefs.setInt(_totalBattlesKey, battles);
  }

  Future<int> getHighScore() async {
    final prefs = await _prefs();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  Future<void> updateHighScore(int value) async {
    final prefs = await _prefs();
    await prefs.setInt(_highScoreKey, value);
  }

  Future<bool> isSoundEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  Future<bool> isVibrationEnabled() async {
    final prefs = await _prefs();
    return prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_vibrationEnabledKey, value);
  }

  Future<void> setOnboarded() async {
    final prefs = await _prefs();
    await prefs.setBool(_onboardedKey, true);
  }

  Future<bool> isOnboarded() async {
    final prefs = await _prefs();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  Future<void> clearAllPreferences() async {
    final prefs = await _prefs();
    await prefs.clear();
  }

} // Removed broken UI code from line 101 onwards
