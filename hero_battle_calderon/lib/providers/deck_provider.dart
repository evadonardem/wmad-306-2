import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class DeckModel {
  final int? id;
  final String name;
  final List<HeroModel> heroes;
  final DateTime created;

  DeckModel({
    this.id,
    required this.name,
    required this.heroes,
    required this.created,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'heroes': heroes.map((h) => h.toJson()).toList(),
      'created': created.toIso8601String(),
    };
  }
}

enum DeckSortBy { latest, name }

class DeckProvider extends ChangeNotifier {
  static const int maxDeckSize = 4;
  static const int totalDecksCount = 12;

  final DatabaseService _dbService = DatabaseService();
  List<DeckModel?> _savedDecks = List.filled(totalDecksCount, null);
  bool _isLoading = false;
  DeckSortBy _sortBy = DeckSortBy.latest;
  bool _isAscending = false;

  List<DeckModel?> get savedDecks => _savedDecks;
  bool get isLoading => _isLoading;
  DeckSortBy get sortBy => _sortBy;
  bool get isAscending => _isAscending;

  int get currentDecksCount => _savedDecks.where((d) => d != null).length;

  int get firstEmptyIndex {
    for (int i = 0; i < _savedDecks.length; i++) {
      if (_savedDecks[i] == null) return i;
    }
    return -1;
  }

  DeckProvider() {
    loadAllDecks();
  }

  void setSortBy(DeckSortBy criteria) {
    if (_sortBy == criteria) {
      _isAscending = !_isAscending;
    } else {
      _sortBy = criteria;
      _isAscending = false;
    }
    _refreshDecks();
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    _refreshDecks();
  }

  Future<void> loadAllDecks() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _refreshDecks();
    } catch (e) {
      debugPrint('Error loading decks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refreshDecks() async {
    final data = await _dbService.loadDecks();
    List<DeckModel> loaded = [];
    
    for (var row in data) {
       final List<HeroModel> heroes = _importHeroList(row['heroes'] as String);
       loaded.add(DeckModel(
         id: row['id'] as int,
         name: row['name'] as String,
         heroes: heroes,
         created: DateTime.parse(row['created'] as String),
       ));
    }

    if (_sortBy == DeckSortBy.name) {
      loaded.sort((a, b) {
        int cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return _isAscending ? cmp : -cmp;
      });
    } else {
      // Default latest
      loaded.sort((a, b) {
        int cmp = a.created.compareTo(b.created);
        return _isAscending ? cmp : -cmp; // Ascending = Oldest first, Descending = Latest first
      });
    }

    _savedDecks = List.filled(totalDecksCount, null);
    for (int i = 0; i < loaded.length && i < totalDecksCount; i++) {
      _savedDecks[i] = loaded[i];
    }
    notifyListeners();
  }

  List<HeroModel> _importHeroList(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => HeroModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> createOrUpdateDeck(int index, String name, List<HeroModel> heroes) async {
    if (index < 0 || index >= totalDecksCount) return;
    
    // For now, we just save to DB. 
    // If we wanted to "overwrite" a specific slot, we'd need more logic in DatabaseService.
    await _dbService.saveDeck(name, heroes);
    await _refreshDecks();
  }
  
  Future<void> deleteDeckAt(int index) async {
    final deck = _savedDecks[index];
    if (deck != null && deck.id != null) {
      await _dbService.deleteDeck(deck.id!);
      await _refreshDecks();
    }
  }

  Future<void> renameDeck(int id, String newName) async {
    await _dbService.updateDeckName(id, newName);
    await _refreshDecks();
  }

  bool containsHero(int deckIndex, String heroId) {
    final deck = _savedDecks[deckIndex];
    if (deck == null) return false;
    return deck.heroes.any((h) => h.id == heroId);
  }
}
