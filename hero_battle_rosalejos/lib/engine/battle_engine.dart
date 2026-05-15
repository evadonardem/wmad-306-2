import 'dart:math';
import '../models/hero_model.dart';

class DamageResult {
  final int damage;
  final String moveName;
  final bool isEffective;

  DamageResult({
    required this.damage,
    required this.moveName,
    required this.isEffective,
  });
}

class BattleEngine {
  static const moveBrutalStrike = 'Brutal Strike';
  static const moveEnergyManifest = 'Energy Manifest';
  static const movePrecisionAssault = 'Precision Assault';

  static DamageResult calculateDamage(
      HeroModel attacker, HeroModel defender, String moveType) {
    int offensiveStat;
    int defensiveStat;
    String moveName;

    switch (moveType) {
      case moveEnergyManifest:
        offensiveStat = attacker.powerStats.power;
        defensiveStat = defender.powerStats.intelligence;
        moveName = 'Energy Manifest';
        break;
      case movePrecisionAssault:
        offensiveStat = attacker.powerStats.combat;
        defensiveStat = defender.powerStats.speed;
        moveName = 'Precision Assault';
        break;
      case moveBrutalStrike:
      default:
        offensiveStat = attacker.powerStats.strength;
        defensiveStat = defender.powerStats.durability;
        moveName = 'Brutal Strike';
        break;
    }

    // Base damage formula: max(5, (OffensiveStat * 1.5) - DefensiveStat)
    double damage = (offensiveStat * 1.5) - defensiveStat;
    damage = max(5.0, damage);

    // Type Advantage: Good > Bad > Neutral > Good (1.2x)
    bool isEffective = false;
    final aAlign = attacker.alignment.toLowerCase();
    final dAlign = defender.alignment.toLowerCase();

    if ((aAlign == 'good' && dAlign == 'bad') ||
        (aAlign == 'bad' && dAlign == 'neutral') ||
        (aAlign == 'neutral' && dAlign == 'good')) {
      damage *= 1.2;
      isEffective = true;
    }

    return DamageResult(
      damage: damage.round(),
      moveName: moveName,
      isEffective: isEffective,
    );
  }

  static String getRandomMove() {
    final moves = [
      moveBrutalStrike,
      moveEnergyManifest,
      movePrecisionAssault,
    ];
    return moves[Random().nextInt(moves.length)];
  }
}
