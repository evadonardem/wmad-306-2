class PowerStats {
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  const PowerStats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic value) {
      if (value == null || value == 'null') return 50;
      return int.tryParse(value.toString()) ?? 50;
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

class HeroModel {
  final String id;
  final String name;
  final String imageUrl;
  final String publisher;
  final String alignment;
  final String fullName;
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

  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack =>
      ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final biography = json['biography'] as Map?;
    final image = json['image'] as Map?;
    final images = json['images'] as Map?;
    final statsJson = json['powerstats'] ?? json['powerStats'] ?? {};
    return HeroModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      imageUrl:
          (images?['lg'] as String?) ??
          (images?['md'] as String?) ??
          (image?['url'] as String?) ??
          json['imageUrl'] as String? ??
          '',
      powerStats: PowerStats.fromJson(
        (statsJson as Map?)?.cast<String, dynamic>() ?? {},
      ),
      publisher:
          (biography?['publisher'] as String?) ??
          json['publisher'] as String? ??
          '',
      alignment:
          (biography?['alignment'] as String?) ??
          json['alignment'] as String? ??
          'neutral',
      fullName:
          (biography?['full-name'] as String?) ??
          (biography?['fullName'] as String?) ??
          json['fullName'] as String? ??
          '',
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

  HeroModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? publisher,
    String? alignment,
    String? fullName,
    PowerStats? powerStats,
  }) {
    return HeroModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      publisher: publisher ?? this.publisher,
      alignment: alignment ?? this.alignment,
      fullName: fullName ?? this.fullName,
      powerStats: powerStats ?? this.powerStats,
    );
  }
}
