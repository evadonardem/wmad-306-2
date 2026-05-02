import 'package:dio/dio.dart';
import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService() : _dio = _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://akabab.github.io/superhero-api/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          // Retry on timeout or connection errors (max 3 retries)
          if (_shouldRetry(error) && error.requestOptions.extra['retryCount'] == null) {
            error.requestOptions.extra['retryCount'] = 0;
            final retryCount = error.requestOptions.extra['retryCount'] as int;
            
            if (retryCount < 3) {
              error.requestOptions.extra['retryCount'] = retryCount + 1;
              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                // Retry failed, continue to error handler
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.connectionError;
  }

  /// Fetch all heroes from Akabab API.
  Future<List<HeroModel>> fetchAllHeroes() async {
    try {
      final response = await _dio.get('all.json');
      final results = response.data as List<dynamic>? ?? [];
      return results
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch all heroes');
    }
  }

  /// Search heroes by name from local list.
  Future<List<HeroModel>> searchHeroes(String name) async {
    try {
      final response = await _dio.get('all.json');
      final List<dynamic> data = response.data;
      return data
          .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
          .where((h) => h.name.toLowerCase().contains(name.toLowerCase()))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to search heroes');
    }
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    try {
      final allHeroes = await fetchAllHeroes();
      allHeroes.shuffle();
      return allHeroes.take(count).toList();
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch random heroes');
    }
  }

  Exception _handleDioError(DioException error, String message) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('$message: Connection timeout. Check your internet connection.');
      case DioExceptionType.receiveTimeout:
        return Exception('$message: Server response timeout. Please try again.');
      case DioExceptionType.sendTimeout:
        return Exception('$message: Request timeout. Please try again.');
      case DioExceptionType.badResponse:
        return Exception('$message: Server error (${error.response?.statusCode}).');
      case DioExceptionType.cancel:
        return Exception('$message: Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('$message: No internet connection.');
      default:
        return Exception('$message: ${error.message}');
    }
  }
}