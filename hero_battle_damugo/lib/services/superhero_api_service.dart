import 'package:dio/dio.dart';
import 'dart:math';

import '../models/hero_model.dart';

class SuperheroApiService {
	SuperheroApiService({required String apiToken})
			: _token = apiToken,
				_dio = Dio(
					BaseOptions(
						baseUrl: 'https://superheroapi.com/api/',
						connectTimeout: const Duration(seconds: 10),
						receiveTimeout: const Duration(seconds: 10),
					),
				);

	final String _token;
	final Dio _dio;

	Future<HeroModel> fetchHero(int id) async {
		final response = await _dio.get('$_token/$id');
		final data = response.data as Map<String, dynamic>;
		return HeroModel.fromJson(data);
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

