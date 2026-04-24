import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyLastSearch = 'last_search_term';
  static const _keyDrawerOpen = 'drawer_open_state';

  /// Saves [breedName] and [imageUrl] as a user's favorite.
  Future<void> saveFavorite(String breedName, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];

    // Check if already favorited (by breed name)
    final exists = favorites.any((f) => f.split('|')[0] == breedName);
    if (!exists) {
      favorites.add('$breedName|$imageUrl');
      await prefs.setStringList(_keyFavorites, favorites);
    }
    // Also add to gallery
    await addImageToGallery(breedName, imageUrl);
  }

  /// Adds an image to a breed's gallery.
  Future<void> addImageToGallery(String breedName, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'gallery_$breedName';
    final gallery = prefs.getStringList(key) ?? [];
    if (!gallery.contains(imageUrl)) {
      gallery.add(imageUrl);
      await prefs.setStringList(key, gallery);
    }
  }

  /// Loads the gallery for a breed.
  Future<List<String>> loadGallery(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('gallery_$breedName') ?? [];
  }

  /// Checks if [breedName] is in favorites.
  Future<bool> isFavorited(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    return favorites.any((f) => f.split('|')[0] == breedName);
  }

  /// Returns the saved favorites.
  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  /// Removes the favorite entry associated with [breedName].
  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    favorites.removeWhere((f) => f.split('|')[0] == breedName);
    await prefs.setStringList(_keyFavorites, favorites);
    // Clear gallery when removed from favorites
    await clearGallery(breedName);
  }

  /// Sets a specific image as the thumbnail for the favorite list.
  Future<void> setThumbnail(String breedName, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    for (int i = 0; i < favorites.length; i++) {
      if (favorites[i].startsWith('$breedName|')) {
        favorites[i] = '$breedName|$imageUrl';
        break;
      }
    }
    await prefs.setStringList(_keyFavorites, favorites);
  }

  /// Removes a single image from a gallery.
  Future<void> removeImageFromGallery(String breedName, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'gallery_$breedName';
    final gallery = prefs.getStringList(key) ?? [];
    gallery.remove(imageUrl);
    await prefs.setStringList(key, gallery);
  }

  /// Clears the entire gallery for a breed.
  Future<void> clearGallery(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gallery_$breedName');
  }

  /// Saves the last search term.
  Future<void> saveLastSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearch, term);
  }

  /// Returns the last saved search term.
  Future<String> loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearch) ?? '';
  }

  /// Saves the drawer state.
  Future<void> saveDrawerState(bool isOpen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDrawerOpen, isOpen);
  }

  /// Loads the drawer state.
  Future<bool> loadDrawerState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDrawerOpen) ?? false;
  }
}
