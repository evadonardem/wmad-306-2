import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  late final SuperheroApiService _apiService;
  
  List<HeroModel> _searchResults = [];
  HeroModel? _selectedHero;
  bool _isLoading = false;
  String? _error;

  HeroSearchProvider() {
    _apiService = SuperheroApiService();
  }

  // Getters - app state only (not ephemeral state like text field value)
  List<HeroModel> get searchResults => _searchResults;
  HeroModel? get selectedHero => _selectedHero;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Search heroes by name - results stored in app state
  Future<void> searchHeroes(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchHeroes(query);
      if (_searchResults.isEmpty) {
        _error = 'No heroes found for "$query"';
      }
    } catch (e) {
      _error = 'Error searching heroes: $e';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch detailed hero information by ID
  Future<void> getHeroById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedHero = await _apiService.fetchHero(id);
    } catch (e) {
      _error = 'Error loading hero: $e';
      _selectedHero = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a random hero
  Future<void> getRandomHero() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final heroes = await _apiService.fetchRandomHeroes(count: 1);
      _selectedHero = heroes.isNotEmpty ? heroes.first : null;
      if (_selectedHero == null) {
        _error = 'Failed to load random hero';
      }
    } catch (e) {
      _error = 'Error loading random hero: $e';
      _selectedHero = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get multiple random heroes for deck building
  Future<List<HeroModel>> getRandomHeroes({int count = 5}) async {
    try {
      return await _apiService.fetchRandomHeroes(count: count);
    } catch (e) {
      _error = 'Error loading heroes: $e';
      return [];
    }
  }

  /// Clear search results and selected hero
  void clearSearch() {
    _searchResults = [];
    _selectedHero = null;
    _error = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set selected hero directly
  void selectHero(HeroModel hero) {
    _selectedHero = hero;
    notifyListeners();
  }
}
