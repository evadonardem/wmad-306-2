import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://akabab.github.io/superhero-api/api/',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          responseType: ResponseType.json,
        ),
      );

  final Dio _dio;

  Future<Response> _get(String path) async {
    return await _dio.get(path);
  }

  Future<HeroModel> fetchHero(int id) async {
    final response = await _get('id/$id.json');
    return HeroModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<HeroModel>> searchHeroes(String name) async {
    final trimmed = name.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return [];
    }

    final maybeId = int.tryParse(trimmed);
    if (maybeId != null) {
      try {
        return [await fetchHero(maybeId)];
      } catch (_) {
        // fall back to text search if the id is not valid
      }
    }

    final response = await _get('all.json');
    final heroes = response.data as List<dynamic>? ?? [];
    final tokens = trimmed
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();

    final results = heroes
        .where((dynamic item) {
          final hero = item as Map<String, dynamic>;
          final heroName = (hero['name'] as String? ?? '').toLowerCase();
          final fullName =
              ((hero['biography'] as Map?)?['fullName'] as String? ?? '')
                  .toLowerCase();
          final aliases = ((hero['biography'] as Map?)?['aliases'] as List?)
              ?.map((alias) => alias.toString().toLowerCase())
              .toList();

          bool matchesToken(String token) {
            return heroName.contains(token) ||
                fullName.contains(token) ||
                (aliases?.any((alias) => alias.contains(token)) ?? false);
          }

          return tokens.every(matchesToken);
        })
        .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return results;
  }

  Future<List<HeroModel>> fetchRandomHeroes({int count = 12}) async {
    final ids = List.generate(731, (i) => i + 1)..shuffle();
    final futures = ids.take(count).map((id) async {
      try {
        return await fetchHero(id);
      } catch (_) {
        return null;
      }
    });
    final heroes = await Future.wait(futures);
    return heroes.whereType<HeroModel>().toList();
  }
}
