import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
      : _token = apiToken,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://superheroapi.com/api/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final String _token;
  final Dio _dio;

  /// Fetch a single hero by numeric ID (1–731).
  Future<HeroModel> fetchHero(int id) async {
    final response = await _dio.get('$_token/$id');
    return HeroModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    final response = await _dio.get('$_token/search/$name');
    // The API returns {"response":"error"} when nothing matches
    if (response.data['response'] == 'error') return [];
    final results = response.data['results'] as List<dynamic>? ?? [];
    return results
        .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a random selection of heroes.
  /// Individual failures are silently skipped so one bad ID
  /// does not wipe out the entire grid.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 12}) async {
    final ids = List.generate(731, (i) => i + 1)..shuffle();

    // Fetch up to count*2 candidates so we still get ~count results
    // even after filtering out failures.
    final candidates = ids.take(count * 2).map((id) async {
      try {
        return await fetchHero(id);
      } catch (_) {
        return null; // skip bad IDs silently
      }
    });

    final results = await Future.wait(candidates);
    return results.whereType<HeroModel>().take(count).toList();
  }
}