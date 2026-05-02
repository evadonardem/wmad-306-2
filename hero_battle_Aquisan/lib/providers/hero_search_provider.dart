import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  HeroSearchProvider({SuperheroApiService? apiService})
      : _apiService =
            apiService ?? SuperheroApiService(apiToken: '');

  final SuperheroApiService _apiService;

  List<HeroModel> _searchResults = <HeroModel>[];
  List<HeroModel> _featuredHeroes = <HeroModel>[];
  String _query = '';
  bool _isLoading = false;
  bool _hasLoadedInitialHeroes = false;
  String? _errorMessage;
  int _requestId = 0;

  List<HeroModel> get searchResults => List.unmodifiable(_searchResults);
  List<HeroModel> get featuredHeroes => List.unmodifiable(_featuredHeroes);
  List<HeroModel> get visibleHeroes =>
      _query.trim().isEmpty ? featuredHeroes : searchResults;
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get hasLoadedInitialHeroes => _hasLoadedInitialHeroes;
  String? get errorMessage => _errorMessage;
  bool get isShowingSearchResults => _query.trim().isNotEmpty;
  bool get hasResults => visibleHeroes.isNotEmpty;

  Future<void> loadInitialHeroes({int count = 20, bool forceRefresh = false}) async {
    if (_hasLoadedInitialHeroes && !forceRefresh) {
      return;
    }

    // Ensure state updates that notify listeners happen after the current build cycle
    // to avoid "setState() or markNeedsBuild() called during build" errors.
    await Future.microtask(() {});

    _setLoading(true);
    _clearError();

    try {
      _featuredHeroes = await _apiService.fetchRandomHeroes(count: count);
      _hasLoadedInitialHeroes = true;
      notifyListeners();
    } catch (e) {
      _setError('Error loading heroes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchHeroes(String value) async {
    final normalizedQuery = value.trim();
    _query = value;

    if (normalizedQuery.isEmpty) {
      _searchResults = <HeroModel>[];
      _clearError();
      notifyListeners();
      return;
    }

    // If this is triggered immediately (e.g., clearing during a build phase),
    // we defer the loading state to the next microtask.
    if (_isLoading == false) {
      await Future.microtask(() {});
    }

    final currentRequestId = ++_requestId;
    _setLoading(true);
    _clearError();

    try {
      final results = await _apiService.searchHeroes(normalizedQuery);
      if (currentRequestId != _requestId) {
        return;
      }

      _searchResults = results;
      notifyListeners();
    } catch (e) {
      if (currentRequestId != _requestId) {
        return;
      }
      _setError('Error searching heroes: $e');
    } finally {
      if (currentRequestId == _requestId) {
        _setLoading(false);
      }
    }
  }

  Future<HeroModel?> fetchHeroById(int id) async {
    _setLoading(true);
    _clearError();

    try {
      return await _apiService.fetchHero(id);
    } catch (e) {
      _setError('Error loading hero: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void updateQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void clearSearch() {
    _requestId++;
    _query = '';
    _searchResults = <HeroModel>[];
    _clearError();
    if (_isLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refreshFeaturedHeroes({int count = 20}) async {
    await loadInitialHeroes(count: count, forceRefresh: true);
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
