import 'package:dio/dio.dart';
import 'dart:math';

import '../models/hero_model.dart';

class SuperheroApiService {
	SuperheroApiService({required String apiToken})
			: _token = apiToken,
				_dio = Dio(
					BaseOptions(
						baseUrl: 'https://www.superheroapi.com/api.php/',
						connectTimeout: const Duration(seconds: 10),
						receiveTimeout: const Duration(seconds: 10),
						followRedirects: true,
						validateStatus: (status) => status != null && status < 500,
						headers: {
							'Accept': 'application/json',
						},
					),
				);

	final String _token;
	final Dio _dio;

	Future<Map<String, dynamic>> _fetchJson(String path) async {
		final response = await _dio.get('$_token/$path');
		return response.data as Map<String, dynamic>;
	}

	Future<HeroModel> fetchHero(int id) async {
		final data = await _fetchJson('$id');
		return HeroModel.fromJson(data);
	}

	Future<String> fetchHeroImageUrl(int id) async {
		final data = await _fetchJson('$id/image');
		return data['url'] as String? ?? '';
	}

	Future<Map<String, dynamic>> fetchPowerStats(int id) async {
		return _fetchJson('$id/powerstats');
	}

	Future<Map<String, dynamic>> fetchBiography(int id) async {
		return _fetchJson('$id/biography');
	}

	Future<Map<String, dynamic>> fetchAppearance(int id) async {
		return _fetchJson('$id/appearance');
	}

	Future<Map<String, dynamic>> fetchWork(int id) async {
		return _fetchJson('$id/work');
	}

	Future<Map<String, dynamic>> fetchConnections(int id) async {
		return _fetchJson('$id/connections');
	}

	Future<List<HeroModel>> searchHeroes(String name) async {
		if (name.trim().isEmpty) {
			return <HeroModel>[];
		}

		final query = Uri.encodeComponent(name.trim());
		final response = await _dio.get('$_token/search/$query');
		final data = response.data as Map<String, dynamic>;
		if (data['response'] == 'error') {
			return <HeroModel>[];
		}

		final results = data['results'] as List<dynamic>? ?? <dynamic>[];
		return results
				.map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
				.toList();
	}

	Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
		final ids = List<int>.generate(731, (i) => i + 1)..shuffle();
		final heroes = <HeroModel>[];

		for (final id in ids) {
			try {
				heroes.add(await fetchHero(id));
			} catch (_) {
				// Skip invalid API responses and keep filling the roster.
			}
			if (heroes.length >= count) {
				break;
			}
		}

		return heroes;
	}

	Future<HeroModel> fetchRandomHeroFast({int maxAttempts = 8}) async {
		final rng = Random();
		Object? lastError;

		for (var i = 0; i < maxAttempts; i++) {
			final id = 1 + rng.nextInt(731);
			try {
				return await fetchHero(id);
			} catch (e) {
				lastError = e;
			}
		}

		throw Exception('Failed to load random hero: $lastError');
	}
}

