import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  String _query = '';
  List<HeroModel> _results = [];
  bool _isLoading = false;
  String? _error;

  String get query => _query;
  List<HeroModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasResults => _results.isNotEmpty;

  Future<void> search(String query, SuperheroApiService api) async {
    if (query.trim().isEmpty) return;
    _query = query.trim();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await api.searchHeroes(_query);
    } catch (e) {
      _error = 'Search failed: $e';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _query = '';
    _results = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
