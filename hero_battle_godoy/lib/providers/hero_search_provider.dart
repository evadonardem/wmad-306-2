import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';
import '../services/prefs_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _api = SuperheroApiService();

  String _query = '';
  List<HeroModel> _results = [];
  List<HeroModel> _randomHeroes = [];
  bool _isLoading = false;
  String _error = '';

  String get query => _query;
  List<HeroModel> get results => _results;
  List<HeroModel> get randomHeroes => _randomHeroes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadRandomHeroes({int count = 20}) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _randomHeroes = await _api.fetchRandomHeroes(count: count);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchHeroes(String name) async {
    _query = name;
    if (name.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _results = await _api.searchHeroes(name);
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _query = '';
    _results = [];
    _error = '';
    notifyListeners();
  }

  Future<void> loadLastSearch() async {
    final lastQuery = await PrefsService().loadLastSearch();
    if (lastQuery != null && lastQuery.isNotEmpty) {
      _query = lastQuery;
      await searchHeroes(lastQuery);
    }
  }

  Future<void> saveLastSearch() async {
    if (_query.isNotEmpty) {
      await PrefsService().saveLastSearch(_query);
    }
  }
}
