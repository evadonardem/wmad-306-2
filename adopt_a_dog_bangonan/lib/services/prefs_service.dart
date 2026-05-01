import 'package:shared_preferences/shared_preferences.dart';
import 'package:adopt_a_dog/models/favorite.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';

  Future<void> saveFavorite(Favorite favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    
    // Remove any existing favorite with the same breed and image to avoid duplicates
    favorites.removeWhere((f) => f.breedName == favorite.breedName && f.imageUrl == favorite.imageUrl);
    
    favorites.add(favorite);
    
    // Convert favorites to a list of maps for storage
    final favoritesMapList = favorites.map((f) => f.toMap()).toList();
    await prefs.setStringList(_keyFavorites, favoritesMapList.map((map) => map.toString()).toList());
  }

  Future<List<Favorite>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesStringList = prefs.getStringList(_keyFavorites);
    
    if (favoritesStringList == null || favoritesStringList.isEmpty) {
      return [];
    }
    
    // Convert string representations back to Favorite objects
    return favoritesStringList.map((favoriteString) {
      // Parse the string representation back to a map
      final map = _parseStringToMap(favoriteString);
      return Favorite.fromMap(map);
    }).toList();
  }

  Future<void> removeFavorite(Favorite favorite) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    favorites.removeWhere((f) => f.breedName == favorite.breedName && f.imageUrl == favorite.imageUrl);
    
    // Save updated favorites
    final favoritesMapList = favorites.map((f) => f.toMap()).toList();
    await prefs.setStringList(_keyFavorites, favoritesMapList.map((map) => map.toString()).toList());
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFavorites);
  }

  // Helper method to parse string representation of map back to Map<String, dynamic>
  Map<String, dynamic> _parseStringToMap(String mapString) {
    // Remove the Map() wrapper and split by commas
    final cleanString = mapString.replaceAll('Map(', '').replaceAll(')', '');
    final entries = cleanString.split(', ');
    
    final map = <String, dynamic>{};
    for (final entry in entries) {
      final parts = entry.split(': ');
      if (parts.length == 2) {
        final key = parts[0].replaceAll("'", '');
        final value = parts[1].replaceAll("'", '');
        map[key] = value;
      }
    }
    return map;
  }
}
