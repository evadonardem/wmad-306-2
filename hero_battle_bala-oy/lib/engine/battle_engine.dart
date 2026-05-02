import 'dart:math';

import '../models/hero_model.dart';

class BattleTurnResult {
  final int playerDamage;
  final int aiDamage;
  final bool playerCritical;
  final bool aiCritical;

  const BattleTurnResult({
    required this.playerDamage,
    required this.aiDamage,
    required this.playerCritical,
    required this.aiCritical,
  });
}

class BattleEngine {
  static BattleTurnResult resolveTurn({
    required int round,
    required int playerAttack,
    required int playerSpecialAttack,
    required int playerDefense,
    required int aiAttack,
    required int aiSpecialAttack,
    required int aiDefense,
    HeroSkill? playerSkill,
    HeroSkill? aiSkill,
  }) {
    final rng = Random(round * 917);
    final playerUsesSpecial = playerSkill?.usesSpecial ?? (round % 3 == 0);
    final aiUsesSpecial = aiSkill?.usesSpecial ?? (round % 4 == 0);

    final basePlayer = playerSkill != null
        ? ((playerUsesSpecial ? playerSpecialAttack : playerAttack) + playerSkill.power) * playerSkill.multiplier
        : (playerUsesSpecial ? playerSpecialAttack : playerAttack).toDouble();
    final baseAi = aiSkill != null
        ? ((aiUsesSpecial ? aiSpecialAttack : aiAttack) + aiSkill.power) * aiSkill.multiplier
        : (aiUsesSpecial ? aiSpecialAttack : aiAttack).toDouble();

    final playerVariance = rng.nextInt(11) - 5;
    final aiVariance = rng.nextInt(11) - 5;
    final playerCritical = rng.nextInt(12) == 0;
    final aiCritical = rng.nextInt(14) == 0;

    var playerDamage = basePlayer.round() + playerVariance - (aiDefense ~/ 2);
    var aiDamage = baseAi.round() + aiVariance - (playerDefense ~/ 2);

    if (playerCritical) {
      playerDamage += 8;
    }
    if (aiCritical) {
      aiDamage += 8;
    }

    playerDamage = max(4, playerDamage);
    aiDamage = max(4, aiDamage);

    return BattleTurnResult(
      playerDamage: playerDamage,
      aiDamage: aiDamage,
      playerCritical: playerCritical,
      aiCritical: aiCritical,
    );
  }
}
