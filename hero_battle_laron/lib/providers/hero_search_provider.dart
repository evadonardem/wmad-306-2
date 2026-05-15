import 'package:flutter/material.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider with ChangeNotifier {
  final SuperheroApiService _apiService = SuperheroApiService();

  List<HeroModel> _heroes = [];
  bool _isLoading = false;
  String _error = '';

  List<HeroModel> get heroes => _heroes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> searchHeroes(String query) async {
    if (query.isEmpty) {
      _heroes = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _heroes = await _apiService.searchHeroes(query);
    } catch (e) {
      _error = e.toString();
      _heroes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _heroes = [];
    _error = '';
    notifyListeners();
  }
}