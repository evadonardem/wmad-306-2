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
    int parse(String? v) => (v == null || v == 'null') ? 50 : int.tryParse(v) ?? 50;
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
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerStats,
    required this.publisher,
    required this.alignment,
    required this.fullName,
  });

  static String cartoonImageUrl(String heroName) {
    final encodedName = Uri.encodeComponent(heroName.toLowerCase().replaceAll(' ', '-'));
    return 'https://api.dicebear.com/6.x/adventurer/png?seed=$encodedName&backgroundColor=262626';
  }

  // Derived game stats
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack => ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? 'Unknown';
    final imageUrl = (json['image'] as Map?)?['url'] as String?;
    return HeroModel(
      id: json['id'].toString(),
      name: name,
      imageUrl: imageUrl != null && imageUrl.isNotEmpty
          ? imageUrl
          : HeroModel.cartoonImageUrl(name),
      powerStats: PowerStats.fromJson(json['powerstats'] ?? {}),
      publisher: (json['biography'] as Map?)?['publisher'] as String? ?? '',
      alignment: (json['biography'] as Map?)?['alignment'] as String? ?? 'neutral',
      fullName: (json['biography'] as Map?)?['full-name'] as String? ?? '',
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