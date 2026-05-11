import 'package:flutter/foundation.dart';
import '../services/prefs_service.dart';
import '../services/database_service.dart';
import '../models/hero_model.dart';
import 'dart:convert';

class PlayerProvider extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();
  String _playerName = 'Hero';
  bool _isDarkTheme = true;
  int _totalWins = 0;
  int _totalGames = 0;
  List<HeroModel> _mostUsedHeroes = [];

  String get playerName => _playerName;
  bool get isDarkTheme => _isDarkTheme;
  int get totalWins => _totalWins;
  int get totalGames => _totalGames;
  List<HeroModel> get mostUsedHeroes => _mostUsedHeroes;

  /// Call once from SplashScreen after app starts.
  Future<void> loadFromPrefs() async {
    _playerName = await _prefs.loadPlayerName() ?? 'Hero';
    _isDarkTheme = await _prefs.loadThemeDark();
    await refreshStats();
    notifyListeners();
  }

  /// Aggregates battle history to calculate global stats and identify frequently used heroes.
  /// Falls back to 'playerHero' string if full 'playerDeckJson' is unavailable.
  Future<void> refreshStats() async {
    final history = await DatabaseService().loadHistory();
    _totalGames = history.length;
    _totalWins = history.where((r) => r.playerWon).length;

    final Map<String, int> heroCounts = {};
    final Map<String, HeroModel> heroData = {};

    for (var record in history) {
      if (record.playerDeckJson != null) {
        try {
          final List<dynamic> deckList = jsonDecode(record.playerDeckJson!);
          for (var heroJson in deckList) {
            final hero = HeroModel.fromJson(heroJson);
            heroCounts[hero.name] = (heroCounts[hero.name] ?? 0) + 1;
            heroData[hero.name] = hero;
          }
        } catch (_) {}
      } else {
        heroCounts[record.playerHero] = (heroCounts[record.playerHero] ?? 0) + 1;
      }
    }

    if (heroCounts.isNotEmpty) {
      var sortedEntries = heroCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      int maxUsage = sortedEntries.first.value;
      _mostUsedHeroes = sortedEntries
          .where((e) => e.value == maxUsage)
          .map((e) => heroData[e.key])
          .whereType<HeroModel>()
          .toList();
    } else {
      _mostUsedHeroes = [];
    }

    notifyListeners();
  }

  Future<void> updatePlayerName(String name) async {
    _playerName = name;
    await _prefs.savePlayerName(name);
    notifyListeners();
  }

  Future<void> clearData() async {
    await _prefs.clearAll();
    await DatabaseService().clearAllData();
    _playerName = 'Player';
    _isDarkTheme = true;
    _totalWins = 0;
    _totalGames = 0;
    _mostUsedHeroes = [];
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkTheme = !_isDarkTheme;
    await _prefs.saveThemeDark(_isDarkTheme);
    notifyListeners();
  }

  void incrementWins() {
    _totalWins++;
    refreshStats(); // This will update both wins and games
  }
}
