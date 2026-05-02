import 'package:flutter/foundation.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';

class BattleHistoryProvider extends ChangeNotifier {
  List<BattleRecord> _history = [];
  bool _isLoading = false;
  String _error = '';

  List<BattleRecord> get history => _history;
  bool get isLoading => _isLoading;
  String get error => _error;

  int get totalMatches => _history.length;
  int get totalWins => _history.where((r) => r.playerWon).length;
  double get winRate => totalMatches == 0 ? 0.0 : (totalWins / totalMatches) * 100;

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _history = await DatabaseService().loadHistory();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
