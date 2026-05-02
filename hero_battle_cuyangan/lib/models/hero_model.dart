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

  // Cast Powerstats: Akabab API returns integers, handle both int and String types
  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v == null) return 50;
      if (v is int) return v;
      if (v is String) {
        if (v == 'null') return 50;
        return int.tryParse(v) ?? 50;
      }
      return 50; // fallback for any other type
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

  // Total power for battle calculations
  int get total =>
      intelligence + strength + speed + durability + power + combat;
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

  bool get hasImage => imageUrl.isNotEmpty;

  String get displayImageUrl {
    // Use direct GitHub-hosted links - no proxy needed for Akabab API
    if (!hasImage) return '';

    return imageUrl;
  }

  // Derived game stats
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack =>
      ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    // Stringify the ID: ensures integer IDs are safely converted to strings
    final id = json['id']?.toString() ?? 'unknown';

    // Check the Image Path: access Akabab image correctly with null safety
    final images = json['images'] as Map<String, dynamic>?;
    final imageUrl =
        images?['lg']?.toString() ??
        images?['md']?.toString() ??
        images?['sm']?.toString() ??
        'https://via.placeholder.com/400x500.png?text=No+URL';

    // Safe Biography Parsing: prevent null-pointer or type errors
    final biography = json['biography'] as Map<String, dynamic>?;
    final publisher = biography?['publisher']?.toString() ?? 'Unknown';
    final alignment = biography?['alignment']?.toString() ?? 'neutral';
    final fullName = biography?['fullName']?.toString() ?? '';

    return HeroModel(
      id: id,
      name: json['name']?.toString() ?? 'Unknown',
      imageUrl: imageUrl,
      powerStats: PowerStats.fromJson(json['powerstats'] ?? {}),
      publisher: publisher,
      alignment: alignment,
      fullName: fullName,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeroModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HeroModel{id: $id, name: $name}';
  }
}
