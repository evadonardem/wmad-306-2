import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';

  Future<void> saveFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    if (!favorites.contains(breedName)) {
      favorites.add(breedName);
      await prefs.setStringList(_keyFavorites, favorites);
    }
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites);
    return favorites ?? [];
  }

  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    favorites.remove(breedName);
    await prefs.setStringList(_keyFavorites, favorites);
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
  }

  Future<void> saveSearchTerm(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('search_term', searchTerm);
  }

  Future<String?> loadSearchTerm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('search_term');
  }
}
