class PowerStats {
  final int intelligence, strength, speed;
  final int durability, power, combat;
  const PowerStats({
    required this.intelligence, required this.strength,
    required this.speed, required this.durability,
    required this.power, required this.combat,
  });

  // Akabab API returns integers, handle both int and string
  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '50') ?? 50;
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

class HeroModel {
  final String id, name, imageUrl, publisher, alignment, fullName;
  final PowerStats powerStats;

  const HeroModel({
    required this.id, required this.name,
    required this.imageUrl, required this.powerStats,
    required this.publisher, required this.alignment,
    required this.fullName,
  });

  /// Construct reliable image URL using Akabab CDN
  String get reliableImageUrl {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return imageUrl;
      }
      // Handle relative URLs from Akabab
      return 'https://akabab.github.io/superhero-api/api/$imageUrl';
    }
    // Akabab API fallback using id
    return 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/$id.jpg';
  }

  // Derived game stats
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack => ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final biography = json['biography'] as Map<String, dynamic>?;
    final images = json['images'] as Map<String, dynamic>?;
    
    return HeroModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Unknown',
      imageUrl: images?['md']?.toString() ?? '',
      powerStats: PowerStats.fromJson(json['powerstats'] ?? {}),
      publisher: biography?['publisher']?.toString() ?? '',
      alignment: biography?['alignment']?.toString() ?? 'neutral',
      fullName: biography?['fullName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'imageUrl': imageUrl,
    'publisher': publisher, 'alignment': alignment, 'fullName': fullName,
    'powerStats': powerStats.toJson(),
  };
}