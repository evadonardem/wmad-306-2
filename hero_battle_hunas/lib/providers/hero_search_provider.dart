import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/prefs_service.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  HeroSearchProvider({SuperheroApiService? api, PrefsService? prefs})
      : _api = api ?? SuperheroApiService(),
        _prefs = prefs ?? PrefsService();

  final SuperheroApiService _api;
  final PrefsService _prefs;

  List<HeroModel> _randomHeroes = [];
  List<HeroModel> _results = [];
  String _query = '';
  bool _isLoading = false;
  String? _error;

  List<HeroModel> get randomHeroes => List.unmodifiable(_randomHeroes);
  List<HeroModel> get results => List.unmodifiable(_results);
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSearch => _query.trim().isNotEmpty;

  Future<void> initialize() async {
    _query = await _prefs.loadLastSearch() ?? '';
    if (_query.trim().isNotEmpty) {
      await search(_query);
    } else {
      await loadRandomHeroes();
    }
  }

  Future<void> loadRandomHeroes() async {
    await _run(() async {
      _randomHeroes = await _api.getRandomHeroes(count: 12);
      _results = [];
    });
  }

  Future<void> search(String value) async {
    _query = value.trim();
    await _prefs.saveLastSearch(_query);
    if (_query.isEmpty) {
      await loadRandomHeroes();
      return;
    }
    await _run(() async {
      _results = await _api.searchHeroes(_query);
    });
  }

  Future<List<HeroModel>> randomOpponents(int count) =>
      _api.getRandomHeroes(count: count);

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
