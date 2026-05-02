// lib/engine/battle_engine.dart
import '../models/hero_model.dart';

class BattleResult {
  final int playerHp;
  final int aiHp;
  final String log;
  final bool battleOver;
  final bool playerWon;

  const BattleResult({
    required this.playerHp,
    required this.aiHp,
    required this.log,
    required this.battleOver,
    required this.playerWon,
  });
}

class BattleEngine {
  static BattleResult calculateRound({
    required HeroModel playerHero,
    required HeroModel aiHero,
    required int playerHp,
    required int aiHp,
    required int round,
  }) {
    // Player attacks AI
    final playerDmg = (playerHero.attack - aiHero.defense).clamp(5, 100);
    int newAiHp = (aiHp - playerDmg).clamp(0, aiHero.maxHp);
    String log = 'Round $round: ${playerHero.name} hits for $playerDmg dmg. AI HP: $newAiHp';

    if (newAiHp <= 0) {
      return BattleResult(
        playerHp: playerHp,
        aiHp: 0,
        log: '$log\n${playerHero.name} wins!',
        battleOver: true,
        playerWon: true,
      );
    }

    // AI attacks player
    final aiDmg = (aiHero.attack - playerHero.defense).clamp(5, 100);
    int newPlayerHp = (playerHp - aiDmg).clamp(0, playerHero.maxHp);
    log += '\nRound $round: ${aiHero.name} hits for $aiDmg dmg. Your HP: $newPlayerHp';

    if (newPlayerHp <= 0) {
      return BattleResult(
        playerHp: 0,
        aiHp: newAiHp,
        log: '$log\n${aiHero.name} wins!',
        battleOver: true,
        playerWon: false,
      );
    }

    return BattleResult(
      playerHp: newPlayerHp,
      aiHp: newAiHp,
      log: log,
      battleOver: false,
      playerWon: false,
    );
  }
}