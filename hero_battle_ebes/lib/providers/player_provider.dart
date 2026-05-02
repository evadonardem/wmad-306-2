import 'package:flutter/foundation.dart';
import '../services/prefs_service.dart';

class PlayerProvider extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();

  String _playerName = 'Hero';
  bool _isDarkTheme = true;
  int _totalWins = 0;
  int _totalLosses = 0;

  String get playerName => _playerName;
  bool get isDarkTheme => _isDarkTheme;
  int get totalWins => _totalWins;
  int get totalLosses => _totalLosses;
  int get totalBattles => _totalWins + _totalLosses;

  /// Call once from SplashScreen after the app starts.
  Future<void> loadFromPrefs() async {
    _playerName = await _prefs.loadPlayerName() ?? 'Hero';
    _isDarkTheme = await _prefs.loadThemeDark();
    notifyListeners();
  }

  Future<void> updatePlayerName(String name) async {
    _playerName = name.trim().isEmpty ? 'Hero' : name.trim();
    await _prefs.savePlayerName(_playerName);
    notifyListeners();
  }

  /// Toggle and persist dark / light mode.  MaterialApp reacts via Consumer.
  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await _prefs.saveThemeDark(_isDarkTheme);
    notifyListeners();
  }

  void recordWin() {
    _totalWins++;
    notifyListeners();
  }

  void recordLoss() {
    _totalLosses++;
    notifyListeners();
  }
}
