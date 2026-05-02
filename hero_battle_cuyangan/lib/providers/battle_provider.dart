import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';
import '../engine/battle_engine.dart';

enum BattleState {
  idle,
  preparing,
  inProgress,
  playerTurn,
  opponentTurn,
  battleEnded,
}

class BattleProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final BattleEngine _battleEngine = BattleEngine();

  BattleState _battleState = BattleState.idle;
  HeroModel? _playerHero;
  HeroModel? _opponentHero;
  int _playerHp = 100;
  int _opponentHp = 100;
  int _maxPlayerHp = 100;
  int _maxOpponentHp = 100;
  String _battleLog = '';
  bool _playerWon = false;
  bool _isPlayerTurn = true;
  DateTime? _battleStartTime;
  final int _roundsPlayed = 0;
  int _battleDuration = 0;

  BattleState get battleState => _battleState;
  HeroModel? get playerHero => _playerHero;
  HeroModel? get opponentHero => _opponentHero;
  int get playerHp => _playerHp;
  int get opponentHp => _opponentHp;
  int get maxPlayerHp => _maxPlayerHp;
  int get maxOpponentHp => _maxOpponentHp;
  String get battleLog => _battleLog;
  bool get playerWon => _playerWon;
  bool get isPlayerTurn => _isPlayerTurn;
  bool get isBattleActive =>
      _battleState == BattleState.inProgress ||
      _battleState == BattleState.playerTurn ||
      _battleState == BattleState.opponentTurn;
  int get battleDuration => _battleDuration;

  Future<void> startBattle(HeroModel playerHero, HeroModel opponentHero) async {
    _battleState = BattleState.preparing;
    _playerHero = playerHero;
    _opponentHero = opponentHero;
    _maxPlayerHp = _calculateMaxHp(playerHero);
    _maxOpponentHp = _calculateMaxHp(opponentHero);
    _playerHp = _maxPlayerHp;
    _opponentHp = _maxOpponentHp;
    _battleLog = 'Battle started!\n${playerHero.name} vs ${opponentHero.name}!';
    _battleStartTime = DateTime.now();
    _isPlayerTurn = true;

    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _battleState = BattleState.playerTurn;
    notifyListeners();
  }

  Future<void> executePlayerAttack() async {
    if (_battleState != BattleState.playerTurn ||
        _playerHero == null ||
        _opponentHero == null) {
      return;
    }

    _battleState = BattleState.inProgress;
    notifyListeners();

    final damage = _battleEngine.calculateDamage(_playerHero!, _opponentHero!);
    _opponentHp = (_opponentHp - damage).clamp(0, _maxOpponentHp);
    _battleLog += '\n${_playerHero!.name} deals $damage damage!';

    if (_opponentHp <= 0) {
      await _endBattle(true);
    } else {
      _isPlayerTurn = false;
      _battleState = BattleState.opponentTurn;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1));
      await _executeOpponentAttack();
    }
  }

  Future<void> _executeOpponentAttack() async {
    if (_opponentHero == null || _playerHero == null) return;

    final damage = _battleEngine.calculateDamage(_opponentHero!, _playerHero!);
    _playerHp = (_playerHp - damage).clamp(0, _maxPlayerHp);
    _battleLog += '\n${_opponentHero!.name} deals $damage damage!';

    if (_playerHp <= 0) {
      await _endBattle(false);
    } else {
      _isPlayerTurn = true;
      _battleState = BattleState.playerTurn;
      notifyListeners();
    }
  }

  Future<void> _endBattle(bool playerWon) async {
    _playerWon = playerWon;
    _battleState = BattleState.battleEnded;

    if (_battleStartTime != null) {
      _battleDuration = DateTime.now().difference(_battleStartTime!).inSeconds;
    }

    if (playerWon) {
      _battleLog += '\n${_playerHero?.name} wins!';
    } else {
      _battleLog += '\n${_opponentHero?.name} wins!';
    }

    await _saveBattleRecord();
    notifyListeners();
  }

  Future<void> _saveBattleRecord() async {
    if (_playerHero == null || _opponentHero == null) return;

    try {
      final BattleRecord record = BattleRecord(
        playerHero: _playerHero!.name,
        aiHero: _opponentHero!.name,
        playerWon: _playerWon,
        roundsPlayed: _roundsPlayed,
        playedAt: DateTime.now().toIso8601String(),
      );

      await _dbService.saveBattleRecord(record);
    } catch (e) {
      _battleLog += '\nFailed to save battle record: $e';
    }
  }

  void resetBattle() {
    _battleState = BattleState.idle;
    _playerHero = null;
    _opponentHero = null;
    _playerHp = 100;
    _opponentHp = 100;
    _maxPlayerHp = 100;
    _maxOpponentHp = 100;
    _battleLog = '';
    _playerWon = false;
    _isPlayerTurn = true;
    _battleStartTime = null;
    _battleDuration = 0;
    notifyListeners();
  }

  int _calculateMaxHp(HeroModel hero) {
    return ((hero.powerStats.durability + hero.powerStats.power) / 2).round();
  }

  void addBattleLog(String message) {
    _battleLog += '\n$message';
    notifyListeners();
  }
}
