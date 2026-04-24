import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keySearchQuery = 'search_query';

  // Ex2 — store a List<String> of favorites

  Future<void> saveFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyFavorites) ?? [];
    if (!current.contains(breedName)) {
      current.add(breedName);
      await prefs.setStringList(_keyFavorites, current);
    }
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyFavorites) ?? [];
    current.remove(breedName);
    await prefs.setStringList(_keyFavorites, current);
  }

  // Ex4 — persist the last search query

  Future<void> saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearchQuery, query);
  }

  Future<String> loadSearchQuery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySearchQuery) ?? '';
  }
}
