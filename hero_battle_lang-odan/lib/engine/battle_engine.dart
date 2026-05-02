import '../models/hero_model.dart';

class BattleTurn {
  final int playerDamage;
  final int aiDamage;
  final String log;

  const BattleTurn({
    required this.playerDamage,
    required this.aiDamage,
    required this.log,
  });
}

class BattleEngine {
  static BattleTurn resolveTurn({
    required HeroModel player,
    required HeroModel ai,
    required int round,
  }) {
    final playerUsesSpecial = round % 3 == 0;
    final aiUsesSpecial = round % 2 == 0;

    final playerAttack = playerUsesSpecial ? player.specialAttack : player.attack;
    final aiAttack = aiUsesSpecial ? ai.specialAttack : ai.attack;

    final playerDamage = (playerAttack - ai.defense).clamp(1, 9999);
    final aiDamage = (aiAttack - player.defense).clamp(1, 9999);

    return BattleTurn(
      playerDamage: playerDamage,
      aiDamage: aiDamage,
      log:
          'Round $round: ${player.name} dealt $playerDamage damage and ${ai.name} dealt $aiDamage damage.',
    );
  }
}
