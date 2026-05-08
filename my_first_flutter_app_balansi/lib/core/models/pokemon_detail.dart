import 'pokemon_stat.dart';

/// Full Pokémon record fetched on-demand for the detail screen.
class PokemonDetail {
  final int id;
  final String name;
  final List<String> types;
  final List<String> abilities;
  /// Height in decimetres as returned by PokéAPI.
  final int heightDm;
  /// Weight in hectograms as returned by PokéAPI.
  final int weightHg;
  final List<PokemonStat> stats;
  final String? artworkUrl;
  final String? spriteUrl;

  const PokemonDetail({
    required this.id,
    required this.name,
    required this.types,
    required this.abilities,
    required this.heightDm,
    required this.weightHg,
    required this.stats,
    required this.artworkUrl,
    required this.spriteUrl,
  });

  /// Height in metres for display.
  double get heightMeters => heightDm / 10.0;

  /// Weight in kilograms for display.
  double get weightKg => weightHg / 10.0;

  /// Primary type drives the accent color throughout the UI.
  String get primaryType => types.isEmpty ? 'normal' : types.first;

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final typesJson = (json['types'] as List?) ?? const [];
    final abilitiesJson = (json['abilities'] as List?) ?? const [];
    final statsJson = (json['stats'] as List?) ?? const [];
    final sprites = (json['sprites'] as Map?) ?? const {};
    final other = (sprites['other'] as Map?) ?? const {};
    final officialArt = (other['official-artwork'] as Map?) ?? const {};

    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      types: typesJson
          .map((t) => (t['type']?['name'] ?? '') as String)
          .where((s) => s.isNotEmpty)
          .toList(),
      abilities: abilitiesJson
          .map((a) => (a['ability']?['name'] ?? '') as String)
          .where((s) => s.isNotEmpty)
          .toList(),
      heightDm: (json['height'] ?? 0) as int,
      weightHg: (json['weight'] ?? 0) as int,
      stats: statsJson
          .map((s) => PokemonStat.fromJson(s as Map<String, dynamic>))
          .toList(),
      artworkUrl: officialArt['front_default'] as String?,
      spriteUrl: sprites['front_default'] as String?,
    );
  }
}
