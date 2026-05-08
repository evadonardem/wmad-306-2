import 'package:hive/hive.dart';

part 'pokemon_summary.g.dart';

/// Lightweight Pokémon record cached for the home grid.
@HiveType(typeId: 1)
class PokemonSummary {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String url;

  const PokemonSummary({
    required this.id,
    required this.name,
    required this.url,
  });

  /// Parses an entry from `GET /pokemon?limit=...`.
  /// The id is derived from the trailing path segment of [url].
  factory PokemonSummary.fromListEntry(Map<String, dynamic> json) {
    final url = json['url'] as String;
    final parts = url.split('/').where((s) => s.isNotEmpty).toList();
    final id = int.parse(parts.last);
    return PokemonSummary(id: id, name: json['name'] as String, url: url);
  }
}
