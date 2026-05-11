import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
      : _token = apiToken,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://superheroapi.com/api/',
          connectTimeout: const Duration(seconds: 15),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          },
        ));

  final String _token;
  final Dio _dio;

  /// Fetch a single hero by numeric ID (1-731).
  Future<HeroModel> fetchHero(int id) async {
    final response = await _dio.get('$_token/$id');
    if (response.data['response'] == 'error') {
      throw Exception(response.data['error'] ?? 'API Error');
    }
    return HeroModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    final response = await _dio.get('$_token/search/$name');
    if (response.data['response'] == 'error' &&
        response.data['error'] != 'character with given name not found') {
      throw Exception(response.data['error'] ?? 'API Error');
    }
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final ids = List.generate(731, (i) => i + 1)..shuffle();
    final futures = ids.take(count).map(fetchHero);
    return Future.wait(futures);
  }

  /// Fetch ALL heroes from the static Akabab JSON API.
  Future<List<HeroModel>> fetchAllHeroes() async {
    try {
      final response = await _dio
          .get('https://akabab.github.io/superhero-api/api/all.json');
      final List<dynamic> results = response.data as List<dynamic>;
      return results
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch full hero database: $e');
    }
  }
}
