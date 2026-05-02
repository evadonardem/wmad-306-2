import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _apiService; // The required dependency

  HeroSearchProvider(this._apiService); // Constructor requiring the service

  List<HeroModel> _searchResults = [];
  bool _isLoading = false;

  List<HeroModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;

  Future<void> search(String query) async {
    if (query.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchHeroes(query);
    } catch (e) {
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}