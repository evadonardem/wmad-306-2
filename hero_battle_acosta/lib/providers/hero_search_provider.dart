import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  List<HeroModel> _searchResults = [];
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  List<HeroModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> searchHeroes(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final apiService = SuperheroApiService();
      _searchResults = await apiService.searchHeroes(query);
    } catch (e) {
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isLoading = false;
    notifyListeners();
  }
}
