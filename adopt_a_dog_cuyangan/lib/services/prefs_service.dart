import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keySearchTerm = 'search_term';

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> addFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    if (!favorites.contains(breedName)) {
      favorites.add(breedName);
      await prefs.setStringList(_keyFavorites, favorites);
    }
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

  Future<String?> loadSearchTerm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySearchTerm);
  }

  Future<void> saveSearchTerm(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearchTerm, searchTerm);
  }
}
