import 'package:flutter/foundation.dart';
import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  BattleState? _state;
  bool _isProcessing = false;

  BattleState? get state => _state;
  bool get isProcessing => _isProcessing;
  bool get hasActiveBattle => _state != null && !_state!.isOver;

  // ── Start ────────────────────────────────────────────────────────────────

  void startBattle(HeroModel player, HeroModel ai) {
    _state = BattleEngine.init(player, ai);
    _isProcessing = false;
    notifyListeners();
  }

  // ── Player actions ───────────────────────────────────────────────────────

  Future<void> playerAttack() => _playerAction(special: false);
  Future<void> playerSpecial() => _playerAction(special: true);

  Future<void> _playerAction({required bool special}) async {
    if (_state == null ||
        !_state!.isPlayerTurn ||
        _state!.isOver ||
        _isProcessing) return;

    _isProcessing = true;
    notifyListeners();

    // Apply player move
    _state = special
        ? BattleEngine.playerSpecial(_state!)
        : BattleEngine.playerAttack(_state!);
    notifyListeners();

    if (_state!.isOver) {
      await _saveRecord();
      _isProcessing = false;
      notifyListeners();
      return;
    }

    // Dramatic AI pause
    await Future.delayed(const Duration(milliseconds: 900));
    if (_state == null) {
      _isProcessing = false;
      notifyListeners();
      return;
    }

    _state = BattleEngine.aiTurn(_state!);
    notifyListeners();

    if (_state!.isOver) await _saveRecord();

    _isProcessing = false;
    notifyListeners();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> _saveRecord() async {
    if (_state == null) return;
    await DatabaseService().saveBattleRecord(BattleRecord(
      playerHero: _state!.playerHero.name,
      aiHero: _state!.aiHero.name,
      playerWon: _state!.playerWon,
      roundsPlayed: _state!.round,
      playedAt: DateTime.now().toIso8601String(),
    ));
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  void reset() {
    _state = null;
    _isProcessing = false;
    notifyListeners();
  }
}
