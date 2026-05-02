import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  HeroModel? playerHero;
  HeroModel? aiHero;

  int playerHp = 0;
  int aiHp = 0;
  int round = 0;
  bool battleOver = false;
  bool playerWon = false;
  List<String> battleLog = [];

  void startBattle(HeroModel player, HeroModel ai) {
    playerHero = player;
    aiHero = ai;
    playerHp = player.maxHp;
    aiHp = ai.maxHp;
    round = 0;
    battleOver = false;
    playerWon = false;
    battleLog = ['Battle started: ${player.name} vs ${ai.name}'];
    notifyListeners();
  }

  Future<void> attackRound() async {
    if (battleOver || playerHero == null || aiHero == null) return;
    round++;

    // Use BattleEngine for pure combat logic
    final result = BattleEngine.calculateRound(
      playerHero: playerHero!,
      aiHero: aiHero!,
      playerHp: playerHp,
      aiHp: aiHp,
      round: round,
    );

    playerHp = result.playerHp;
    aiHp = result.aiHp;
    battleLog.add(result.log);
    battleOver = result.battleOver;
    playerWon = result.playerWon;

    if (battleOver) {
      await _saveRecord();
    }

    notifyListeners();
  }

  Future<void> _saveRecord() async {
    final record = BattleRecord(
      playerHero: playerHero!.name,
      aiHero: aiHero!.name,
      playerWon: playerWon,
      roundsPlayed: round,
      playedAt: DateTime.now().toIso8601String(),
    );
    await DatabaseService().saveBattleRecord(record);
  }

  void reset() {
    playerHero = null;
    aiHero = null;
    playerHp = 0;
    aiHp = 0;
    round = 0;
    battleOver = false;
    playerWon = false;
    battleLog = [];
    notifyListeners();
  }
}