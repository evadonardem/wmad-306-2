import 'dart:convert';
import 'package:adopt_a_dog/models/breed.dart';
import 'package:http/http.dart' as http;


class DogApiService {
  static const _base = 'https://dog.ceo/api';

  Future<List<Breed>> fetchBreeds() async {
    final response = await http.get(Uri.parse('$_base/breeds/list/all'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load breeds');
    }

    final data = jsonDecode(response.body);
    final message = data['message'];

    return message.entries.map<Breed>((e) {
      return Breed(
        name: e.key,
        subBreeds: List<String>.from(e.value),
      );
    }).toList();
  }

  Future<String> fetchRandomImage(String breed) async {
    final response = await http.get(
      Uri.parse('$_base/breed/$breed/images/random'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final data = jsonDecode(response.body);
    return data['message'];
  }
}