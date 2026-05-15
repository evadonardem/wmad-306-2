import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';

class BattleProvider with ChangeNotifier {
  HeroModel? _playerHero;
  HeroModel? _opponentHero;
  BattleRecord? _lastBattle;

  HeroModel? get playerHero => _playerHero;
  HeroModel? get opponentHero => _opponentHero;
  BattleRecord? get lastBattle => _lastBattle;

  void selectPlayerHero(HeroModel hero) {
    _playerHero = hero;
    notifyListeners();
  }

  void selectOpponentHero(HeroModel hero) {
    _opponentHero = hero;
    notifyListeners();
  }

  Future<void> startBattle() async {
    if (_playerHero == null || _opponentHero == null) return;

    // Simple battle logic: compare total powerstats
    int playerScore = calculateScore(_playerHero!);
    int opponentScore = calculateScore(_opponentHero!);

    String winnerId = playerScore >= opponentScore ? _playerHero!.id : _opponentHero!.id;
    String winnerName = playerScore >= opponentScore ? _playerHero!.name : _opponentHero!.name;

    _lastBattle = BattleRecord(
      playerHeroId: _playerHero!.id,
      playerHeroName: _playerHero!.name,
      opponentHeroId: _opponentHero!.id,
      opponentHeroName: _opponentHero!.name,
      winnerId: winnerId,
      winnerName: winnerName,
      date: DateTime.now(),
    );

    // Save to database
    await DatabaseService().insertBattleRecord(_lastBattle!);

    notifyListeners();
  }

  int calculateScore(HeroModel hero) {
    return int.parse(hero.powerstats.intelligence) +
           int.parse(hero.powerstats.strength) +
           int.parse(hero.powerstats.speed) +
           int.parse(hero.powerstats.durability) +
           int.parse(hero.powerstats.power) +
           int.parse(hero.powerstats.combat);
  }

  void resetBattle() {
    _playerHero = null;
    _opponentHero = null;
    _lastBattle = null;
    notifyListeners();
  }
}