import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../engine/battle_engine.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  BattleResult? _lastResult;
  bool _isBattling = false;

  BattleResult? get lastResult => _lastResult;
  bool get isBattling => _isBattling;

  Future<void> startBattle(HeroModel playerHero, HeroModel aiHero) async {
    _isBattling = true;
    notifyListeners();

    // Simulate some delay for tension
    await Future.delayed(const Duration(seconds: 2));

    _lastResult = BattleEngine.simulate(playerHero, aiHero);
    
    // Save to history
    final record = BattleRecord(
      aiName: BattleEngine.getRandomAiName(),
      playerTeam: [playerHero.name],
      aiTeam: [aiHero.name],
      playerWon: _lastResult!.playerWon,
      roundsPlayed: _lastResult!.rounds,
      playedAt: DateTime.now().toIso8601String(),
    );
    
    await DatabaseService().saveBattleRecord(record);

    _isBattling = false;
    notifyListeners();
  }
}
