import 'package:dio/dio.dart';
import 'dart:math';
import '../models/hero_model.dart';

class SuperheroApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: 'https://akabab.github.io/superhero-api/api/',
    connectTimeout: const Duration(seconds: 10),
  ));

  List<HeroModel>? _allHeroes;

  Future<List<HeroModel>> _fetchAllHeroes() async {
    if (_allHeroes != null) return _allHeroes!;
    final response = await dio.get('all.json');
    final data = response.data as List<dynamic>;
    _allHeroes = data.map((e) => HeroModel.fromJson(e as Map<String, dynamic>)).toList();
    return _allHeroes!;
  }

  Future<HeroModel?> fetchHero(int id) async {
    final heroes = await _fetchAllHeroes();
    return heroes.where((h) => int.tryParse(h.id) == id).firstOrNull;
  }

  Future<List<HeroModel>> fetchRandomHeroes([int count = 6]) async {
    final heroes = await _fetchAllHeroes();
    final random = Random();
    final selected = <HeroModel>[];
    final used = <int>{};
    while (selected.length < count && used.length < heroes.length) {
      final index = random.nextInt(heroes.length);
      if (!used.contains(index)) {
        used.add(index);
        selected.add(heroes[index]);
      }
    }
    return selected;
  }

  Future<List<HeroModel>> searchHeroes(String name) async {
    final heroes = await _fetchAllHeroes();
    return heroes.where((h) => h.name.toLowerCase().contains(name.toLowerCase())).toList();
  }
}