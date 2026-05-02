import 'dart:math';

import '../models/hero_model.dart';

class BattleTurnResult {
  final int playerHp;
  final int aiHp;
  final String log;

  const BattleTurnResult({
    required this.playerHp,
    required this.aiHp,
    required this.log,
  });
}

class BattleEngine {
  static final Random _random = Random();

  static BattleTurnResult attack({
    required HeroModel attacker,
    required HeroModel defender,
    required int attackerHp,
    required int defenderHp,
    required bool attackerIsPlayer,
    bool special = false,
  }) {
    final base = special ? attacker.specialAttack : attacker.attack;
    final variance = _random.nextInt(11) - 5;
    final damage = max(5, base + variance - defender.defense);
    final nextDefenderHp = max(0, defenderHp - damage);
    final move = special ? 'special attack' : 'attack';

    return BattleTurnResult(
      playerHp: attackerIsPlayer ? attackerHp : nextDefenderHp,
      aiHp: attackerIsPlayer ? nextDefenderHp : attackerHp,
      log:
          '${attacker.name} used $move on ${defender.name} for $damage damage.',
    );
  }
}
