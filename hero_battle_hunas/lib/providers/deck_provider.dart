import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
  static const int maxDeckSize = 5;

  final DatabaseService _database = DatabaseService.instance;
  final List<HeroModel> _heroes = [];
  List<SavedDeck> _savedDecks = [];

  List<HeroModel> get heroes => List.unmodifiable(_heroes);
  List<SavedDeck> get savedDecks => List.unmodifiable(_savedDecks);
  bool get canBattle => _heroes.isNotEmpty;

  bool contains(HeroModel hero) => _heroes.any((item) => item.id == hero.id);

  void addHero(HeroModel hero) {
    if (contains(hero) || _heroes.length >= maxDeckSize) return;
    _heroes.add(hero);
    notifyListeners();
  }

  void removeHero(HeroModel hero) {
    _heroes.removeWhere((item) => item.id == hero.id);
    notifyListeners();
  }

  void loadDeck(List<HeroModel> heroes) {
    _heroes
      ..clear()
      ..addAll(heroes.take(maxDeckSize));
    notifyListeners();
  }

  Future<void> loadSavedDecks() async {
    _savedDecks = await _database.getSavedDecks();
    notifyListeners();
  }

  Future<void> saveCurrentDeck(String name) async {
    if (_heroes.isEmpty) return;
    await _database.saveDeck(name.trim().isEmpty ? 'My Deck' : name.trim(), _heroes);
    await loadSavedDecks();
  }

  Future<void> deleteSavedDeck(int id) async {
    await _database.deleteSavedDeck(id);
    await loadSavedDecks();
  }
}
