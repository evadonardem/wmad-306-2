import 'package:flutter/foundation.dart';

import 'prefs_service.dart';

class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  final PrefsService _prefsService = PrefsService();

  List<String> _favorites = <String>[];
  List<String> _recentBreeds = <String>[];
  String _lastSearch = '';
  bool _initialized = false;

  List<String> get favorites => List.unmodifiable(_favorites);
  List<String> get recentBreeds => List.unmodifiable(_recentBreeds);
  String get lastSearch => _lastSearch;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _favorites = await _prefsService.loadFavorites();
    _recentBreeds = await _prefsService.loadRecentBreeds();
    _lastSearch = await _prefsService.loadLastSearch();
    _initialized = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _favorites = await _prefsService.loadFavorites();
    _recentBreeds = await _prefsService.loadRecentBreeds();
    _lastSearch = await _prefsService.loadLastSearch();
    _initialized = true;
    notifyListeners();
  }

  Future<void> addFavorite(String breed) async {
    await _prefsService.addFavorite(breed);
    if (!_favorites.contains(breed)) {
      _favorites = [..._favorites, breed];
      notifyListeners();
    } else {
      await reload();
    }
  }

  Future<void> removeFavorite(String breed) async {
    await _prefsService.removeFavorite(breed);
    _favorites = _favorites.where((item) => item != breed).toList();
    notifyListeners();
  }

  Future<void> clearFavorites() async {
    await _prefsService.clearFavorites();
    _favorites = <String>[];
    notifyListeners();
  }

  Future<void> saveLastSearch(String value) async {
    await _prefsService.saveLastSearch(value);
    if (_lastSearch != value) {
      _lastSearch = value;
      notifyListeners();
    }
  }

  Future<void> addRecentBreed(String breed) async {
    await _prefsService.addRecentBreed(breed);
    final updated = _recentBreeds.where((item) => item != breed).toList();
    updated.insert(0, breed);
    if (updated.length > 6) {
      updated.removeRange(6, updated.length);
    }
    _recentBreeds = updated;
    notifyListeners();
  }

  Future<void> clearRecentBreeds() async {
    await _prefsService.clearRecentBreeds();
    _recentBreeds = <String>[];
    notifyListeners();
  }
}
