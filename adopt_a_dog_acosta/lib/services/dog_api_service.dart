import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breed.dart';

class DogApiService {
  static const _base = 'https://dog.ceo/api';

  Future<List<Breed>> fetchBreeds() async {
    final uri = Uri.parse('$_base/breeds/list/all');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load breeds');
    }

    final data = jsonDecode(response.body);
    final message = data['message'];

    return (message as Map<String, dynamic>).entries
        .map((e) => Breed(
              name: e.key,
              subBreeds: List<String>.from(e.value),
            ))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<String> fetchRandomImage(String breedName) async {
    final uri = Uri.parse('$_base/breed/$breedName/images/random');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final data = jsonDecode(response.body);
    return data['message'];
  }

  // Helper to find full breed data by name for functional lists
  Future<Breed> findBreedByName(String name) async {
    final allBreeds = await fetchBreeds();
    return allBreeds.firstWhere(
      (breed) => breed.name.toLowerCase() == name.toLowerCase(),
      orElse: () => Breed(name: name, subBreeds: []),
    );
  }
}