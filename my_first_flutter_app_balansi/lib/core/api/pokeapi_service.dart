import 'package:dio/dio.dart';

import '../models/pokemon_detail.dart';
import '../models/pokemon_summary.dart';
import 'dio_client.dart';

/// Friendly, typed wrapper around the PokéAPI endpoints we use.
class PokeapiService {
  PokeapiService({Dio? dio}) : _dio = dio ?? DioClient.instance;

  final Dio _dio;

  /// Hard cap so we only ever surface Gen 1–6.
  static const int gen6Cutoff = 721;

  /// Fetches the basic Pokémon list (name + url) up to [limit] entries.
  Future<List<PokemonSummary>> fetchPokemonList({
    int limit = gen6Cutoff,
    int offset = 0,
  }) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>(
        'pokemon',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final results = (resp.data?['results'] as List?) ?? const [];
      return results
          .map((e) => PokemonSummary.fromListEntry(e as Map<String, dynamic>))
          .where((p) => p.id <= gen6Cutoff)
          .toList();
    } on DioException catch (e) {
      throw _humanise(e);
    }
  }

  /// Fetches the full record for a single Pokémon by [id].
  Future<PokemonDetail> fetchPokemonDetail(int id) async {
    try {
      final resp = await _dio.get<Map<String, dynamic>>('pokemon/$id');
      return PokemonDetail.fromJson(resp.data!);
    } on DioException catch (e) {
      throw _humanise(e);
    }
  }

  /// Maps Dio failure modes to short, end-user-friendly messages.
  Exception _humanise(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('The PokéAPI is taking too long to respond.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 404) {
          return Exception('Pokémon not found.');
        }
        return Exception('PokéAPI is unreachable right now.');
      default:
        return Exception('Something went wrong while reaching PokéAPI.');
    }
  }
}
