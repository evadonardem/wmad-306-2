import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';

class HeroSearchProvider extends ChangeNotifier {
  String _searchQuery = '';
  List<HeroModel> _searchResults = [];

  String get searchQuery => _searchQuery;
  List<HeroModel> get searchResults => List.unmodifiable(_searchResults);

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSearchResults(List<HeroModel> results) {
    _searchResults = results;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
