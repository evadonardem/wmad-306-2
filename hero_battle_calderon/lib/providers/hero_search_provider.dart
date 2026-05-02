import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';
import '../services/prefs_service.dart';

enum HeroSortBy {
  none,
  total,
  intelligence,
  strength,
  speed,
  durability,
  power,
  combat
}

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _api;
  final PrefsService _prefs = PrefsService();

  HeroSearchProvider(this._api);

  List<HeroModel> _fullDatabase = [];
  List<HeroModel> _searchResults = [];
  List<HeroModel> _randomHeroes = [];
  bool _isLoading = false;
  String _error = '';
  HeroSortBy _sortBy = HeroSortBy.total;
  bool _isAscending = false;
  String _currentQuery = '';

  List<HeroModel> get results {
    // Determine the base list: search results or the entire database
    List<HeroModel> baseList = _currentQuery.isEmpty ? _fullDatabase : _searchResults;
    
    // Create a copy to sort
    List<HeroModel> sortedList = List.from(baseList);
    
    if (_sortBy != HeroSortBy.none) {
      sortedList.sort((a, b) {
        int valA = _getStatValue(a, _sortBy);
        int valB = _getStatValue(b, _sortBy);
        return _isAscending ? valA.compareTo(valB) : valB.compareTo(valA);
      });
    }
    
    // Always show top 200 of the current sorted/filtered view
    return sortedList.take(200).toList();
  }

  // New getter for Home Screen
  List<HeroModel> get randomResults => _randomHeroes.isNotEmpty ? _randomHeroes : results;

  bool get isLoading => _isLoading;
  String get error => _error;
  HeroSortBy get sortBy => _sortBy;
  bool get isAscending => _isAscending;
  String get currentQuery => _currentQuery;

  int _getStatValue(HeroModel hero, HeroSortBy criteria) {
    switch (criteria) {
      case HeroSortBy.intelligence: return hero.powerStats.intelligence;
      case HeroSortBy.strength: return hero.powerStats.strength;
      case HeroSortBy.speed: return hero.powerStats.speed;
      case HeroSortBy.durability: return hero.powerStats.durability;
      case HeroSortBy.power: return hero.powerStats.power;
      case HeroSortBy.combat: return hero.powerStats.combat;
      case HeroSortBy.total:
        return hero.powerStats.intelligence +
               hero.powerStats.strength +
               hero.powerStats.speed +
               hero.powerStats.durability +
               hero.powerStats.power +
               hero.powerStats.combat;
      default: return 0;
    }
  }

  void setSortBy(HeroSortBy criteria) {
    if (_sortBy == criteria) {
      _isAscending = !_isAscending;
    } else {
      _sortBy = criteria;
      _isAscending = false;
    }
    notifyListeners();
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  /// Initialize the global database.
  Future<void> initialize() async {
    if (_fullDatabase.isNotEmpty) return;
    
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _fullDatabase = await _api.fetchAllHeroes();
      
      // Load last search query
      final lastQuery = await _prefs.loadLastSearch();
      if (lastQuery != null && lastQuery.isNotEmpty) {
        await search(lastQuery);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _currentQuery = query.trim();
    if (_currentQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await _prefs.saveLastSearch(_currentQuery);

      // If database is empty, try to load it first
      if (_fullDatabase.isEmpty) {
        await initialize();
      }
      
      // Perform local search for better speed
      _searchResults = _fullDatabase
          .where((h) => h.name.toLowerCase().contains(_currentQuery.toLowerCase()) || 
                       h.fullName.toLowerCase().contains(_currentQuery.toLowerCase()))
          .toList();
      
      // If local search fails to find anything, try API search
      if (_searchResults.isEmpty) {
        _searchResults = await _api.searchHeroes(_currentQuery);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Shuffle the database to provide a random selection for home
  Future<void> fetchRandom() async {
    if (_fullDatabase.isEmpty) {
      await initialize();
    }
    final List<HeroModel> copy = List.from(_fullDatabase);
    copy.shuffle();
    _randomHeroes = copy.take(200).toList();
    notifyListeners();
  }

  Future<HeroModel> getRandomHero() async {
    if (_fullDatabase.isNotEmpty) {
      final list = List<HeroModel>.from(_fullDatabase)..shuffle();
      return list.first;
    }
    final heroes = await _api.fetchRandomHeroes(count: 1);
    return heroes.first;
  }
}
