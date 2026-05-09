import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keySearchTerm = 'last_search_term';

  /// Saves [breedName] to the user's favorites list.
  Future<void> saveFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    if (!favorites.contains(breedName)) {
      favorites.add(breedName);
      await prefs.setStringList(_keyFavorites, favorites);
    }
  }

  /// Removes [breedName] from the user's favorites list.
  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    if (favorites.contains(breedName)) {
      favorites.remove(breedName);
      await prefs.setStringList(_keyFavorites, favorites);
    }
  }

  /// Returns the saved favorites list.
  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  /// Saves the last search term.
  Future<void> saveSearchTerm(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearchTerm, term);
  }

  /// Loads the last search term.
  Future<String> loadSearchTerm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySearchTerm) ?? '';
  }

  /// Clears all favorites.
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
  }
}
