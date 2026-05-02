import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
  static const int maxDeckSize = 10;
  static const int maxBattleTeamSize = 5;
  List<HeroModel> _deck = [];
  List<HeroModel> _battleTeam = [];

  List<HeroModel> get deck => List.unmodifiable(_deck);
  List<HeroModel> get battleTeam => List.unmodifiable(_battleTeam);
  bool get isFull => _deck.length >= maxDeckSize;
  bool get isReady => _deck.isNotEmpty;
  bool get isBattleTeamReady => _battleTeam.length == maxBattleTeamSize;
  bool get isBattleTeamFull => _battleTeam.length >= maxBattleTeamSize;
  int get deckSize => _deck.length;
  int get battleTeamSize => _battleTeam.length;

  bool contains(HeroModel hero) => _deck.any((h) => h.id == hero.id);
  bool battleTeamContains(HeroModel hero) => _battleTeam.any((h) => h.id == hero.id);

  void addHero(HeroModel hero) {
    if (isFull || contains(hero)) return;
    _deck = [..._deck, hero];
    notifyListeners(); // ← triggers Consumer rebuilds
  }

  void removeHero(HeroModel hero) {
    _deck = _deck.where((h) => h.id != hero.id).toList();
    _battleTeam = _battleTeam.where((h) => h.id != hero.id).toList();
    notifyListeners();
  }

  void clearDeck() {
    _deck = [];
    _battleTeam = [];
    notifyListeners();
  }

  void replaceDeck(List<HeroModel> heroes) {
    _deck = heroes.take(maxDeckSize).toList();
    _battleTeam = [];
    notifyListeners();
  }

  void setBattleTeam(List<HeroModel> heroes) {
    _battleTeam = heroes
        .where((hero) => contains(hero))
        .toList(growable: false)
        .take(maxBattleTeamSize)
        .toList();
    notifyListeners();
  }

  void swapBattleTeamHeroes(int firstIndex, int secondIndex) {
    if (firstIndex < 0 || secondIndex < 0) return;
    if (firstIndex >= _battleTeam.length || secondIndex >= _battleTeam.length) return;
    if (firstIndex == secondIndex) return;

    final heroes = [..._battleTeam];
    final hero = heroes[firstIndex];
    heroes[firstIndex] = heroes[secondIndex];
    heroes[secondIndex] = hero;
    _battleTeam = heroes;
    notifyListeners();
  }

  void moveBattleHeroToIndex(HeroModel hero, int targetIndex) {
    final currentIndex = _battleTeam.indexWhere((h) => h.id == hero.id);
    if (currentIndex == -1) return;
    if (targetIndex < 0 || targetIndex >= _battleTeam.length) return;
    if (currentIndex == targetIndex) return;

    final heroes = [..._battleTeam]..removeAt(currentIndex);
    heroes.insert(targetIndex, hero);
    _battleTeam = heroes;
    notifyListeners();
  }

  void toggleBattleHero(HeroModel hero) {
    if (!contains(hero)) return;

    if (battleTeamContains(hero)) {
      _battleTeam = _battleTeam.where((h) => h.id != hero.id).toList();
      notifyListeners();
      return;
    }

    if (isBattleTeamFull) return;
    _battleTeam = [..._battleTeam, hero];
    notifyListeners();
  }

  void removeFromBattleTeam(HeroModel hero) {
    _battleTeam = _battleTeam.where((h) => h.id != hero.id).toList();
    notifyListeners();
  }

  void chooseRandomBattleTeam() {
    final heroes = [..._deck]..shuffle(Random());
    _battleTeam = heroes.take(maxBattleTeamSize).toList();
    notifyListeners();
  }

  HeroModel? battleHeroAt(int index) {
    if (index < 0 || index >= _battleTeam.length) return null;
    return _battleTeam[index];
  }

  Future<void> saveDeckToDb(String name) async {
    await DatabaseService().saveDeck(name, _deck);
  }
}