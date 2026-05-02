import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSelectionProvider extends ChangeNotifier {
  final SuperheroApiService _api;

  HeroSelectionProvider(this._api);

  List<HeroModel> _fullDatabase = [];
  List<HeroModel> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  String _currentQuery = '';

  List<HeroModel> get results => _currentQuery.isEmpty ? _fullDatabase.take(50).toList() : _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentQuery => _currentQuery;

  Future<void> initialize() async {
    if (_fullDatabase.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      _fullDatabase = await _api.fetchAllHeroes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _currentQuery = query.trim();
    if (_currentQuery.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (_fullDatabase.isEmpty) {
        await initialize();
      }
      
      _searchResults = _fullDatabase
          .where((h) => h.name.toLowerCase().contains(_currentQuery.toLowerCase()) || 
                       h.fullName.toLowerCase().contains(_currentQuery.toLowerCase()))
          .toList();

      // If local search fails to find anything, try API search
      if (_searchResults.isEmpty && _currentQuery.length > 2) {
        try {
          final apiResults = await _api.searchHeroes(_currentQuery);
          if (apiResults.isNotEmpty) {
            _searchResults = apiResults;
          }
        } catch (_) {
          // Ignore API errors and keep local empty results
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
