import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';
import 'dart:convert';

class DeckProvider extends ChangeNotifier {
  static const int maxDeckSize = 5;
  List<HeroModel> _deck = [];

  List<HeroModel> get deck => List.unmodifiable(_deck);
  bool get isFull => _deck.length >= maxDeckSize;
  bool get isReady => _deck.isNotEmpty;
  int get deckSize => _deck.length;

  bool contains(HeroModel hero) => _deck.any((h) => h.id == hero.id);

  void addHero(HeroModel hero) {
    if (isFull || contains(hero)) return;
    _deck = [..._deck, hero];
    notifyListeners(); // ← triggers Consumer rebuilds
  }

  void removeHero(HeroModel hero) {
    _deck = _deck.where((h) => h.id != hero.id).toList();
    notifyListeners();
  }

  void clearDeck() {
    _deck = [];
    notifyListeners();
  }

  Future<void> saveDeckToDb(String name) async {
    try {
      // Serialize the Deck: Convert HeroModel objects to JSON string
      String encodedHeroes = jsonEncode(
        _deck.map((hero) => hero.toJson()).toList(),
      );
      print('Saving deck: $name with ${_deck.length} heroes');
      print('Encoded heroes length: ${encodedHeroes.length}');

      // Update the Database Call: Pass encodedHeroes string
      await DatabaseService().saveDeck(name, _deck);
      print('Deck saved successfully');
    } catch (e) {
      print('Error saving deck: $e');
      rethrow; // Re-throw to handle in UI
    }
  }
}
