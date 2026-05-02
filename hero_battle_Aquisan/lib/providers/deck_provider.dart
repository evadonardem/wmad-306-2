import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
  List<HeroModel> _deck = [];

  List<HeroModel> get deck => _deck;
  int get deckSize => _deck.length;
  bool get isFull => _deck.length >= 5; // Manual states max 5 heroes

  bool contains(HeroModel hero) => _deck.any((h) => h.id == hero.id);

  void addHero(HeroModel hero) {
    if (!isFull && !contains(hero)) {
      _deck.add(hero);
      notifyListeners(); // Rebuilds Consumer subtrees
    }
  }

  void removeHero(HeroModel hero) {
    _deck.removeWhere((h) => h.id == hero.id);
    notifyListeners();
  }

  // Exercise 1: Save current deck to SQLite
  Future<bool> saveDeckToDb(String name) async {
    if (_deck.isEmpty) return false;
    
    try {
      await DatabaseService().saveDeck(name, _deck);
      return true;
    } catch (e) {
      debugPrint('Error saving deck: $e');
      return false;
    }
  }

  void clearDeck() {
    _deck = [];
    notifyListeners();
  }
}