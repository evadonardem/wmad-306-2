import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';
import '../services/prefs_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _api;
  final PrefsService _prefs = PrefsService();

  List<HeroModel> _allHeroes = [];
  List<HeroModel> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuery = '';

  List<HeroModel> get searchResults => List.unmodifiable(_searchResults);
  List<HeroModel> get allHeroes => List.unmodifiable(_allHeroes);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuery => _currentQuery;

  HeroSearchProvider() : _api = SuperheroApiService();

  // Initialize with all heroes for local filtering
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allHeroes = await _api.fetchAllHeroes();
      print('All heroes loaded: ${_allHeroes.length}');

      // Load last search query for persistence
      await loadLastSearch();
    } catch (e) {
      _error = 'Failed to load heroes: $e';
      print('Initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Local Filtering: Filter existing list instead of API calls
  void searchHeroes(String query) {
    _currentQuery = query;

    if (query.trim().isEmpty) {
      _searchResults = []; // Empty state will show full list
    } else {
      _searchResults = _allHeroes
          .where(
            (hero) => hero.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
      print('Search results for "$query": ${_searchResults.length}');
    }

    notifyListeners();
  }

  // Search Persistence: Save last search query only on submit
  Future<void> saveSearchQuery(String query) async {
    try {
      await _prefs.saveLastSearch(query);
      print('Search query saved: $query');
    } catch (e) {
      print('Failed to save search query: $e');
    }
  }

  // Load last search query on app restart
  Future<String?> loadLastSearch() async {
    try {
      final lastSearch = await _prefs.loadLastSearch();
      if (lastSearch != null && lastSearch.isNotEmpty) {
        _currentQuery = lastSearch;
        _searchResults = _allHeroes
            .where(
              (hero) =>
                  hero.name.toLowerCase().contains(lastSearch.toLowerCase()),
            )
            .toList();
        print(
          'Last search loaded: $lastSearch (${_searchResults.length} results)',
        );
        notifyListeners();
        return lastSearch; // Return the query for pre-filling
      }
    } catch (e) {
      print('Failed to load last search: $e');
    }
    return null;
  }

  // Clear Search: Reset to show all heroes
  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  // Check if currently searching
  bool get isSearching => _currentQuery.isNotEmpty;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
