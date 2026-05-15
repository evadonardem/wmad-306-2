import 'package:flutter/material.dart';
import '../models/hero_model.dart';

class DeckProvider with ChangeNotifier {
  final List<HeroModel> _deck = [];

  List<HeroModel> get deck => _deck;

  void addToDeck(HeroModel hero) {
    if (!_deck.any((h) => h.id == hero.id)) {
      _deck.add(hero);
      notifyListeners();
    }
  }

  void removeFromDeck(String heroId) {
    _deck.removeWhere((h) => h.id == heroId);
    notifyListeners();
  }

  void clearDeck() {
    _deck.clear();
    notifyListeners();
  }
}