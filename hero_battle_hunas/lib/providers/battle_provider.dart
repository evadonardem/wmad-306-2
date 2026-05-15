import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  BattleProvider({BattleEngine? engine}) : _engine = engine ?? BattleEngine();

  final BattleEngine _engine;
  final DatabaseService _database = DatabaseService.instance;

  BattleResult? _result;
  List<HeroModel> _playerDeck = [];
  List<HeroModel> _opponents = [];
  bool _isSaving = false;

  BattleResult? get result => _result;
  List<HeroModel> get playerDeck => List.unmodifiable(_playerDeck);
  List<HeroModel> get opponents => List.unmodifiable(_opponents);
  bool get isSaving => _isSaving;

  Future<void> startBattle({
    required List<HeroModel> playerDeck,
    required List<HeroModel> opponents,
  }) async {
    _playerDeck = List.of(playerDeck);
    _opponents = List.of(opponents);
    _result = _engine.battle(_playerDeck, _opponents);
    notifyListeners();

    final record = BattleRecord(
      playerDeckName: 'Active Deck',
      opponentName: _opponents.map((hero) => hero.name).join(', '),
      didWin: _result!.didWin,
      playerScore: _result!.playerScore,
      opponentScore: _result!.opponentScore,
      createdAt: DateTime.now(),
    );
    _isSaving = true;
    notifyListeners();
    try {
      await _database.insertBattleRecord(record);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void reset() {
    _result = null;
    _playerDeck = [];
    _opponents = [];
    notifyListeners();
  }
}
