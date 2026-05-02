import '../models/hero_model.dart';

class BattleEngine {
  /// Calculates damage: (Attack - Defense). Minimum damage is 5.
  static int calculateDamage(HeroModel attacker, HeroModel defender) {
    int damage = attacker.attack - defender.defense;
    return damage < 5 ? 5 : damage;
  }

  /// Determines who acts first based on Initiative (Speed)[cite: 226].
  static bool playerGoesFirst(HeroModel player, HeroModel ai) {
    return player.initiative >= ai.initiative;
  }
}