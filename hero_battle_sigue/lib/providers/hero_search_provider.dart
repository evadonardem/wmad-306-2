import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';

class HeroSearchProvider extends ChangeNotifier {
  String _query = '';
  List<HeroModel> _results = [];

  String get query => _query;
  List<HeroModel> get results => List.unmodifiable(_results);

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  void setResults(List<HeroModel> results) {
    _results = results;
    notifyListeners();
  }

  void clear() {
    _query = '';
    _results = [];
    notifyListeners();
  }
}