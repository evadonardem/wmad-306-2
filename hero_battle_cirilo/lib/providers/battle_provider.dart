import 'package:flutter/foundation.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';
import '../engine/battle_engine.dart';

class BattleProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  HeroModel? _playerHero;
  HeroModel? _aiHero;
  int _playerHp = 0;
  int _aiHp = 0;
  int _round = 0;
  final List<String> _battleLog = [];
  bool _battleInProgress = false;
  BattleRecord? _latestBattle;
  List<BattleRecord> _history = [];

  BattleProvider() {
    _loadHistory();
  }

  HeroModel? get playerHero => _playerHero;
  HeroModel? get aiHero => _aiHero;
  int get playerHp => _playerHp;
  int get aiHp => _aiHp;
  int get round => _round;
  List<String> get battleLog => List.unmodifiable(_battleLog);
  bool get battleInProgress => _battleInProgress;
  bool get isFighting => _battleInProgress; // Alias
  BattleRecord? get latestBattle => _latestBattle; // For compatibility
  List<BattleRecord> get history => List.unmodifiable(_history); // For compatibility

  Future<void> _loadHistory() async {
    _history = await _db.loadHistory();
    notifyListeners();
  }

  void startBattle(HeroModel player, HeroModel ai) {
    _playerHero = player;
    _aiHero = ai;
    _playerHp = player.maxHp;
    _aiHp = ai.maxHp;
    _round = 0;
    _battleLog.clear();
    _battleInProgress = true;
    _battleLog.add('Battle started: ${player.name} vs ${ai.name}');
    notifyListeners();
  }

  Future<BattleRecord> endBattle(bool playerWon) async {
    if (_playerHero == null || _aiHero == null) {
      throw StateError('No battle in progress');
    }

    final record = BattleRecord(
      playerHero: _playerHero!.name,
      aiHero: _aiHero!.name,
      playerWon: playerWon,
      roundsPlayed: _round,
      playedAt: DateTime.now().toIso8601String(),
    );

    await _db.saveBattleRecord(record);
    _latestBattle = record;
    _history.insert(0, record);
    _battleInProgress = false;
    notifyListeners();
    return record;
  }

  Future<BattleRecord> fight(HeroModel attacker, HeroModel defender) async {
    _battleInProgress = true;
    notifyListeners();

    final result = BattleEngine.simulate(attacker, defender);

    final record = BattleRecord(
      playerHero: attacker.name,
      aiHero: defender.name,
      playerWon: result.winner.id == attacker.id,
      roundsPlayed: 1,
      playedAt: DateTime.now().toIso8601String(),
    );

    await _db.saveBattleRecord(record);
    _latestBattle = record;
    _history.insert(0, record);
    _battleInProgress = false;
    notifyListeners();
    return record;
  }

  void addLog(String message) {
    _battleLog.add(message);
    notifyListeners();
  }
}
