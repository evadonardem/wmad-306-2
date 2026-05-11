import 'dart:math';

import 'package:dio/dio.dart';

import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://akabab.github.io/superhero-api/api',
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;
  List<HeroModel>? _cache;

  Future<List<HeroModel>> getAllHeroes() async {
    try {
      final response = await _dio.get<List<dynamic>>('/all.json');
      final data = response.data ?? const [];
      _cache = data
          .whereType<Map>()
          .map((item) => HeroModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return _cache!;
    } on DioException {
      rethrow;
    } catch (error) {
      throw StateError('Unable to parse heroes: $error');
    }
  }

  Future<List<HeroModel>> getRandomHeroes({int count = 12}) async {
    final heroes = List<HeroModel>.from(_cache ?? await getAllHeroes());
    heroes.shuffle(Random());
    return heroes.take(count).toList();
  }

  Future<List<HeroModel>> searchHeroes(String query) async {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return const [];
    final heroes = _cache ?? await getAllHeroes();
    return heroes
        .where((hero) =>
            hero.name.toLowerCase().contains(trimmed) ||
            (hero.fullName?.toLowerCase().contains(trimmed) ?? false))
        .take(30)
        .toList();
  }
}
