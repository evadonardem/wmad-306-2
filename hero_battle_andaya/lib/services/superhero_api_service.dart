import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api',
          connectTimeout: const Duration(seconds: 10),
        ));

  final Dio _dio;

  /// Fetch a single hero by numeric ID.
  Future<HeroModel> fetchHero(int id) async {
    final response = await _dio.get('/id/$id.json');
    return HeroModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetch all heroes (returns a list of all available heroes).
  Future<List<HeroModel>> fetchAllHeroes() async {
    final response = await _dio.get('/all.json');
    final results = response.data as List<dynamic>? ?? [];
    return results
        .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final allHeroes = await fetchAllHeroes();
    allHeroes.shuffle();
    return allHeroes.take(count).toList();
  }

  /// Search heroes by name (client-side filtering since Acabab API doesn't have search endpoint).
  Future<List<HeroModel>> searchHeroes(String name) async {
    final allHeroes = await fetchAllHeroes();
    return allHeroes
        .where((hero) => hero.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  /// Fetch heroes by publisher.
  Future<List<HeroModel>> fetchHeroesByPublisher(String publisher) async {
    final allHeroes = await fetchAllHeroes();
    return allHeroes
        .where((hero) => hero.publisher.toLowerCase() == publisher.toLowerCase())
        .toList();
  }

  /// Fetch heroes by alignment (good, bad, neutral).
  Future<List<HeroModel>> fetchHeroesByAlignment(String alignment) async {
    final allHeroes = await fetchAllHeroes();
    return allHeroes
        .where((hero) => hero.alignment.toLowerCase() == alignment.toLowerCase())
        .toList();
  }
}