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

  /// Handles both API format (strings / "null") and saved SQLite format (ints).
  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v == null || v == 'null') return 50;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 50;
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

  // ── Derived game stats ───────────────────────────────────────────────────
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack =>
      ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  /// Handles both the live API format and the flat SQLite-saved format.
  factory HeroModel.fromJson(Map<String, dynamic> json) {
    // imageUrl can come from 'image' → 'url' (API) or 'imageUrl' (saved)
    String imageUrl = '';
    if (json['image'] is Map) {
      imageUrl = (json['image'] as Map)['url'] as String? ?? '';
    } else if (json['imageUrl'] is String) {
      imageUrl = json['imageUrl'] as String;
    }

    // powerStats key is 'powerstats' (API) or 'powerStats' (saved)
    final statsJson = (json['powerstats'] ?? json['powerStats']) as Map?;
    final powerStats =
        PowerStats.fromJson(statsJson?.cast<String, dynamic>() ?? {});

    // biography fields come nested (API) or flat (saved)
    final bio = json['biography'] as Map?;
    String publisher =
        bio?['publisher'] as String? ?? json['publisher'] as String? ?? '';
    String alignment = bio?['alignment'] as String? ??
        json['alignment'] as String? ??
        'neutral';
    String fullName = bio?['full-name'] as String? ??
        json['fullName'] as String? ??
        '';

    return HeroModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: imageUrl,
      powerStats: powerStats,
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
}
