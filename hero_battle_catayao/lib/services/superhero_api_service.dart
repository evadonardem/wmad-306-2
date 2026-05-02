import 'package:dio/dio.dart';

import '../models/hero_model.dart';

const kApiToken = String.fromEnvironment(
  'SUPERHERO_API_TOKEN',
  defaultValue: '', //Put Token here --Khendev
);

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
    : _apiToken = apiToken,
      _primaryDio = Dio(
        BaseOptions(
          baseUrl: 'https://www.superheroapi.com/api.php/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ),
      _fallbackDio = Dio(
        BaseOptions(
          baseUrl: 'https://akabab.github.io/superhero-api/api/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  final String _apiToken;
  final Dio _primaryDio;
  final Dio _fallbackDio;

  Future<List<HeroModel>>? _fallbackHeroesFuture;
  Map<String, HeroModel>? _fallbackById;

  /// Primary data source: superheroapi.com, as required by the manual.
  /// Fallback: akabab/superhero-api for reliable card images and backup data.
  Future<HeroModel> fetchHero(int id) async {
    try {
      final response = await _primaryDio.get('$_apiToken/$id');
      final data = response.data as Map<String, dynamic>;
      if (data['response'] == 'error') {
        throw Exception(data['error'] ?? 'Unable to fetch hero');
      }
      return _withFallbackImage(HeroModel.fromJson(data));
    } catch (_) {
      return _fetchFallbackHero(id);
    }
  }

  Future<List<HeroModel>> searchHeroes(String name) async {
    final query = name.trim();
    if (query.isEmpty) return [];

    try {
      final response = await _primaryDio.get(
        '$_apiToken/search/${Uri.encodeComponent(query)}',
      );
      final data = response.data as Map<String, dynamic>;
      if (data['response'] == 'error') {
        throw Exception(data['error'] ?? 'Unable to search heroes');
      }
      final results = data['results'] as List<dynamic>? ?? [];
      final heroes = results
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Future.wait(heroes.map(_withFallbackImage));
    } catch (_) {
      return _searchFallbackHeroes(query);
    }
  }

  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final ids = List.generate(731, (i) => i + 1)..shuffle();
    final futures = ids.take(count).map(fetchHero);
    try {
      return await Future.wait(futures);
    } catch (_) {
      final heroes = [...await _loadFallbackHeroes()]..shuffle();
      return heroes.take(count).toList();
    }
  }

  Future<HeroModel> _withFallbackImage(HeroModel hero) async {
    final fallback = await _findFallbackHero(hero);
    final fallbackImage = fallback?.imageUrl.trim() ?? '';
    if (fallbackImage.isEmpty) return hero;
    return hero.copyWith(imageUrl: fallbackImage);
  }

  Future<HeroModel?> _findFallbackHero(HeroModel hero) async {
    final fallbackById = await _loadFallbackHeroMap();
    final idMatch = fallbackById[hero.id];
    if (idMatch != null) return idMatch;

    final lowerName = hero.name.toLowerCase();
    final lowerFullName = hero.fullName.toLowerCase();
    for (final fallback in fallbackById.values) {
      if (fallback.name.toLowerCase() == lowerName ||
          (lowerFullName.isNotEmpty &&
              fallback.fullName.toLowerCase() == lowerFullName)) {
        return fallback;
      }
    }
    return null;
  }

  Future<HeroModel> _fetchFallbackHero(int id) async {
    final response = await _fallbackDio.get('id/$id.json');
    final data = response.data as Map<String, dynamic>;
    return HeroModel.fromJson(data);
  }

  Future<List<HeroModel>> _searchFallbackHeroes(String query) async {
    final lowerQuery = query.toLowerCase();
    final heroes = await _loadFallbackHeroes();
    return heroes
        .where((hero) {
          final nameMatch = hero.name.toLowerCase().contains(lowerQuery);
          final fullNameMatch = hero.fullName.toLowerCase().contains(
            lowerQuery,
          );
          return nameMatch || fullNameMatch;
        })
        .take(30)
        .toList();
  }

  Future<Map<String, HeroModel>> _loadFallbackHeroMap() async {
    if (_fallbackById != null) return _fallbackById!;
    final heroes = await _loadFallbackHeroes();
    _fallbackById = {for (final hero in heroes) hero.id: hero};
    return _fallbackById!;
  }

  Future<List<HeroModel>> _loadFallbackHeroes() {
    _fallbackHeroesFuture ??= _fetchFallbackHeroes();
    return _fallbackHeroesFuture!;
  }

  Future<List<HeroModel>> _fetchFallbackHeroes() async {
    final response = await _fallbackDio.get('all.json');
    final results = response.data as List<dynamic>? ?? [];
    return results
        .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
