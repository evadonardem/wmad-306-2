// lib/providers/player_provider.dart

import 'package:flutter/foundation.dart';
import '../services/prefs_service.dart';

class PlayerProvider extends ChangeNotifier {
  final PrefsService _prefs = PrefsService();
  
  String _playerName = 'Hero';
  bool _isDarkTheme = true;
  int _totalWins = 0;
  int _totalBattles = 0;
  int _totalLosses = 0;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _totalCoins = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get playerName => _playerName;
  bool get isDarkTheme => _isDarkTheme;
  int get totalWins => _totalWins;
  int get totalBattles => _totalBattles;
  int get totalLosses => _totalLosses;
  int get currentStreak => _currentStreak;
  int get bestStreak => _bestStreak;
  int get totalCoins => _totalCoins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Derived getters
  double get winRatio => _totalBattles == 0 ? 0 : _totalWins / _totalBattles;
  double get winPercentage => winRatio * 100;
  bool get hasWins => _totalWins > 0;
  bool get hasPlayed => _totalBattles > 0;
  String get winLossText => '$_totalWins - $_totalLosses';
  
  // Player level based on wins
  int get playerLevel {
    if (_totalWins < 5) return 1;
    if (_totalWins < 15) return 2;
    if (_totalWins < 30) return 3;
    if (_totalWins < 50) return 4;
    return 5;
  }
  
  String get playerTitle {
    switch (playerLevel) {
      case 1:
        return 'Rookie Hero';
      case 2:
        return 'Novice Hero';
      case 3:
        return 'Skilled Hero';
      case 4:
        return 'Expert Hero';
      case 5:
        return 'Legendary Hero';
      default:
        return 'Hero';
    }
  }
  
  // Next level XP (wins needed)
  int get winsToNextLevel {
    switch (playerLevel) {
      case 1:
        return 5 - _totalWins;
      case 2:
        return 15 - _totalWins;
      case 3:
        return 30 - _totalWins;
      case 4:
        return 50 - _totalWins;
      default:
        return 0;
    }
  }

  /// Call once from SplashScreen after app starts.
  Future<void> loadFromPrefs() async {
    _setLoading(true);
    _clearError();
    
    try {
      _playerName = await _prefs.loadPlayerName() ?? 'Hero';
      _isDarkTheme = await _prefs.loadThemeDark();
      _totalWins = await _prefs.getTotalWins();
      _totalBattles = await _prefs.getTotalBattles();
      _totalLosses = _totalBattles - _totalWins;
      _bestStreak = await _prefs.getHighScore(); // Reusing high score for best streak
      _totalCoins = await _loadCoins();
      
      notifyListeners();
    } catch (e) {
      _setError('Error loading player data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Load coins from preferences
  Future<int> _loadCoins() async {
    // You can add a coin storage method to PrefsService
    // For now, returning 0
    return 0;
  }

  /// Update player name
  Future<void> updatePlayerName(String name) async {
    if (name.trim().isEmpty) {
      _setError('Player name cannot be empty');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _playerName = name.trim();
      await _prefs.savePlayerName(_playerName);
      notifyListeners();
    } catch (e) {
      _setError('Error saving player name: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle dark/light theme
  Future<void> toggleTheme() async {
    try {
      _isDarkTheme = !_isDarkTheme;
      await _prefs.saveThemeDark(_isDarkTheme);
      notifyListeners();
    } catch (e) {
      _setError('Error saving theme preference: $e');
    }
  }
  
  /// Set theme explicitly
  Future<void> setTheme(bool isDark) async {
    if (_isDarkTheme != isDark) {
      await toggleTheme();
    }
  }

  /// Increment wins (call when player wins a battle)
  Future<void> incrementWins() async {
    try {
      _totalWins++;
      _totalBattles++;
      _currentStreak++;
      
      // Update best streak
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
        await _prefs.updateHighScore(_bestStreak);
      }
      
      // Save to preferences
      await _prefs.incrementTotalWins();
      await _prefs.incrementTotalBattles();
      
      notifyListeners();
    } catch (e) {
      _setError('Error saving win: $e');
    }
  }
  
  /// Increment losses (call when player loses a battle)
  Future<void> incrementLosses() async {
    try {
      _totalLosses++;
      _totalBattles++;
      _currentStreak = 0; // Reset streak on loss
      
      // Save to preferences
      await _prefs.incrementTotalBattles();
      
      notifyListeners();
    } catch (e) {
      _setError('Error saving loss: $e');
    }
  }
  
  /// Record battle result (win/loss)
  Future<void> recordBattleResult(bool won) async {
    if (won) {
      await incrementWins();
    } else {
      await incrementLosses();
    }
  }
  
  /// Add coins to player
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    
    _totalCoins += amount;
    // Save coins to preferences (add this method to PrefsService)
    notifyListeners();
  }
  
  /// Spend coins
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    if (_totalCoins < amount) {
      _setError('Not enough coins!');
      return false;
    }
    
    _totalCoins -= amount;
    // Save coins to preferences
    notifyListeners();
    return true;
  }
  
  /// Reset current streak (manual reset)
  void resetStreak() {
    _currentStreak = 0;
    notifyListeners();
  }
  
  /// Reset all player progress (for testing or reset option)
  Future<void> resetProgress() async {
    _setLoading(true);
    _clearError();
    
    try {
      _totalWins = 0;
      _totalBattles = 0;
      _totalLosses = 0;
      _currentStreak = 0;
      _bestStreak = 0;
      _totalCoins = 0;
      
      // Reset in preferences (add these methods to PrefsService)
      notifyListeners();
    } catch (e) {
      _setError('Error resetting progress: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Reset entire player (including name)
  Future<void> resetAll() async {
    await resetProgress();
    await updatePlayerName('Hero');
  }
  
  /// Get statistics as a map for display
  Map<String, dynamic> getStatistics() {
    return {
      'playerName': _playerName,
      'level': playerLevel,
      'title': playerTitle,
      'totalWins': _totalWins,
      'totalLosses': _totalLosses,
      'totalBattles': _totalBattles,
      'winRatio': winRatio,
      'winPercentage': winPercentage,
      'currentStreak': _currentStreak,
      'bestStreak': _bestStreak,
      'totalCoins': _totalCoins,
    };
  }
  
  /// Get formatted statistics string
  String getFormattedStats() {
    return '''
Player: $_playerName
Level: $playerLevel ($playerTitle)
Battles: $_totalBattles
Wins: $_totalWins
Losses: $_totalLosses
Win Rate: ${winPercentage.toStringAsFixed(1)}%
Current Streak: $_currentStreak
Best Streak: $_bestStreak
Coins: $_totalCoins
    ''';
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
  
  // Reset error (call when user dismisses error)
  void clearError() {
    _clearError();
  }

  /// Update player profile with multiple fields
  Future<void> updateProfile({String? name, bool? theme}) async {
    bool needsUpdate = false;
    
    if (name != null && name.trim().isNotEmpty && name != _playerName) {
      _playerName = name.trim();
      await _prefs.savePlayerName(_playerName);
      needsUpdate = true;
    }
    
    if (theme != null && theme != _isDarkTheme) {
      _isDarkTheme = theme;
      await _prefs.saveThemeDark(_isDarkTheme);
      needsUpdate = true;
    }
    
    if (needsUpdate) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}