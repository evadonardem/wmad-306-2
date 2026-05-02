import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/prefs_service.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  HeroSearchProvider({required String apiToken})
      : _api = SuperheroApiService(apiToken: apiToken);

  final SuperheroApiService _api;
  final PrefsService _prefs = PrefsService();

  List<HeroModel> _results = [];
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<HeroModel> get results => List.unmodifiable(_results);
  String get query => _query;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> search(String query) async {
    _query = query;
    _errorMessage = null;

    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _results = await _api.searchHeroes(query);
      await _prefs.saveLastSearch(query);
    } on DioException catch (e) {
      _results = [];
      _errorMessage = e.message ?? 'Search failed.';
    } catch (e) {
      _results = [];
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> loadLastSearch() => _prefs.loadLastSearch();
}
