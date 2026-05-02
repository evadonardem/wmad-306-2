import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  HeroModel? _playerHero;
  HeroModel? _aiHero;
  int _playerHp = 0;
  int _aiHp = 0;
  int _round = 0;
  bool _isPlayerTurn = true;
  String _battleLog = '';

  HeroModel? get playerHero => _playerHero;
  HeroModel? get aiHero => _aiHero;
  int get playerHp => _playerHp;
  int get aiHp => _aiHp;
  int get round => _round;
  bool get isPlayerTurn => _isPlayerTurn;
  String get battleLog => _battleLog;
  bool get isBattleActive => _playerHero != null && _aiHero != null;

  void startBattle(HeroModel player, HeroModel ai) {
    _playerHero = player;
    _aiHero = ai;
    _playerHp = player.maxHp;
    _aiHp = ai.maxHp;
    _round = 1;
    _isPlayerTurn = player.initiative >= ai.initiative;
    _battleLog = 'Battle started!\n';

    if (!_isPlayerTurn) {
      _battleLog += '${ai.name} has initiative and strikes first!\n';
      _performTurn(attacker: _aiHero!, defender: _playerHero!, isPlayerAttack: false);
    }

    notifyListeners();
  }

  void attack() {
    if (!isBattleActive || _isBattleOver) return;
    if (!_isPlayerTurn) return;

    _performTurn(attacker: _playerHero!, defender: _aiHero!, isPlayerAttack: true);
    notifyListeners();
  }

  void _performTurn({
    required HeroModel attacker,
    required HeroModel defender,
    required bool isPlayerAttack,
  }) {
    final damage = _calculateDamage(attacker, defender);
    if (isPlayerAttack) {
      _aiHp -= damage;
      _battleLog += '${attacker.name} attacks ${defender.name} for $damage damage!\n';
    } else {
      _playerHp -= damage;
      _battleLog += '${attacker.name} attacks ${defender.name} for $damage damage!\n';
    }

    if (_playerHp <= 0 || _aiHp <= 0) {
      _endBattle();
      return;
    }

    _isPlayerTurn = !_isPlayerTurn;
    if (_isPlayerTurn) {
      _round++;
      return;
    }

    // After a player turn, let the AI immediately respond.
    if (isPlayerAttack) {
      _performTurn(attacker: _aiHero!, defender: _playerHero!, isPlayerAttack: false);
    }
  }

  int _calculateDamage(HeroModel attacker, HeroModel defender) {
    final baseDamage = attacker.attack;
    final defense = defender.defense;
    final rawDamage = baseDamage - defense;
    if (rawDamage <= 0) {
      return 1;
    }
    return (rawDamage / 2).ceil();
  }

  void _endBattle() {
    final playerWon = _playerHp > 0;
    _battleLog += playerWon ? 'Player wins!\n' : 'AI wins!\n';

    final record = BattleRecord(
      playerHero: _playerHero!.name,
      aiHero: _aiHero!.name,
      playerWon: playerWon,
      roundsPlayed: _round,
      playedAt: DateTime.now().toIso8601String(),
    );
    DatabaseService().saveBattleRecord(record);
  }

  bool get _isBattleOver => _playerHp <= 0 || _aiHp <= 0;

  void resetBattle() {
    _playerHero = null;
    _aiHero = null;
    _playerHp = 0;
    _aiHp = 0;
    _round = 0;
    _isPlayerTurn = true;
    _battleLog = '';
    notifyListeners();
  }
}