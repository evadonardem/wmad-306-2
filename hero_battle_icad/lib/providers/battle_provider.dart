import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../engine/battle_engine.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  List<HeroModel> playerHeroes = [];
  List<HeroModel> aiHeroes = [];
  HeroModel? currentPlayerHero;
  HeroModel? currentAiHero;

  int playerHp = 0;
  int aiHp = 0;
  List<String> battleLog = [];
  bool isBattleOver = false;

  void startBattle(List<HeroModel> playerDeck, List<HeroModel> aiDeck) {
    playerHeroes = List.of(playerDeck);
    aiHeroes = List.of(aiDeck);
    currentPlayerHero = playerHeroes.isNotEmpty ? playerHeroes.first : null;
    currentAiHero = aiHeroes.isNotEmpty ? aiHeroes.first : null;
    playerHp = currentPlayerHero?.maxHp ?? 0;
    aiHp = currentAiHero?.maxHp ?? 0;
    battleLog = [
      'Battle Start: ${playerHeroes.length} vs ${aiHeroes.length}!',
      'Player sends ${currentPlayerHero?.name ?? 'No hero'} vs AI sends ${currentAiHero?.name ?? 'No hero'}.',
    ];
    isBattleOver = false;
    notifyListeners();
  }

  Future<void> executeTurn() async {
    if (isBattleOver || currentPlayerHero == null || currentAiHero == null)
      return;

    if (BattleEngine.playerGoesFirst(currentPlayerHero!, currentAiHero!)) {
      _resolveStrike(attackerIsPlayer: true);
      if (isBattleOver || currentAiHero == null) return;
      _resolveStrike(attackerIsPlayer: false);
    } else {
      _resolveStrike(attackerIsPlayer: false);
      if (isBattleOver || currentPlayerHero == null) return;
      _resolveStrike(attackerIsPlayer: true);
    }

    notifyListeners();
  }

  void _resolveStrike({required bool attackerIsPlayer}) {
    final attacker = attackerIsPlayer ? currentPlayerHero! : currentAiHero!;
    final defender = attackerIsPlayer ? currentAiHero! : currentPlayerHero!;
    final damage = BattleEngine.calculateDamage(attacker, defender);

    if (attackerIsPlayer) {
      aiHp -= damage;
      battleLog.insert(
        0,
        '${attacker.name} hits ${defender.name} for $damage damage!',
      );
      if (aiHp <= 0) {
        battleLog.insert(0, '${defender.name} has been defeated!');
        _advanceAiHero();
      }
    } else {
      playerHp -= damage;
      battleLog.insert(
        0,
        '${attacker.name} hits ${defender.name} for $damage damage!',
      );
      if (playerHp <= 0) {
        battleLog.insert(0, '${defender.name} has been defeated!');
        _advancePlayerHero();
      }
    }
  }

  void _advanceAiHero() {
    if (aiHeroes.length <= 1) {
      _endBattle(true);
      return;
    }

    aiHeroes.removeAt(0);
    currentAiHero = aiHeroes.first;
    aiHp = currentAiHero!.maxHp;
    battleLog.insert(0, 'AI sends ${currentAiHero!.name} into battle!');
  }

  void _advancePlayerHero() {
    if (playerHeroes.length <= 1) {
      _endBattle(false);
      return;
    }

    playerHeroes.removeAt(0);
    currentPlayerHero = playerHeroes.first;
    playerHp = currentPlayerHero!.maxHp;
    battleLog.insert(0, 'Player sends ${currentPlayerHero!.name} into battle!');
  }

  void _endBattle(bool playerWon) {
    isBattleOver = true;
    battleLog.insert(0, playerWon ? 'YOU WIN!' : 'YOU LOST!');

    final record = BattleRecord(
      playerHero: playerHeroes.map((hero) => hero.name).join(', '),
      aiHero: aiHeroes.map((hero) => hero.name).join(', '),
      playerWon: playerWon,
      roundsPlayed: (battleLog.length / 2).ceil(),
      playedAt: DateTime.now().toIso8601String(),
    );
    DatabaseService().insertBattle(record);
    notifyListeners();
  }
}
