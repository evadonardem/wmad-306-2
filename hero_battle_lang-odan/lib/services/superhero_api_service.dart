import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  final Dio _dio;
  final String apiToken;

  SuperheroApiService({required this.apiToken}) : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// Fetch all heroes from Akabab API
  Future<List<HeroModel>> fetchAllHeroes() async {
    final url = 'https://akabab.github.io/superhero-api/api/all.json';

    try {
      final response = await _dio.get(url);

      // Fix JSON Parsing: Akabab API returns a List directly, not an object with 'results' key
      final results = response.data as List<dynamic>;

      final heroes = results
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .toList();


      return heroes;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch random heroes from Akabab API
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final allHeroes = await fetchAllHeroes();
    allHeroes.shuffle();
    return allHeroes.take(count).toList();
  }

  /// Search heroes by name in Akabab API
  Future<List<HeroModel>> searchHeroes(String name) async {
    try {
      final allHeroes = await fetchAllHeroes();

      final searchResults = allHeroes
          .where((hero) => hero.name.toLowerCase().contains(name.toLowerCase()))
          .toList();

      return searchResults;
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single hero by ID (for compatibility)
  Future<HeroModel> fetchHero(int id) async {
    final allHeroes = await fetchAllHeroes();

    final hero = allHeroes.firstWhere(
      (h) => h.id == id.toString(),
      orElse: () => throw Exception('Hero with ID $id not found'),
    );

    return hero;
  }
}