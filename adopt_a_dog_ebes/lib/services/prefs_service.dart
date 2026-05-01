import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyLastSearch = 'last_search_term'; // Exercise 4

  // ─── Favorites (Exercise 2: List<String>) ───────────────────────────────

  /// Returns the full list of saved favorites (may be empty).
  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  /// Adds [breedName] to the favorites list if not already present.
  Future<void> saveFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyFavorites) ?? [];
    if (!current.contains(breedName)) {
      current.add(breedName);
      await prefs.setStringList(_keyFavorites, current);
    }
  }

  /// Removes [breedName] from the favorites list.
  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyFavorites) ?? [];
    current.remove(breedName);
    await prefs.setStringList(_keyFavorites, current);
  }

  /// Clears all saved favorites.
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
  }

  // ─── Last search term (Exercise 4) ──────────────────────────────────────

  /// Persists the last search query the user typed.
  Future<void> saveLastSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, term);
  }

  /// Returns the last saved search term, or an empty string.
  Future<String> loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch) ?? '';
  }
}
