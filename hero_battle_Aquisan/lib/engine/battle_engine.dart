import 'dart:math';
import '../models/hero_model.dart';

class BattleEngine {
  /// Calculates damage: (Attack - Defense). Minimum damage is 5.
  static int calculateDamage(int attack, int defense) {
    int damage = attack - defense;
    return max(5, damage);
  }

  /// Determines who acts first based on Initiative (Speed)[cite: 226].
  static bool playerGoesFirst(HeroModel player, HeroModel ai) {
    return player.speed >= ai.speed;
  }
}