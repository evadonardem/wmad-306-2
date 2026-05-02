import 'dart:math';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: apiToken.isEmpty
                ? null
                : <String, dynamic>{'Authorization': 'Bearer $apiToken'},
          ),
        );

  static const String _charactersUrl =
      'https://raw.githubusercontent.com/akabab/superhero-api/master/api/all.json';

  final Dio _dio;
  List<HeroModel>? _cachedHeroes;

  Future<List<HeroModel>> _loadHeroes() async {
    if (_cachedHeroes != null) {
      return _cachedHeroes!;
    }

    final response = await _dio.get<String>(_charactersUrl);
    final decoded = jsonDecode(response.data ?? '[]');
    final rawHeroes = decoded is List ? decoded : <dynamic>[];

    final heroes = rawHeroes
        .whereType<Map>()
        .map((hero) => _mapApiHeroToModel(Map<String, dynamic>.from(hero)))
        .toList(growable: false);

    _cachedHeroes = heroes;
    return heroes;
  }

  HeroModel _mapApiHeroToModel(Map<String, dynamic> json) {
    Map<String, dynamic> normalizePowerstats(dynamic value) {
      final stats = value is Map ? value : const <String, dynamic>{};

      int parseInt(dynamic input) {
        if (input is int) {
          return input;
        }
        if (input is String) {
          return int.tryParse(input) ?? 0;
        }
        return 0;
      }

      return <String, dynamic>{
        'intelligence': parseInt(stats['intelligence']).toString(),
        'strength': parseInt(stats['strength']).toString(),
        'speed': parseInt(stats['speed']).toString(),
        'durability': parseInt(stats['durability']).toString(),
        'power': parseInt(stats['power']).toString(),
        'combat': parseInt(stats['combat']).toString(),
      };
    }

    return HeroModel.fromJson(<String, dynamic>{
      'id': json['id'],
      'name': json['name'],
      'image': json['images'] is Map
          ? <String, dynamic>{'url': (json['images'] as Map)['md'] ?? ''}
          : <String, dynamic>{'url': ''},
      // Fixed key to match HeroModel.fromJson expectation
      'powerStats': normalizePowerstats(json['powerstats']),
      'biography': <String, dynamic>{
        'publisher': (json['biography'] as Map?)?['publisher'] ?? '',
        'alignment': (json['biography'] as Map?)?['alignment'] ?? 'neutral',
        'fullName': (json['biography'] as Map?)?['fullName'] ?? '',
      },
    });
  }

  /// Fetch a single hero by numeric ID.
  Future<HeroModel> fetchHero(int id) async {
    final heroes = await _loadHeroes();
    return heroes.firstWhere(
      (hero) => int.tryParse(hero.id) == id,
      orElse: () => throw Exception('Hero with id $id not found.'),
    );
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    final heroes = await _loadHeroes();
    final query = name.trim().toLowerCase();

    if (query.isEmpty) {
      return heroes;
    }

    return heroes
        .where((hero) => hero.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final heroes = List<HeroModel>.from(await _loadHeroes());
    heroes.shuffle(Random());

    final safeCount = count.clamp(0, heroes.length);
    return heroes.take(safeCount).toList(growable: false);
  }
}
