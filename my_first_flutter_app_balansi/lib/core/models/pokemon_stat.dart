/// A single base stat for a Pokémon (e.g. hp = 45, attack = 49).
class PokemonStat {
  final String name;
  final int baseValue;

  const PokemonStat({required this.name, required this.baseValue});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      name: (json['stat']?['name'] ?? '') as String,
      baseValue: (json['base_stat'] ?? 0) as int,
    );
  }

  /// Display label, e.g. `special-attack` → `Sp. Atk`.
  String get displayLabel {
    switch (name) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Atk';
      case 'special-defense':
        return 'Sp. Def';
      case 'speed':
        return 'Speed';
      default:
        return name;
    }
  }
}
