import 'dart:math';
import '../models/hero_model.dart';

class BattleEngine {
  static const int maxRounds = 10;

  static BattleResult simulateRound(
    HeroModel playerHero,
    HeroModel aiHero,
    int playerHp,
    int aiHp,
  ) {
    final random = Random();

    // Player attack
    final playerAttackRoll = random.nextInt(20) + 1;
    final playerAttackValue = playerHero.attack + playerAttackRoll;
    final playerHits = playerAttackValue > aiHero.defense;
    final playerDamage = playerHits
        ? random.nextInt(playerHero.attack ~/ 2) + playerHero.attack ~/ 3
        : 0;

    // AI attack
    final aiAttackRoll = random.nextInt(20) + 1;
    final aiAttackValue = aiHero.attack + aiAttackRoll;
    final aiHits = aiAttackValue > playerHero.defense;
    final aiDamage = aiHits
        ? random.nextInt(aiHero.attack ~/ 2) + aiHero.attack ~/ 3
        : 0;

    return BattleResult(
      playerDamage: playerDamage,
      aiDamage: aiDamage,
      playerHit: playerHits,
      aiHit: aiHits,
    );
  }

  static String getAttackDescription(
    bool playerAttack,
    String attacker,
    String defender,
    bool hit,
    int damage,
  ) {
    if (!hit) {
      return '$attacker tried to attack $defender but missed!';
    }
    return '$attacker attacks $defender for $damage damage!';
  }
}

class BattleResult {
  final int playerDamage;
  final int aiDamage;
  final bool playerHit;
  final bool aiHit;

  BattleResult({
    required this.playerDamage,
    required this.aiDamage,
    required this.playerHit,
    required this.aiHit,
  });
}
