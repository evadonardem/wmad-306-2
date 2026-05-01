import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyBreedSearchQuery = 'breed_search_query';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites);
    return favorites == null ? <String>{} : favorites.toSet();
  }

  Future<void> saveFavorites(Set<String> routes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, routes.toList());
  }

  Future<void> addFavorite(String path) async {
    final favorites = await loadFavorites();
    favorites.add(path);
    await saveFavorites(favorites);
  }

  Future<void> removeFavorite(String path) async {
    final favorites = await loadFavorites();
    favorites.remove(path);
    await saveFavorites(favorites);
  }

  Future<bool> isFavorite(String path) async {
    final favorites = await loadFavorites();
    return favorites.contains(path);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
  }

  Future<String> loadBreedSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBreedSearchQuery) ?? '';
  }

  Future<void> saveBreedSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBreedSearchQuery, query);
  }
}
