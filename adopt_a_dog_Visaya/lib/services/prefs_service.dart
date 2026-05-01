import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorite = 'favorite_breed';
  static const _keyFavorites = 'favorite_breeds';
  static const _keyLastSearch = 'last_search_term';

  Future<void> saveFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_keyFavorites) ?? [];
    if (!current.contains(breedName)) {
      current.add(breedName);
      await prefs.setStringList(_keyFavorites, current);
    }
    await prefs.setString(_keyFavorite, breedName);
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
    final currentMain = prefs.getString(_keyFavorite);
    if (currentMain == breedName) {
      if (current.isNotEmpty) {
        await prefs.setString(_keyFavorite, current.last);
      } else {
        await prefs.remove(_keyFavorite);
      }
    }
  }

  Future<String?> loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFavorite);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
    await prefs.remove(_keyFavorite);
  }

  Future<void> saveLastSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, term);
  }

  Future<String?> loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch);
  }
}

