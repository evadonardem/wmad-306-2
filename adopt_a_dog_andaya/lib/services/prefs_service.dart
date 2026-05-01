import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyLastSearch = 'last_breed_search';

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites);
    if (favorites != null) {
      return favorites;
    }

    // Fallback for legacy single-string storage.
    const legacyKey = 'favorite_breed';
    final legacyValue = prefs.getString(legacyKey);
    if (legacyValue != null && legacyValue.isNotEmpty) {
      return [legacyValue];
    }

    return <String>[];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, favorites);
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

  Future<void> saveLastSearchTerm(String? searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    if (searchTerm == null || searchTerm.isEmpty) {
      await prefs.remove(_keyLastSearch);
    } else {
      await prefs.setString(_keyLastSearch, searchTerm);
    }
  }

  Future<void> clearFavorite() async {
    await clearFavorites();
  }
}
