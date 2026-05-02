import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/prefs_service.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  HeroSearchProvider({SuperheroApiService? api, PrefsService? prefs})
    : _api = api ?? SuperheroApiService(apiToken: kApiToken),
      _prefs = prefs ?? PrefsService();

  final SuperheroApiService _api;
  final PrefsService _prefs;

  List<HeroModel> _results = [];
  bool _isLoading = false;
  String? _error;
  String _lastQuery = '';

  List<HeroModel> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get lastQuery => _lastQuery;
  bool get hasQuery => _lastQuery.trim().isNotEmpty;

  Future<String?> loadLastSearch() => _prefs.loadLastSearch();

  Future<void> search(String query) async {
    final trimmed = query.trim();
    _lastQuery = trimmed;
    if (trimmed.isEmpty) {
      _results = [];
      _error = null;
      notifyListeners();
      return;
    }

    await _prefs.saveLastSearch(trimmed);
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _results = await _api.searchHeroes(trimmed);
    } catch (e) {
      _error = e.toString();
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _lastQuery = '';
    _results = [];
    _error = null;
    notifyListeners();
  }
}
