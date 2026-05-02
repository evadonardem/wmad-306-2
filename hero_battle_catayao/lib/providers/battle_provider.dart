import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  HeroModel? _playerHero;
  HeroModel? _aiHero;
  int _playerHp = 0;
  int _aiHp = 0;
  int _round = 0;
  bool _isComplete = false;
  bool _playerWon = false;
  bool _winAwarded = false;
  bool _isResolvingTurn = false;
  final List<String> _log = [];

  HeroModel? get playerHero => _playerHero;
  HeroModel? get aiHero => _aiHero;
  int get playerHp => _playerHp;
  int get aiHp => _aiHp;
  int get round => _round;
  bool get isComplete => _isComplete;
  bool get playerWon => _playerWon;
  bool get isResolvingTurn => _isResolvingTurn;
  List<String> get log => List.unmodifiable(_log);

  void startBattle(HeroModel playerHero, HeroModel aiHero) {
    _playerHero = playerHero;
    _aiHero = aiHero;
    _playerHp = playerHero.maxHp;
    _aiHp = aiHero.maxHp;
    _round = 1;
    _isComplete = false;
    _playerWon = false;
    _winAwarded = false;
    _isResolvingTurn = false;
    _log
      ..clear()
      ..add('${playerHero.name} faces ${aiHero.name}.');
    notifyListeners();
  }

  bool consumeWinAward() {
    if (!_isComplete || !_playerWon || _winAwarded) return false;
    _winAwarded = true;
    return true;
  }

  Future<void> playerAttack({bool special = false}) async {
    if (_isComplete ||
        _isResolvingTurn ||
        _playerHero == null ||
        _aiHero == null) {
      return;
    }
    _isResolvingTurn = true;
    notifyListeners();

    try {
      final playerResult = BattleEngine.attack(
        attacker: _playerHero!,
        defender: _aiHero!,
        attackerHp: _playerHp,
        defenderHp: _aiHp,
        attackerIsPlayer: true,
        special: special,
      );
      _playerHp = playerResult.playerHp;
      _aiHp = playerResult.aiHp;
      _log.insert(0, playerResult.log);

      if (_aiHp <= 0) {
        await _finish(playerWon: true);
        return;
      }

      final aiResult = BattleEngine.attack(
        attacker: _aiHero!,
        defender: _playerHero!,
        attackerHp: _aiHp,
        defenderHp: _playerHp,
        attackerIsPlayer: false,
      );
      _playerHp = aiResult.playerHp;
      _aiHp = aiResult.aiHp;
      _log.insert(0, aiResult.log);

      if (_playerHp <= 0) {
        await _finish(playerWon: false);
        return;
      }

      _round++;
      notifyListeners();
    } catch (e) {
      _log.insert(0, 'Battle error: $e');
      notifyListeners();
    } finally {
      _isResolvingTurn = false;
      notifyListeners();
    }
  }

  Future<void> _finish({required bool playerWon}) async {
    _isComplete = true;
    _playerWon = playerWon;
    _log.insert(0, playerWon ? 'Victory!' : 'Defeat.');
    try {
      await DatabaseService().saveBattleRecord(
        BattleRecord(
          playerHero: _playerHero!.name,
          aiHero: _aiHero!.name,
          playerWon: playerWon,
          roundsPlayed: _round,
          playedAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      _log.insert(0, 'History save failed: $e');
    }
    notifyListeners();
  }
}
