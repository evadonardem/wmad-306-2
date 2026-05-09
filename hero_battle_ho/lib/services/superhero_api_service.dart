import 'package:dio/dio.dart';

import '../models/hero_model.dart';

class SuperheroApiService {
  SuperheroApiService({required String apiToken})
      : _token = apiToken,
        _dio = Dio(BaseOptions(
          baseUrl: 'https://superheroapi.com/api/',
          connectTimeout: const Duration(seconds: 10),
        )),
        _fallbackDio = Dio(BaseOptions(
          baseUrl: 'https://akabab.github.io/superhero-api/api/',
          connectTimeout: const Duration(seconds: 10),
        )),
        _probeDio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null && status < 500,
        ));

  final String _token;
  final Dio _dio;
  final Dio _fallbackDio;
  final Dio _probeDio;
  final Map<String, String> _fallbackImageCache = {};
  static Future<Map<String, String>>? _imageIndexFuture;

  Map<String, dynamic> _validatedMap(Response<dynamic> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw Exception('HTTP error: $status');
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected API response format.');
    }

    if (data['response'] == 'error') {
      throw Exception(data['error']?.toString() ?? 'Superhero API error');
    }

    return data;
  }

  String _slugify(String value) {
    final lower = value.toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _buildCdnImageUrl({required String id, required String name, String size = 'lg'}) {
    final slug = _slugify(name);
    if (id.isEmpty || slug.isEmpty) return '';
    return 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/$size/$id-$slug.jpg';
  }

  String _buildAvatarFallbackUrl(String name) {
    final safeName = Uri.encodeQueryComponent(name.isEmpty ? 'Hero' : name);
    return 'https://ui-avatars.com/api/?name=$safeName&background=1f1b2e&color=ffffff&size=512&bold=true';
  }

  Future<bool> _isImageReachable(String url) async {
    if (url.isEmpty) return false;
    try {
      final response = await _probeDio.get<dynamic>(
        url,
        options: Options(headers: const {'Range': 'bytes=0-0'}),
      );
      final status = response.statusCode ?? 0;
      return status >= 200 && status < 300;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, String>> _loadImageIndex() {
    _imageIndexFuture ??= () async {
      final response = await _fallbackDio.get('all.json');
      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        return <String, String>{};
      }

      final data = response.data;
      if (data is! List<dynamic>) {
        return <String, String>{};
      }

      final map = <String, String>{};
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final id = item['id']?.toString() ?? '';
        final image = (item['images'] as Map?)?['lg'] as String? ?? '';
        if (id.isNotEmpty && image.isNotEmpty) {
          map[id] = image;
        }
      }
      return map;
    }();

    return _imageIndexFuture!;
  }

  Future<String> _resolveImageUrl(Map<String, dynamic> heroJson) async {
    final id = heroJson['id']?.toString() ?? '';
    final name = heroJson['name']?.toString() ?? '';
    final primaryImage = (heroJson['image'] as Map?)?['url'] as String? ?? '';
    if (id.isEmpty) return primaryImage;

    final cached = _fallbackImageCache[id];
    if (cached != null && cached.isNotEmpty) return cached;

    final deterministicFallback = _buildCdnImageUrl(id: id, name: name, size: 'lg');

    // If the API image is not from SuperheroDB and is already valid, keep it.
    if (!primaryImage.contains('superherodb.com') && primaryImage.isNotEmpty) {
      return primaryImage;
    }

    // Best fallback source: pre-indexed Akabab image map (stable per hero ID).
    try {
      final index = await _loadImageIndex();
      final indexed = index[id];
      if (indexed != null && indexed.isNotEmpty) {
        _fallbackImageCache[id] = indexed;
        return indexed;
      }
    } catch (_) {
      // Continue with other fallback strategies.
    }

    // SuperheroDB image links may return 403 hotlink protection on some targets.
    // Fallback to jsDelivr image URL from Akabab's superhero dataset.
    try {
      final response = await _fallbackDio.get('id/$id.json');
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final fallback = (data['images'] as Map?)?['lg'] as String?;
        if (fallback != null && fallback.isNotEmpty) {
          _fallbackImageCache[id] = fallback;
          return fallback;
        }
      }
    } catch (_) {
      // Keep primary image URL when fallback lookup fails.
    }

    if (deterministicFallback.isNotEmpty && await _isImageReachable(deterministicFallback)) {
      _fallbackImageCache[id] = deterministicFallback;
      return deterministicFallback;
    }

    // Final safety net: always return a renderable image URL.
    final avatarFallback = _buildAvatarFallbackUrl(name);
    _fallbackImageCache[id] = avatarFallback;
    return avatarFallback;
  }

  /// Fetch a single hero by numeric ID (1–731).
  Future<HeroModel> fetchHero(int id) async {
    final response = await _dio.get('$_token/$id');
    final data = _validatedMap(response);
    final imageUrl = await _resolveImageUrl(data);
    return HeroModel.fromJson({
      ...data,
      'image': {
        ...((data['image'] as Map?)?.cast<String, dynamic>() ?? {}),
        'url': imageUrl,
      },
    });
  }

  /// Search heroes by name.
  Future<List<HeroModel>> searchHeroes(String name) async {
    final response = await _dio.get('$_token/search/$name');
    final data = _validatedMap(response);
    final results = data['results'] as List<dynamic>? ?? [];

    final mapped = await Future.wait(
      results.map((e) async {
        final hero = e as Map<String, dynamic>;
        final imageUrl = await _resolveImageUrl(hero);
        return HeroModel.fromJson({
          ...hero,
          'image': {
            ...((hero['image'] as Map?)?.cast<String, dynamic>() ?? {}),
            'url': imageUrl,
          },
        });
      }),
    );
    return mapped;
  }

  /// Fetch a random selection of heroes.
  Future<List<HeroModel>> fetchRandomHeroes({int count = 20}) async {
    final ids = List.generate(731, (i) => i + 1)..shuffle();
    final futures = ids.take(count).map(fetchHero);
    return Future.wait(futures);
  }
}