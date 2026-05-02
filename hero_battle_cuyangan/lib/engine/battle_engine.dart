import 'dart:math';
import '../models/hero_model.dart';

class BattleEngine {
  final Random _random = Random();

  int calculateDamage(HeroModel attacker, HeroModel defender) {
    final attackerPower = attacker.powerStats.strength + attacker.powerStats.combat;
    final defenderDefense = defender.powerStats.durability + defender.powerStats.combat;
    
    int baseDamage = (attackerPower - defenderDefense ~/ 2).clamp(10, 50);
    
    // Add randomness
    final random = _random.nextInt(21) - 10; // -10 to +10
    baseDamage += random;
    
    // Critical hit chance (10% chance)
    if (_random.nextInt(10) == 0) {
      baseDamage = (baseDamage * 1.5).round();
    }
    
    return baseDamage.clamp(5, 100);
  }

  int calculateSpeedAdvantage(HeroModel hero1, HeroModel hero2) {
    final speedDiff = hero1.powerStats.speed - hero2.powerStats.speed;
    if (speedDiff > 20) return 2;
    if (speedDiff > 10) return 1;
    if (speedDiff < -20) return -2;
    if (speedDiff < -10) return -1;
    return 0;
  }

  bool determineFirstAttacker(HeroModel hero1, HeroModel hero2) {
    final speedAdvantage = calculateSpeedAdvantage(hero1, hero2);
    if (speedAdvantage > 0) return true;
    if (speedAdvantage < 0) return false;
    
    final hero1Total = hero1.powerStats.speed + hero1.powerStats.intelligence;
    final hero2Total = hero2.powerStats.speed + hero2.powerStats.intelligence;
    
    if (hero1Total != hero2Total) {
      return hero1Total > hero2Total;
    }
    
    // If all else equal, random choice
    return _random.nextBool();
  }

  double calculateWinProbability(HeroModel hero1, HeroModel hero2) {
    final hero1Power = _calculateHeroPower(hero1);
    final hero2Power = _calculateHeroPower(hero2);
    final totalPower = hero1Power + hero2Power;
    
    return hero1Power / totalPower;
  }

  double _calculateHeroPower(HeroModel hero) {
    final stats = hero.powerStats;
    return (stats.intelligence * 1.2) +
           (stats.strength * 1.5) +
           (stats.speed * 1.0) +
           (stats.durability * 1.3) +
           (stats.power * 1.4) +
           (stats.combat * 1.1);
  }

  String getBattleOutcomeDescription(HeroModel winner, HeroModel loser) {
    final winnerPower = _calculateHeroPower(winner);
    final loserPower = _calculateHeroPower(loser);
    final powerRatio = winnerPower / loserPower;
    
    if (powerRatio > 2.0) {
      return '${winner.name} dominates ${loser.name} with overwhelming power!';
    } else if (powerRatio > 1.5) {
      return '${winner.name} defeats ${loser.name} in a decisive victory!';
    } else if (powerRatio > 1.2) {
      return '${winner.name} narrowly defeats ${loser.name} in a close battle!';
    } else {
      return '${winner.name} barely manages to defeat ${loser.name} in an epic struggle!';
    }
  }

  List<String> generateAttackFlavorText(HeroModel attacker, HeroModel defender, int damage) {
    final List<String> texts = [];
    
    if (damage > 50) {
      texts.add('${attacker.name} unleashes a devastating attack!');
      texts.add('Critical hit! Massive damage dealt!');
    } else if (damage > 30) {
      texts.add('${attacker.name} lands a powerful blow!');
      texts.add('Solid damage inflicted!');
    } else {
      texts.add('${attacker.name} strikes with precision!');
      texts.add('Quick and effective attack!');
    }
    
    if (attacker.powerStats.intelligence > 80) {
      texts.add('${attacker.name} uses tactical superiority!');
    }
    
    if (attacker.powerStats.speed > 80) {
      texts.add('Lightning-fast attack from ${attacker.name}!');
    }
    
    return texts;
  }
}