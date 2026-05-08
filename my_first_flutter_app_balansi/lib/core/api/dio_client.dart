import 'package:dio/dio.dart';

/// Shared Dio instance configured for the public PokéAPI.
class DioClient {
  DioClient._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: 'https://pokeapi.co/api/v2/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: {'Accept': 'application/json'},
    ),
  );
}
