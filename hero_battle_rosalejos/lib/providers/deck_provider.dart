import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
  static const int maxDeckSize = 5;
  static const int maxTotalCost = 15;

  List<HeroModel> _deck = [];
  List<HeroModel> get deck => List.unmodifiable(_deck);

  bool get isFull => _deck.length >= maxDeckSize;
  bool get isReady => _deck.isNotEmpty;
  int get deckSize => _deck.length;

  int get totalCost => _deck.fold(0, (sum, hero) => sum + hero.cost);

  bool contains(HeroModel hero) => _deck.any((h) => h.id == hero.id);

  bool canAdd(HeroModel hero) {
    if (isFull) return false;
    if (contains(hero)) return false;
    if (totalCost + hero.cost > maxTotalCost) return false;
    return true;
  }

  void addHero(HeroModel hero) {
    if (!canAdd(hero)) return;
    _deck = [..._deck, hero];
    notifyListeners();
  }

  void removeHero(HeroModel hero) {
    _deck = _deck.where((h) => h.id != hero.id).toList();
    notifyListeners();
  }

  void clearDeck() {
    _deck = [];
    notifyListeners();
  }

  void loadDeck(List<HeroModel> heroes) {
    _deck = List.from(heroes);
    notifyListeners();
  }

  Future<void> saveDeckToDb(String name) async {
    await DatabaseService().saveDeck(name, _deck);
    clearDeck();
  }
}
