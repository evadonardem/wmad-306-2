import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';
import '../services/prefs_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _api;
  final PrefsService _prefs = PrefsService();

  HeroSearchProvider(this._api);

  List<HeroModel> _fullDatabase = [];
  List<HeroModel> _results = [];
  List<HeroModel> _randomResults = [];
  bool _isLoading = false;
  String _error = '';
  String _lastQuery = '';

  List<HeroModel> get results => _results;
  List<HeroModel> get randomResults => _randomResults;
  List<HeroModel> get fullDatabase => _fullDatabase;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get lastQuery => _lastQuery;

  /// Initialize the global database.
  Future<void> initialize() async {
    if (_fullDatabase.isNotEmpty) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _fullDatabase = await _api.fetchAllHeroes();
      await fetchRandom();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _results = [];
      _lastQuery = '';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    _lastQuery = trimmedQuery;
    notifyListeners();

    try {
      await _prefs.saveLastSearch(trimmedQuery);

      if (_fullDatabase.isEmpty) {
        await initialize();
      }

      // Perform local search for better speed
      _results = _fullDatabase
          .where((h) =>
              h.name.toLowerCase().contains(trimmedQuery.toLowerCase()) ||
              h.fullName.toLowerCase().contains(trimmedQuery.toLowerCase()))
          .toList();

      // If local search fails, fall back to Superhero API
      if (_results.isEmpty) {
        _results = await _api.searchHeroes(trimmedQuery);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRandom() async {
    if (_fullDatabase.isEmpty) {
      await initialize();
      return; // initialize calls fetchRandom
    }

    final List<HeroModel> copy = List.from(_fullDatabase);
    copy.shuffle();
    _randomResults = copy.take(40).toList();
    notifyListeners();
  }

  Future<void> loadMoreRandom() async {
    if (_fullDatabase.isEmpty || _isLoading) return;

    // Get IDs currently in random results to avoid duplicates in the new batch
    final existingIds = _randomResults.map((h) => h.id).toSet();
    
    final List<HeroModel> available = _fullDatabase
        .where((h) => !existingIds.contains(h.id))
        .toList();
    
    if (available.isEmpty) return;

    available.shuffle();
    final nextBatch = available.take(20).toList();
    
    _randomResults.addAll(nextBatch);
    notifyListeners();
  }

  Future<void> loadLastSearch() async {
    if (_fullDatabase.isEmpty) {
      await initialize();
    }

    final query = await _prefs.loadLastSearch();
    if (query != null && query.isNotEmpty) {
      _lastQuery = query;
      await search(query);
    } else {
      await fetchRandom();
    }
  }

  void clearSearch() {
    _results = [];
    _lastQuery = '';
    notifyListeners();
  }
}
