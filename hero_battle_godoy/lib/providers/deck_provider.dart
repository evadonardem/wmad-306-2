import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
  static const int maxDeckSize = 5;
  List<HeroModel> _deck = [];

  List<HeroModel> get deck => List.unmodifiable(_deck);
  int get deckSize => _deck.length;
  bool get isFull => _deck.length >= maxDeckSize;
  bool get isReady => _deck.isNotEmpty;
  bool contains(HeroModel hero) => _deck.any((h) => h.id == hero.id);

  void addHero(HeroModel hero) {
    if (isFull || contains(hero)) return;
    _deck = [..._deck, hero];
    notifyListeners();
    saveDeckToDb('My Deck');
  }

  void removeHero(HeroModel hero) {
    _deck = _deck.where((h) => h.id != hero.id).toList();
    notifyListeners();
    saveDeckToDb('My Deck');
  }

  void clearDeck() {
    _deck = [];
    notifyListeners();
    saveDeckToDb('My Deck');
  }

  Future<void> loadDeck() async {
    final decks = await DatabaseService().loadDecks();
    if (decks.isNotEmpty) {
      final deckJson = decks.first['heroes'] as String;
      final heroList = jsonDecode(deckJson) as List;
      _deck = heroList.map((json) => HeroModel.fromJson(json as Map<String, dynamic>)).toList();
      notifyListeners();
    }
  }

  Future<void> saveDeckToDb(String name) async {
    await DatabaseService().saveDeck(name, _deck);
  }
}