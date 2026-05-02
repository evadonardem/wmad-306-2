import 'dart:math';
import '../models/hero_model.dart';

class TurnResult {
  final String message;
  final int playerHpAfter;
  final int aiHpAfter;

  TurnResult({
    required this.message,
    required this.playerHpAfter,
    required this.aiHpAfter,
  });
}

class BattleEngine {
  static final Random _random = Random();

  static TurnResult executeTurn(
    HeroModel playerHero,
    HeroModel aiHero,
    int playerHpBefore,
    int aiHpBefore,
  ) {
    int playerHp = playerHpBefore;
    int aiHp = aiHpBefore;
    String message = 'Round: ';

    // Determine who goes first based on initiative
    final playerFirst = playerHero.initiative >= aiHero.initiative;

    if (playerFirst) {
      // Player attacks first
      final playerDamage = _calculateDamage(playerHero, aiHero);
      aiHp -= playerDamage;
      message +=
          '${playerHero.name} attacks ${aiHero.name} for $playerDamage damage! ';

      if (aiHp > 0) {
        // AI counter-attacks
        final aiDamage = _calculateDamage(aiHero, playerHero);
        playerHp -= aiDamage;
        message +=
            '${aiHero.name} attacks ${playerHero.name} for $aiDamage damage!';
      }
    } else {
      // AI attacks first
      final aiDamage = _calculateDamage(aiHero, playerHero);
      playerHp -= aiDamage;
      message +=
          '${aiHero.name} attacks ${playerHero.name} for $aiDamage damage! ';

      if (playerHp > 0) {
        // Player counter-attacks
        final playerDamage = _calculateDamage(playerHero, aiHero);
        aiHp -= playerDamage;
        message +=
            '${playerHero.name} attacks ${aiHero.name} for $playerDamage damage!';
      }
    }

    return TurnResult(
      message: message,
      playerHpAfter: max(0, playerHp),
      aiHpAfter: max(0, aiHp),
    );
  }

  static int _calculateDamage(HeroModel attacker, HeroModel defender) {
    // Base damage from attack stat with some randomness
    final baseDamage = attacker.attack;
    final variance = _random.nextInt(baseDamage ~/ 4 + 1);
    final rawDamage = baseDamage + variance;

    // Apply defense reduction
    final defense = defender.defense;
    final finalDamage = max(1, rawDamage - (defense ~/ 2));

    // Occasional critical hits
    final isCrit = _random.nextDouble() < 0.15; // 15% crit chance
    return isCrit ? (finalDamage * 1.5).toInt() : finalDamage;
  }
}
