import 'dart:convert';
import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/services/cache_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DogApiService {
  static const _base = 'https://dog.ceo/api';
  static const _breedListCacheKey = 'breed_list';
  static const _breedListExpiryHours = 6; // Cache breed list for 6 hours

  final _cacheService = CacheService.instance;

  Future<List<Breed>> fetchBreeds() async {
    // Try to get cached breed list first
    final cachedBreeds = await _getCachedBreeds();
    if (cachedBreeds != null) {
      return cachedBreeds;
    }

    // Fetch from API if not cached
    final uri = Uri.parse('$_base/breeds/list/all');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load breeds');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final Map<String, dynamic> message = data['message'];

    final breeds = message.entries
        .map(
          (e) =>
              Breed(name: e.key, subBreeds: List<String>.from(e.value as List)),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Cache the breed list
    await _cacheBreeds(breeds);

    return breeds;
  }

  Future<String> fetchRandomImage(String breedName) async {
    // Try to get cached image first
    final cachedImagePath = await _getCachedImage(breedName);
    if (cachedImagePath != null) {
      return cachedImagePath;
    }

    // Fetch from API if not cached
    final uri = Uri.parse('$_base/breed/$breedName/images/random');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final imageUrl = data['message'] as String;

    // Cache the image
    await _cacheImage(imageUrl);

    return imageUrl;
  }

  Future<void> _cacheBreeds(List<Breed> breeds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_breedListCacheKey, 
        breeds.map((b) => '${b.name}:${b.subBreeds.join(',')}').toList());
      
      // Store timestamp for cache expiry
      await prefs.setInt('${_breedListCacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Ignore cache errors
    }
  }

  Future<List<Breed>?> _getCachedBreeds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getStringList(_breedListCacheKey);
      final timestamp = prefs.getInt('${_breedListCacheKey}_timestamp');
      
      if (cachedData == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final diff = now.difference(cacheTime);
      
      if (diff.inHours > _breedListExpiryHours) {
        return null;
      }

      // Parse cached data back to Breed objects
      return cachedData.map((data) {
        final parts = data.split(':');
        final name = parts[0];
        final subBreeds = parts.length > 1 ? parts[1].split(',').toList() : <String>[];
        return Breed(name: name, subBreeds: subBreeds);
      }).toList();
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getCachedImage(String breedName) async {
    try {
      // For now, we'll use a simple approach - try to get any cached image
      // In a real implementation, we'd need to store which images are cached for which breeds
      return null; // Let's implement proper image caching in the CacheService
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheImage(String imageUrl) async {
    try {
      await _cacheService.cacheImage(imageUrl);
    } catch (e) {
      // Ignore cache errors
    }
  }
}
