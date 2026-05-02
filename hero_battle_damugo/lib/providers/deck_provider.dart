import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
	static const int maxDeckSize = 5;

	List<HeroModel> _deck = <HeroModel>[];
	List<HeroModel> get deck => List.unmodifiable(_deck);

	bool get isFull => _deck.length >= maxDeckSize;
	bool get isReady => _deck.isNotEmpty;
	int get deckSize => _deck.length;

	bool contains(HeroModel hero) => _deck.any((h) => h.id == hero.id);

	void addHero(HeroModel hero) {
		if (isFull || contains(hero)) {
			return;
		}
		_deck = <HeroModel>[..._deck, hero];
		notifyListeners();
	}

	void removeHero(HeroModel hero) {
		_deck = _deck.where((h) => h.id != hero.id).toList();
		notifyListeners();
	}

	void clearDeck() {
		_deck = <HeroModel>[];
		notifyListeners();
	}

	void replaceDeck(List<HeroModel> heroes) {
		final uniqueById = <String, HeroModel>{};
		for (final hero in heroes) {
			uniqueById[hero.id] = hero;
		}

		_deck = uniqueById.values.take(maxDeckSize).toList();
		notifyListeners();
	}

	Future<void> saveDeckToDb(String name) async {
		if (_deck.isEmpty) {
			return;
		}
		await DatabaseService().saveDeck(name, _deck);
	}
}

