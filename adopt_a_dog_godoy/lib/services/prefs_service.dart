import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyLastSearch = 'last_search_term';

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? <String>[];
  }

  Future<void> saveFavorites(List<String> breeds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, breeds);
  }

  Future<void> addFavorite(String breed) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(breed)) {
      favorites.add(breed);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String breed) async {
    final favorites = await loadFavorites();
    favorites.remove(breed);
    await saveFavorites(favorites);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
  }

  Future<String?> loadLastSearchTerm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch);
  }

  Future<void> saveLastSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, term);
  }
}
