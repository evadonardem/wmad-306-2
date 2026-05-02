import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  static const String _baseUrl = 'https://superheroapi.com/api/5e0b738ac29491ed4a6facd7b271f13b/';
  static const String _proxyUrl = 'http://localhost:8080/';
  static const String _accessToken = '5e0b738ac29491ed4a6facd7b271f13b';

  final Dio _dio = Dio();

  String get _apiRoot => kIsWeb ? _proxyUrl : _baseUrl;

  Uri _buildUri(String path) {
    final root = _apiRoot.endsWith('/') ? _apiRoot : '$_apiRoot/';
    return Uri.parse('$root$path');
  }

  Future<List<HeroModel>> searchHeroes(String query) async {
    try {
      final uri = _buildUri('$_accessToken/search/${Uri.encodeComponent(query)}');
      final response = await _dio.getUri(uri, options: Options(responseType: ResponseType.json));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['response'] == 'success') {
          final results = data['results'] as List<dynamic>;
          return results.map((json) => HeroModel.fromJson(json as Map<String, dynamic>)).toList();
        }
        return [];
      }

      throw Exception('Failed to search heroes: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error searching heroes: $e');
    }
  }

  Future<HeroModel> getHeroById(int id) async {
    try {
      final uri = _buildUri('$_accessToken/$id');
      final response = await _dio.getUri(uri, options: Options(responseType: ResponseType.json));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return HeroModel.fromJson(data);
        }
      }

      throw Exception('Failed to get hero: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error getting hero: $e');
    }
  }
}