import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyLastSearch = 'last_search_term';
  static const _keyRecentBreeds = 'recent_breeds';

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? <String>[];
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, favorites);
  }

  Future<void> addFavorite(String breed) async {
    final favorites = await loadFavorites();
    if (!favorites.contains(breed)) {
      favorites.add(breed);
    }
    await saveFavorites(favorites);
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

  Future<void> saveLastSearch(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, value);
  }

  Future<String> loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch) ?? '';
  }

  Future<List<String>> loadRecentBreeds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyRecentBreeds) ?? <String>[];
  }

  Future<void> addRecentBreed(String breed) async {
    final prefs = await SharedPreferences.getInstance();
    final recentBreeds = prefs.getStringList(_keyRecentBreeds) ?? <String>[];

    recentBreeds.remove(breed);
    recentBreeds.insert(0, breed);

    if (recentBreeds.length > 6) {
      recentBreeds.removeRange(6, recentBreeds.length);
    }

    await prefs.setStringList(_keyRecentBreeds, recentBreeds);
  }

  Future<void> clearRecentBreeds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRecentBreeds);
  }
}
