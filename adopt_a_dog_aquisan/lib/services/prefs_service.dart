import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _key = 'favorite_breeds';

  Future<void> saveFavorite(String breed) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    if (!favorites.contains(breed)) {
      favorites.add(breed);
      await prefs.setStringList(_key, favorites);
    }
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> removeFavorite(String breed) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_key) ?? [];
    favorites.remove(breed);
    await prefs.setStringList(_key, favorites);
  }

  Future<bool> isFavorite(String breed) async {
    final favorites = await loadFavorites();
    return favorites.contains(breed);
  }
}
