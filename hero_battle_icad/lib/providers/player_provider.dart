import 'package:flutter/material.dart';
import '../services/prefs_service.dart';

class PlayerProvider extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();
  String _playerName = 'Hero';
  bool _isDarkTheme = true;

  String get playerName => _playerName;
  bool get isDarkTheme => _isDarkTheme;

  // Initialize data from local storage
  Future<void> loadFromPrefs() async {
    _playerName = await _prefs.loadPlayerName() ?? 'Hero';
    _isDarkTheme = await _prefs.loadThemeDark();
    notifyListeners();
  }

  // ADD THIS METHOD TO FIX THE ERROR
  Future<void> updatePlayerName(String newName) async {
    if (newName.trim().isEmpty) return;
    
    _playerName = newName;
    await _prefs.savePlayerName(newName); // Persist to SharedPreferences
    notifyListeners(); // Refresh the UI (Profile screen name label)
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await _prefs.saveThemeDark(_isDarkTheme);
    notifyListeners();
  }
}