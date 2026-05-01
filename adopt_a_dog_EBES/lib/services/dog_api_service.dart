import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breed.dart';

class DogApiService {
  static const _base = 'https://dog.ceo/api';

  Future<List<Breed>> fetchBreeds() async {
    final uri = Uri.parse('$_base/breeds/list/all');
    final response = await http.get(uri);

    // FIX 1: was response.statuscode (lowercase c) — undefined getter, compile error
    if (response.statusCode != 200) {
      throw Exception('Failed to load breeds');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final Map<String, dynamic> message = data['message'];

    return message.entries
        .map((e) => Breed(
              name: e.key,
              subBreeds: List<String>.from(e.value as List),
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // FIX 2: added optional {String? subBreed} parameter.
  // breed_detail_screen.dart calls fetchRandomImage(name, subBreed: sub),
  // which caused an "undefined named parameter 'subBreed'" compile error.
  Future<String> fetchRandomImage(String breedName, {String? subBreed}) async {
    final path = subBreed != null
        ? '$_base/breed/$breedName/$subBreed/images/random'
        : '$_base/breed/$breedName/images/random';

    final uri = Uri.parse(path);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return data['message'] as String;
  }
}