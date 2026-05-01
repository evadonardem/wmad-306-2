import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorite = 'favorite_breed';
  static const _keyFavorites = 'favorite_breeds';
  static const _keySearch = 'last_search_term';

  // Single favorite (kept for backwards compatibility)
  Future<void> saveFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavorite, breedName);
    // Also add to the list
    final list = await loadFavorites();
    if (!list.contains(breedName)) {
      list.add(breedName);
      await prefs.setStringList(_keyFavorites, list);
    }
  }

  Future<String?> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFavorite);
  }

  Future<void> clearFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorite);
    await prefs.remove(_keyFavorites);
  }

  // Multiple favorites
  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await loadFavorites();
    list.remove(breedName);
    await prefs.setStringList(_keyFavorites, list);
  }

  Future<void> saveSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearch, term);
  }

  Future<String?> loadSearchTerm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySearch);
  }
}
