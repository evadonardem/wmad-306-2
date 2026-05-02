import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/hero_model.dart';

class BattleState {
  final HeroModel playerHero;
  final HeroModel opponentHero;
  late int playerHp;
  late int opponentHp;
  final int playerMaxHp;
  final int opponentMaxHp;
  int turn = 1;
  bool isPlayerTurn = true;
  final List<String> battleLog = [];

  BattleState({
    required this.playerHero,
    required this.opponentHero,
  })  : playerMaxHp = playerHero.maxHp,
        opponentMaxHp = opponentHero.maxHp {
    playerHp = playerMaxHp;
    opponentHp = opponentMaxHp;
    battleLog.add('Battle started: ${playerHero.name} vs ${opponentHero.name}');
  }

  bool get isPlayerDefeated => playerHp <= 0;
  bool get isOpponentDefeated => opponentHp <= 0;
  bool get isBattleOver => isPlayerDefeated || isOpponentDefeated;

  void addLog(String message) {
    battleLog.add('[Turn $turn] $message');
  }

  void endTurn() {
    isPlayerTurn = !isPlayerTurn;
    if (!isPlayerTurn) {
      turn++;
    }
  }
}

class BattleProvider extends ChangeNotifier {
  BattleState? _currentBattle;
  bool _isComputerOpponent = false;

  BattleState? get currentBattle => _currentBattle;
  bool get isBattleActive => _currentBattle != null && !_currentBattle!.isBattleOver;
  bool get isComputerOpponent => _isComputerOpponent;
  String get battleStatus {
    if (_currentBattle == null) return 'No battle in progress';
    if (_currentBattle!.isPlayerDefeated) return 'Defeated!';
    if (_currentBattle!.isOpponentDefeated) return 'Victory!';
    if (_isComputerOpponent) return 'Computer Battle - Turn ${_currentBattle!.turn}';
    return 'Turn ${_currentBattle!.turn}';
  }

  /// Start a new battle
  void startBattle(HeroModel playerHero, HeroModel opponentHero, {bool isComputerOpponent = false}) {
    _isComputerOpponent = isComputerOpponent;
    _currentBattle = BattleState(
      playerHero: playerHero,
      opponentHero: opponentHero,
    );
    notifyListeners();
    
    // If computer opponent, start automatic battle
    if (_isComputerOpponent) {
      _executeComputerBattle();
    }
  }

  /// Player attacks opponent
  void playerAttack() {
    if (_currentBattle == null || !_currentBattle!.isPlayerTurn) return;

    final damage = _calculateDamage(
      _currentBattle!.playerHero,
      _currentBattle!.opponentHero,
    );

    _currentBattle!.opponentHp -= damage;
    _currentBattle!.addLog(
      '${_currentBattle!.playerHero.name} attacks for $damage damage!',
    );

    if (_currentBattle!.isOpponentDefeated) {
      _currentBattle!.addLog('Victory! ${_currentBattle!.playerHero.name} wins!');
    } else {
      _currentBattle!.endTurn();
    }

    notifyListeners();
  }

  /// Opponent attacks player
  void opponentAttack() {
    if (_currentBattle == null || _currentBattle!.isPlayerTurn) return;

    final damage = _calculateDamage(
      _currentBattle!.opponentHero,
      _currentBattle!.playerHero,
    );

    _currentBattle!.playerHp -= damage;
    _currentBattle!.addLog(
      '${_currentBattle!.opponentHero.name} attacks for $damage damage!',
    );

    if (_currentBattle!.isPlayerDefeated) {
      _currentBattle!.addLog('Defeated! ${_currentBattle!.opponentHero.name} wins!');
    } else {
      _currentBattle!.endTurn();
    }

    notifyListeners();
  }

  /// Execute automatic computer battle
  Future<void> _executeComputerBattle() async {
    while (_currentBattle != null && !_currentBattle!.isBattleOver) {
      await Future.delayed(const Duration(milliseconds: 1000)); // Delay for visual effect
      
      if (_currentBattle!.isPlayerTurn) {
        playerAttack();
      } else {
        opponentAttack();
      }
    }
  }

  /// End the current battle
  void endBattle() {
    _currentBattle = null;
    _isComputerOpponent = false;
    notifyListeners();
  }

  /// Calculate damage based on attacker and defender stats
  int _calculateDamage(HeroModel attacker, HeroModel defender) {
    final baseAttack = attacker.attack;
    final defense = defender.defense;
    const minVariance = 0.8;
    const maxVariance = 1.2;

    // Calculate base damage: (attacker attack - defender defense / 2)
    int baseDamage = (baseAttack - (defense / 2)).round();
    
    // Ensure minimum damage of 1
    baseDamage = baseDamage.clamp(1, baseAttack);
    
    // Apply random variance between 0.8x and 1.2x
    final random = Random();
    final varianceMultiplier = minVariance + 
        (random.nextDouble() * (maxVariance - minVariance));
    
    int finalDamage = (baseDamage * varianceMultiplier).round();
    
    // Ensure damage is at least 1 and doesn't exceed baseAttack
    return finalDamage.clamp(1, baseAttack);
  }
}
