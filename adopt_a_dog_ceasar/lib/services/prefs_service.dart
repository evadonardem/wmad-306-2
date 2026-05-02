import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _keyFavorites = 'favorite_breeds_list';

  Future<List<Map<String, String>>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFavorites);
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      return jsonList.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavorite(String breedName, String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    
    // Avoid duplicates based on breedName
    if (!favorites.any((f) => f['name'] == breedName)) {
      favorites.add({'name': breedName, 'image': imageUrl});
      await prefs.setString(_keyFavorites, jsonEncode(favorites));
    }
  }

  Future<void> removeFavorite(String breedName) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await loadFavorites();
    
    favorites.removeWhere((f) => f['name'] == breedName);
    await prefs.setString(_keyFavorites, jsonEncode(favorites));
  }
}
