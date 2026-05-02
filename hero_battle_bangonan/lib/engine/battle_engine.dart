import '../models/hero_model.dart';
import 'dart:math';

class BattleState {
  final int playerHP;
  final int aiHP;
  final int round;
  final List<String> log;

  const BattleState({
    required this.playerHP,
    required this.aiHP,
    required this.round,
    required this.log,
  });
}

class BattleEngine {
  static BattleState executeTurn(
    HeroModel playerHero,
    HeroModel aiHero,
    BattleState state,
  ) {
    final random = Random();
    var newPlayerHP = state.playerHP;
    var newAiHP = state.aiHP;
    final newLog = [...state.log];

    // Determine turn order based on initiative
    final playerFirst = playerHero.initiative >= aiHero.initiative;

    if (playerFirst) {
      // Player attacks first
      final damage = _calculateDamage(playerHero, aiHero, random);
      newAiHP -= damage;
      newLog.add('${playerHero.name} attacks for $damage damage!');

      if (newAiHP <= 0) {
        newLog.add('${aiHero.name} is defeated!');
        return BattleState(
          playerHP: newPlayerHP,
          aiHP: 0,
          round: state.round + 1,
          log: newLog,
        );
      }

      // AI counter-attacks
      final counterDamage = _calculateDamage(aiHero, playerHero, random);
      newPlayerHP -= counterDamage;
      newLog.add('${aiHero.name} counter-attacks for $counterDamage damage!');
    } else {
      // AI attacks first
      final damage = _calculateDamage(aiHero, playerHero, random);
      newPlayerHP -= damage;
      newLog.add('${aiHero.name} attacks for $damage damage!');

      if (newPlayerHP <= 0) {
        newLog.add('${playerHero.name} is defeated!');
        return BattleState(
          playerHP: 0,
          aiHP: newAiHP,
          round: state.round + 1,
          log: newLog,
        );
      }

      // Player counter-attacks
      final counterDamage = _calculateDamage(playerHero, aiHero, random);
      newAiHP -= counterDamage;
      newLog.add('${playerHero.name} counter-attacks for $counterDamage damage!');
    }

    return BattleState(
      playerHP: max(0, newPlayerHP),
      aiHP: max(0, newAiHP),
      round: state.round + 1,
      log: newLog,
    );
  }

  static int _calculateDamage(HeroModel attacker, HeroModel defender, Random random) {
    // 70% chance to use normal attack, 30% to use special attack
    final useSpecial = random.nextDouble() < 0.3;
    final attackPower = useSpecial ? attacker.specialAttack : attacker.attack;
    final defenseValue = defender.defense;

    // Damage = (Attack - Defense/2) with variance
    final baseDamage = (attackPower - defenseValue / 2).toInt();
    final variance = random.nextInt(baseDamage ~/ 4 + 1) - baseDamage ~/ 8;
    return max(1, baseDamage + variance);
  }

  static bool isBattleOver(BattleState state) {
    return state.playerHP <= 0 || state.aiHP <= 0;
  }

  static bool playerWon(BattleState state) {
    return state.aiHP <= 0;
  }
}
