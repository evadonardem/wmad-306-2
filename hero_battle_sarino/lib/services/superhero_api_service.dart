import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  static const _defaultTokenPlaceholder = 'YOUR_API_TOKEN_HERE';

  SuperheroApiService({required String apiToken})
    : _token = apiToken,
      _dio = Dio(
        BaseOptions(
          baseUrl: 'https://superheroapi.com/api/',
          connectTimeout: const Duration(seconds: 10),
        ),
      );

  final String _token;
  final Dio _dio;

  static final List<HeroModel> _demoHeroes = [
    HeroModel(
      id: '1',
      name: 'Superman',
      imageUrl: HeroModel.cartoonImageUrl('Superman'),
      powerStats: const PowerStats(
        intelligence: 80,
        strength: 100,
        speed: 95,
        durability: 95,
        power: 100,
        combat: 85,
      ),
      publisher: 'DC',
      alignment: 'good',
      fullName: 'Clark Kent',
    ),
    HeroModel(
      id: '2',
      name: 'Batman',
      imageUrl: HeroModel.cartoonImageUrl('Batman'),
      powerStats: const PowerStats(
        intelligence: 95,
        strength: 40,
        speed: 60,
        durability: 50,
        power: 40,
        combat: 100,
      ),
      publisher: 'DC',
      alignment: 'good',
      fullName: 'Bruce Wayne',
    ),
    HeroModel(
      id: '3',
      name: 'Wonder Woman',
      imageUrl: HeroModel.cartoonImageUrl('Wonder Woman'),
      powerStats: const PowerStats(
        intelligence: 85,
        strength: 95,
        speed: 80,
        durability: 90,
        power: 90,
        combat: 90,
      ),
      publisher: 'DC',
      alignment: 'good',
      fullName: 'Diana Prince',
    ),
    HeroModel(
      id: '4',
      name: 'Spider-Man',
      imageUrl: HeroModel.cartoonImageUrl('Spider-Man'),
      powerStats: const PowerStats(
        intelligence: 80,
        strength: 55,
        speed: 85,
        durability: 75,
        power: 70,
        combat: 80,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: 'Peter Parker',
    ),
    HeroModel(
      id: '5',
      name: 'Iron Man',
      imageUrl: HeroModel.cartoonImageUrl('Iron Man'),
      powerStats: const PowerStats(
        intelligence: 90,
        strength: 60,
        speed: 70,
        durability: 70,
        power: 85,
        combat: 75,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: 'Tony Stark',
    ),
    HeroModel(
      id: '6',
      name: 'Hulk',
      imageUrl: HeroModel.cartoonImageUrl('Hulk'),
      powerStats: const PowerStats(
        intelligence: 60,
        strength: 100,
        speed: 65,
        durability: 100,
        power: 95,
        combat: 70,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: 'Bruce Banner',
    ),
    HeroModel(
      id: '7',
      name: 'Flash',
      imageUrl: HeroModel.cartoonImageUrl('Flash'),
      powerStats: const PowerStats(
        intelligence: 75,
        strength: 40,
        speed: 100,
        durability: 60,
        power: 70,
        combat: 65,
      ),
      publisher: 'DC',
      alignment: 'good',
      fullName: 'Barry Allen',
    ),
    HeroModel(
      id: '8',
      name: 'Green Lantern',
      imageUrl: HeroModel.cartoonImageUrl('Green Lantern'),
      powerStats: const PowerStats(
        intelligence: 80,
        strength: 70,
        speed: 75,
        durability: 85,
        power: 90,
        combat: 70,
      ),
      publisher: 'DC',
      alignment: 'good',
      fullName: 'Hal Jordan',
    ),
    HeroModel(
      id: '9',
      name: 'Thor',
      imageUrl: HeroModel.cartoonImageUrl('Thor'),
      powerStats: const PowerStats(
        intelligence: 70,
        strength: 95,
        speed: 75,
        durability: 95,
        power: 100,
        combat: 80,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: 'Thor Odinson',
    ),
    HeroModel(
      id: '10',
      name: 'Captain America',
      imageUrl: HeroModel.cartoonImageUrl('Captain America'),
      powerStats: const PowerStats(
        intelligence: 70,
        strength: 80,
        speed: 70,
        durability: 80,
        power: 75,
        combat: 90,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: 'Steve Rogers',
    ),
    HeroModel(
      id: '11',
      name: 'Black Panther',
      imageUrl: HeroModel.cartoonImageUrl('Black Panther'),
      powerStats: const PowerStats(
        intelligence: 85,
        strength: 85,
        speed: 80,
        durability: 80,
        power: 70,
        combat: 95,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: "T'Challa",
    ),
    HeroModel(
      id: '12',
      name: 'Doctor Strange',
      imageUrl: HeroModel.cartoonImageUrl('Doctor Strange'),
      powerStats: const PowerStats(
        intelligence: 95,
        strength: 60,
        speed: 60,
        durability: 85,
        power: 100,
        combat: 85,
      ),
      publisher: 'Marvel',
      alignment: 'good',
      fullName: 'Stephen Strange',
    ),
  ];

  /// Fetch a single hero by numeric ID (1–731).
  Future<HeroModel> fetchHero(int id) async {
    final response = await _dio.get('$_token/$id');
    return HeroModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    if (_token == _defaultTokenPlaceholder) {
      return _demoHeroes
          .where((hero) => hero.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }

    try {
      final response = await _dio.get('$_token/search/$name');
      final results = response.data['results'] as List<dynamic>? ?? [];
      return results
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _demoHeroes
          .where((hero) => hero.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    }
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    if (_token == _defaultTokenPlaceholder) {
      return _demoHeroes;
    }

    try {
      final ids = List.generate(731, (i) => i + 1)..shuffle();
      final futures = ids.take(count).map(fetchHero);
      return Future.wait(futures);
    } catch (_) {
      return _demoHeroes.take(count).toList();
    }
  }
}
