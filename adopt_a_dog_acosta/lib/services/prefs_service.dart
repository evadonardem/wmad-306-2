import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds';
  static const _keyAdopted = 'adopted_breeds'; // New key
  static const _keySearch = 'search_term';

  Future<void> saveFavorites(List<String> breeds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, breeds);
  }

  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  // New methods for Adopted Dogs
  Future<void> saveAdopted(List<String> breeds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyAdopted, breeds);
  }

  Future<List<String>> loadAdopted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyAdopted) ?? [];
  }

  Future<void> saveSearch(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearch, value);
  }

  Future<String> loadSearch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySearch) ?? '';
  }
}