import 'package:flutter/foundation.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';
import '../engine/battle_engine.dart';

class BattleProvider extends ChangeNotifier {
  BattleState? _battleState;
  final bool _isLoading = false;

  BattleState? get battleState => _battleState;
  bool get isLoading => _isLoading;
  bool get isBattleActive => _battleState != null && !BattleEngine.isBattleOver(_battleState!);

  void startBattle(HeroModel playerHero, HeroModel aiHero) {
    _battleState = BattleState(
      playerHP: playerHero.maxHp,
      aiHP: aiHero.maxHp,
      round: 1,
      log: ['Battle started: ${playerHero.name} vs ${aiHero.name}'],
    );
    notifyListeners();
  }

  void executeTurn(HeroModel playerHero, HeroModel aiHero) {
    if (_battleState == null || BattleEngine.isBattleOver(_battleState!)) return;
    
    _battleState = BattleEngine.executeTurn(playerHero, aiHero, _battleState!);
    notifyListeners();
  }

  Future<void> saveBattleRecord(BattleRecord record) async {
    await DatabaseService().saveBattleRecord(record);
    notifyListeners();
  }

  void resetBattle() {
    _battleState = null;
    notifyListeners();
  }
}
