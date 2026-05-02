// lib/models/hero_model.dart

class HeroModel {
  final String id;
  final String name;
  final HeroImage image;
  final PowerStats powerStats;
  final HeroBiography biography;
  final String? ability; // Added ability field

  const HeroModel({
    required this.id,
    required this.name,
    required this.image,
    required this.powerStats,
    required this.biography,
    this.ability,
  });

  // Computed properties for battle and display
  int get maxHp => 100 + (powerStats.durability ~/ 2);
  int get attack => powerStats.strength + (powerStats.power ~/ 2);
  int get defense => powerStats.durability + (powerStats.combat ~/ 3);
  int get speed => powerStats.speed;
  int get specialAttack => powerStats.power;
  
  // Helper getters for display
  String get fullName => biography.fullName;
  String get publisher => biography.publisher;
  String get alignment => biography.alignment;
  String get imageUrl => image.url;
  
  // Default ability based on name if not provided
  String get displayAbility => ability ?? _getDefaultAbility();

  String _getDefaultAbility() {
    switch (name.toLowerCase()) {
      case 'aquila':
        return 'Wind Slash';
      case 'blaze':
        return 'Fire Blast';
      case 'titan':
        return 'Earth Shatter';
      default:
        return 'Super Punch';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image.toJson(),
      'powerStats': powerStats.toJson(),
      'biography': biography.toJson(),
      'ability': ability,
    };
  }

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    return HeroModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown',
      image: HeroImage.fromJson(json['image'] ?? {}),
      powerStats: PowerStats.fromJson(json['powerStats'] ?? {}),
      biography: HeroBiography.fromJson(json['biography'] ?? {}),
      ability: json['ability']?.toString(),
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {
      'intelligence': intelligence,
      'strength': strength,
      'speed': speed,
      'durability': durability,
      'power': power,
      'combat': combat,
    };
  }

  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parseStat(dynamic value) {
      if (value == null || value == 'null') return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return PowerStats(
      intelligence: parseStat(json['intelligence']),
      strength: parseStat(json['strength']),
      speed: parseStat(json['speed']),
      durability: parseStat(json['durability']),
      power: parseStat(json['power']),
      combat: parseStat(json['combat']),
    );
  }
}

class HeroImage {
  final String url;
  final String? thumbnailUrl;

  const HeroImage({
    required this.url,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  factory HeroImage.fromJson(Map<String, dynamic> json) {
    return HeroImage(
      url: json['url']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
    );
  }
}

class HeroBiography {
  final String fullName;
  final String publisher;
  final String alignment;

  const HeroBiography({
    required this.fullName,
    required this.publisher,
    required this.alignment,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'publisher': publisher,
      'alignment': alignment,
    };
  }

  factory HeroBiography.fromJson(Map<String, dynamic> json) {
    return HeroBiography(
      fullName: json['fullName']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      alignment: json['alignment']?.toString() ?? 'neutral',
    );
  }
}