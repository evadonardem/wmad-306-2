class PowerStats {
  final int intelligence, strength, speed;
  final int durability, power, combat;

  const PowerStats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  // API returns strings; "null" strings fall back to 50
  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic value) {
      if (value == null || value == 'null') return 50;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 50;
      return 50;
    }

    return PowerStats(
      intelligence: parse(json['intelligence']),
      strength: parse(json['strength']),
      speed: parse(json['speed']),
      durability: parse(json['durability']),
      power: parse(json['power']),
      combat: parse(json['combat']),
    );
  }

  Map<String, dynamic> toJson() => {
    'intelligence': intelligence,
    'strength': strength,
    'speed': speed,
    'durability': durability,
    'power': power,
    'combat': combat,
  };
}

enum HeroRarity { common, rare, epic, legendary }

class HeroModel {
  final String id, name, imageUrl, publisher, alignment, fullName;
  final PowerStats powerStats;

  const HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerStats,
    required this.publisher,
    required this.alignment,
    required this.fullName,
  });

  // Derived game stats
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack =>
      ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  HeroRarity get rarity {
    final score = powerStats.intelligence +
        powerStats.strength +
        powerStats.speed +
        powerStats.durability +
        powerStats.power +
        powerStats.combat;
    if (score >= 260) return HeroRarity.legendary;
    if (score >= 220) return HeroRarity.epic;
    if (score >= 170) return HeroRarity.rare;
    return HeroRarity.common;
  }

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map?;
    final rawImageUrl = images == null
        ? ''
        : (images['lg'] as String?) ?? (images['md'] as String?) ?? '';
    var imageUrl = rawImageUrl.replaceFirst(RegExp(r'^http:'), 'https:');
    if (imageUrl.startsWith('ttps://')) {
      imageUrl = 'h$imageUrl';
    }

    return HeroModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: imageUrl,
      powerStats: PowerStats.fromJson(json['powerstats'] ?? {}),
      publisher: (json['biography'] as Map?)?['publisher'] as String? ?? '',
      alignment:
          (json['biography'] as Map?)?['alignment'] as String? ?? 'neutral',
      fullName: (json['biography'] as Map?)?['fullName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'publisher': publisher,
    'alignment': alignment,
    'fullName': fullName,
    'powerStats': powerStats.toJson(),
  };
}
