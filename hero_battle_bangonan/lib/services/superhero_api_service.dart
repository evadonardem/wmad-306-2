import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
      : _token = apiToken,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://superheroapi.com/api/',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ));
  final String _token;
  final Dio _dio;

  /// Fetch a single hero by numeric ID (1–731).
  Future<HeroModel> fetchHero(int id) async {
    try {
      final response = await _dio.get('$_token/$id');
      if (response.statusCode == 200) {
        return HeroModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to fetch hero: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching hero: $e');
    }
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    try {
      if (name.trim().isEmpty) {
        throw Exception('Search query cannot be empty');
      }
      
      final response = await _dio.get('$_token/search/${name.trim()}');
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Check if we got an error response from the API
        if (responseData is Map && responseData['response'] == 'error') {
          throw Exception('No heroes found matching "$name"');
        }
        
        final results = (responseData['results'] ?? []) as List<dynamic>;
        if (results.isEmpty) {
          throw Exception('No heroes found matching "$name"');
        }
        
        return results
            .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Search failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error during search: ${e.message}');
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    try {
      final ids = List.generate(731, (i) => i + 1)..shuffle();
      final futures = ids.take(count).map(fetchHero);
      return Future.wait(futures);
    } catch (e) {
      throw Exception('Error fetching random heroes: $e');
    }
  }
}
