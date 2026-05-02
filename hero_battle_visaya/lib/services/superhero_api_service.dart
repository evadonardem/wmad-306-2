import 'package:dio/dio.dart';

import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
      : _token = apiToken,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://superheroapi.com/api/',
          connectTimeout: const Duration(seconds: 10),
        ));

  final String _token;
  final Dio _dio;

  Map<String, dynamic> _validatedMap(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw Exception('HTTP error: $status');
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected API response format.');
    }

    if (data['response'] == 'error') {
      throw Exception(data['error']?.toString() ?? 'Superhero API error');
    }

    return data;
  }

  /// Fetch a single hero by numeric ID (1–731).
  Future<HeroModel> fetchHero(int id) async {
    final response = await _dio.get('$_token/$id');
    final data = _validatedMap(response);
    return HeroModel.fromJson(data);
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    final response = await _dio.get('$_token/search/$name');
    final data = _validatedMap(response);
    final results = data['results'] as List<dynamic>? ?? [];
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
}