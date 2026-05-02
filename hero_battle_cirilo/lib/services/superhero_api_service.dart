import 'package:dio/dio.dart';
import '../models/hero_model.dart';

const String kApiToken = '3657';
const String _baseUrl = 'https://superheroapi.com/api/';

class SuperheroApiService {
  SuperheroApiService({String? apiToken})
      : _token = apiToken ?? kApiToken,
        _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  final String _token;
  final Dio _dio;

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _dio.get(path);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchApiRoot() async {
    return _get(_token);
  }

  Future<HeroModel> fetchHero(int id) async {
    final data = await _get('$_token/$id');
    return HeroModel.fromJson(data);
  }

  Future<Map<String, dynamic>> fetchPowerstats(int id) async {
    return _get('$_token/$id/powerstats');
  }

  Future<Map<String, dynamic>> fetchBiography(int id) async {
    return _get('$_token/$id/biography');
  }

  Future<Map<String, dynamic>> fetchAppearance(int id) async {
    return _get('$_token/$id/appearance');
  }

  Future<Map<String, dynamic>> fetchWork(int id) async {
    return _get('$_token/$id/work');
  }

  Future<Map<String, dynamic>> fetchConnections(int id) async {
    return _get('$_token/$id/connections');
  }

  Future<Map<String, dynamic>> fetchImage(int id) async {
    return _get('$_token/$id/image');
  }

  Future<List<HeroModel>> searchHeroes(String name) async {
    final data = await _get('$_token/search/$name');
    final results = data['results'] as List<dynamic>?;
    return results == null
        ? []
        : results
            .map((item) => HeroModel.fromJson(item as Map<String, dynamic>))
            .toList();
  }

  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final ids = List.generate(731, (index) => index + 1)..shuffle();
    final heroes = <HeroModel>[];

    for (final id in ids.take(count)) {
      heroes.add(await fetchHero(id));
    }

    return heroes;
  }
}
