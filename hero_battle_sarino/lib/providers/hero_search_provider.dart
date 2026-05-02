import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
  final SuperheroApiService _api;
  List<HeroModel> _searchResults = [];
  String _query = '';
  bool _isLoading = false;

  HeroSearchProvider(this._api);

  List<HeroModel> get searchResults => _searchResults;
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get hasNoResults =>
      _query.isNotEmpty && !_isLoading && _searchResults.isEmpty;

  void updateQuery(String newQuery) {
    _query = newQuery;
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
      _searchResults = await _api.searchHeroes(query);
    } catch (e) {
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
