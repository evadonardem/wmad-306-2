import 'package:flutter/foundation.dart';
import '../models/battle_history_model.dart';
import '../services/database_service.dart';

class BattleHistoryProvider extends ChangeNotifier {
  List<BattleHistoryModel> _battleHistory = [];
  bool _isLoading = false;
  String? _error;

  List<BattleHistoryModel> get battleHistory =>
      _battleHistory.reversed.toList(); // Most recent first
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Save battle to history
  Future<void> saveBattle({
    required String playerTeamName,
    required String opponentName,
    required String finalScore,
    required String winner,
    required List<String> playerHeroes,
    required List<String> opponentHeroes,
    required String battleSummary,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final battle = BattleHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        playerTeamName: playerTeamName,
        opponentName: opponentName,
        finalScore: finalScore,
        battleDate: DateTime.now(),
        winner: winner,
        playerHeroes: playerHeroes,
        opponentHeroes: opponentHeroes,
        battleSummary: battleSummary,
      );

      await DatabaseService().saveBattleHistory(battle);
      _battleHistory.add(battle);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to save battle: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load all battles from database
  Future<void> loadBattleHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _battleHistory = await DatabaseService().getBattleHistory();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load battle history: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear battle history
  Future<void> clearHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await DatabaseService().clearBattleHistory();
      _battleHistory.clear();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear history: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get battle statistics
  Map<String, dynamic> getStatistics() {
    final totalBattles = _battleHistory.length;
    final playerWins = _battleHistory.where((b) => b.winner == 'Player').length;
    final opponentWins = _battleHistory
        .where((b) => b.winner == 'Opponent')
        .length;
    final winRate = totalBattles > 0
        ? (playerWins / totalBattles * 100).toStringAsFixed(1)
        : '0.0';

    return {
      'totalBattles': totalBattles,
      'playerWins': playerWins,
      'opponentWins': opponentWins,
      'winRate': winRate,
    };
  }
}
