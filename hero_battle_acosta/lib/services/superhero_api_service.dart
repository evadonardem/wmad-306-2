import 'package:dio/dio.dart';
import '../models/hero_model.dart';
import 'mock_hero_service.dart';

class SuperheroApiService {
  final String _token = "791decc8c246a81a2c6fefcc01c75bf2";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://superheroapi.com/api/',
      connectTimeout: const Duration(seconds: 10),
    ),
  );

  // 🔹 GET HERO BY ID
  Future<HeroModel> fetchHero(int id) async {
    try {
      final res = await _dio.get('$_token/$id');
      return HeroModel.fromJson(res.data);
    } catch (e) {
      print('API Error fetching hero $id: $e');
      // Fallback to mock data
      return await MockHeroService.getHero(id);
    }
  }

  // 🔹 RANDOM HEROES
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    // For web development, use mock data directly to avoid CORS issues
    return await MockHeroService.getRandomHeroes(count: count);
  }

  // 🔹 SEARCH HEROES (FIXED)
  Future<List<HeroModel>> searchHeroes(String name) async {
    try {
      final res = await _dio.get('$_token/search/$name');

      // API returns "error" if not found
      if (res.data['response'] == 'error') {
        // Fall back to mock search
        return await MockHeroService.searchHeroes(name);
      }

      final results = res.data['results'] as List<dynamic>? ?? [];
      
      // If no results from API, use mock data
      if (results.isEmpty) {
        return await MockHeroService.searchHeroes(name);
      }

      List<HeroModel> heroes = results
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return heroes;
    } catch (e) {
      print('API Error searching heroes: $e');
      // Fallback to mock data
      return await MockHeroService.searchHeroes(name);
    }
  }
}