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
      return prefs.getStringList(_keyFavorites) ?? [];
    }
    
    Future<void> removeFavorite(String breedName) async {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await loadFavorites();
      favorites.remove(breedName);
      await prefs.setStringList(_keyFavorites, favorites);
    }
    
    Future<bool> isFavorite(String breedName) async {
      final favorites = await loadFavorites();
      return favorites.contains(breedName);
    }
    
    Future<void> clearAllFavorites() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyFavorites);
    }
    static const _keyLastSearch = 'last_search';

Future<void> saveLastSearch(String query) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyLastSearch, query);
}

Future<String?> loadLastSearch() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyLastSearch);
}
  }