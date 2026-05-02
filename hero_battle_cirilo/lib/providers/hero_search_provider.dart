import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _apiService =
      SuperheroApiService(apiToken: kApiToken);
  List<HeroModel> _searchResults = [];
  String _query = '';

  HeroSearchProvider() {
    _loadInitialHeroes();
  }

  List<HeroModel> get searchResults => _searchResults;
  List<HeroModel> get heroes => _searchResults; // Alias for compatibility
  String get query => _query;

  void setQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  Future<void> _loadInitialHeroes() async {
    try {
      await _apiService.fetchApiRoot();
    } catch (_) {
      // If the API root endpoint is unavailable, continue with hero fetching.
    }

    _searchResults = await _apiService.fetchRandomHeroes(count: 20);
    notifyListeners();
  }

  Future<void> search(String name) async {
    _query = name;
    if (name.isEmpty) {
      _searchResults = await _apiService.fetchRandomHeroes(count: 20);
    } else {
      _searchResults = await _apiService.searchHeroes(name);
    }
    notifyListeners();
  }
}
