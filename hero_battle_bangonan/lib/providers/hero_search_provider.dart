import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';

class HeroSearchProvider extends ChangeNotifier {
  List<HeroModel> _results = [];
  String _query = '';
  List<HeroModel> get results => List.unmodifiable(_results);
  String get query => _query;

  void setResults(List<HeroModel> heroes) {
    _results = heroes;
    notifyListeners();
  }

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }
}
