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
    int parse(dynamic v) =>
        (v == null || v == 'null') ? 50 : int.tryParse(v.toString()) ?? 50;
    
    // Check if powerstats object is empty or doesn't have values
    if (json.isEmpty) {
      return const PowerStats(
        intelligence: 50,
        strength: 50,
        speed: 50,
        durability: 50,
        power: 50,
        combat: 50,
      );
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
  int get attack =>
      ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack =>
      ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense =>
      ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final name = json['name'] as String? ?? 'Unknown';
    
    // Handle both API response format (nested image.url) and saved deck format (flat imageUrl)
    var imageUrl = json['imageUrl'] as String? ?? 
                   (json['image'] as Map<String, dynamic>?)?['url'] as String? ?? 
                   '';
    
    // If no image URL, construct one from CDN
    if (imageUrl.isEmpty) {
      final nameSlug = name.toLowerCase().replaceAll(' ', '-');
      imageUrl = 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/md/$id-$nameSlug.jpg';
    }
    
    return HeroModel(
      id: id,
      name: name,
      imageUrl: imageUrl,
      powerStats: PowerStats.fromJson((json['powerStats'] ?? json['powerstats'] ?? {}) as Map<String, dynamic>),
      publisher: (json['biography'] as Map<String, dynamic>?)?['publisher'] as String? ?? '',
      alignment: (json['biography'] as Map<String, dynamic>?)?['alignment'] as String? ?? 'neutral',
      fullName: (json['biography'] as Map<String, dynamic>?)?['full-name'] as String? ?? '',
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
