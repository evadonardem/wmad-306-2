import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/breed.dart';

class DogApiService {
  static const _base = 'https://dog.ceo/api';
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
          },
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected server response');
    }

    return decoded;
  }

  Future<List<Breed>> fetchBreeds() async {
    final uri = Uri.parse('$_base/breeds/list/all');
    final data = await _getJson(uri);
    final message = data['message'];
    if (message is! Map<String, dynamic>) {
      throw Exception('Failed to load breeds');
    }

    return message.entries
        .map(
          (entry) => Breed(
            name: entry.key,
            subBreeds: List<String>.from(entry.value as List),
          ),
        )
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<String> fetchRandomImage({
    required String breed,
    String? subBreed,
  }) async {
    final path = subBreed == null
        ? '$breed/images/random'
        : '$breed/$subBreed/images/random';
    final uri = Uri.parse('$_base/breed/$path');
    final data = await _getJson(uri);
    final message = data['message'];
    if (message is! String || message.isEmpty) {
      throw Exception('Failed to load image');
    }

    return message;
  }
}
