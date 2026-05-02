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
      intelligence: parse(json['intelligence'] as String?),
      strength: parse(json['strength'] as String?),
      speed: parse(json['speed'] as String?),
      durability: parse(json['durability'] as String?),
      power: parse(json['power'] as String?),
      combat: parse(json['combat'] as String?),
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

class Biography {
  final String fullName;
  final String alterEgos;
  final List<String> aliases;
  final String placeOfBirth;
  final String firstAppearance;
  final String publisher;
  final String alignment;

  const Biography({
    required this.fullName,
    required this.alterEgos,
    required this.aliases,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.publisher,
    required this.alignment,
  });

  factory Biography.fromJson(Map<String, dynamic> json) {
    return Biography(
      fullName: json['full-name'] as String? ?? '',
      alterEgos: json['alter-egos'] as String? ?? '',
      aliases: List<String>.from(json['aliases'] as List<dynamic>? ?? []),
      placeOfBirth: json['place-of-birth'] as String? ?? '',
      firstAppearance: json['first-appearance'] as String? ?? '',
      publisher: json['publisher'] as String? ?? 'Unknown',
      alignment: json['alignment'] as String? ?? 'neutral',
    );
  }

  Map<String, dynamic> toJson() => {
        'full-name': fullName,
        'alter-egos': alterEgos,
        'aliases': aliases,
        'place-of-birth': placeOfBirth,
        'first-appearance': firstAppearance,
        'publisher': publisher,
        'alignment': alignment,
      };
}

class Appearance {
  final String gender;
  final String race;
  final List<String> height;
  final List<String> weight;
  final String eyeColor;
  final String hairColor;

  const Appearance({
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
  });

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      gender: json['gender'] as String? ?? '',
      race: json['race'] as String? ?? '',
      height: List<String>.from(json['height'] as List<dynamic>? ?? []),
      weight: List<String>.from(json['weight'] as List<dynamic>? ?? []),
      eyeColor: json['eye-color'] as String? ?? '',
      hairColor: json['hair-color'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'gender': gender,
        'race': race,
        'height': height,
        'weight': weight,
        'eye-color': eyeColor,
        'hair-color': hairColor,
      };
}

class WorkInfo {
  final String occupation;
  final String base;

  const WorkInfo({
    required this.occupation,
    required this.base,
  });

  factory WorkInfo.fromJson(Map<String, dynamic> json) {
    return WorkInfo(
      occupation: json['occupation'] as String? ?? '',
      base: json['base'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'occupation': occupation,
        'base': base,
      };
}

class Connections {
  final String groupAffiliation;
  final String relatives;

  const Connections({
    required this.groupAffiliation,
    required this.relatives,
  });

  factory Connections.fromJson(Map<String, dynamic> json) {
    return Connections(
      groupAffiliation: json['group-affiliation'] as String? ?? '',
      relatives: json['relatives'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'group-affiliation': groupAffiliation,
        'relatives': relatives,
      };
}

class HeroModel {
  final String id;
  final String name;
  final String imageUrl;
  final PowerStats powerStats;
  final Biography biography;
  final Appearance appearance;
  final WorkInfo work;
  final Connections connections;

  const HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerStats,
    required this.biography,
    required this.appearance,
    required this.work,
    required this.connections,
  });

  String get description =>
      work.occupation.isNotEmpty ? work.occupation : biography.publisher;

  // Derived game stats
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack =>
      ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  // For compatibility with existing code
  int get totalPower =>
      powerStats.intelligence +
      powerStats.strength +
      powerStats.speed +
      powerStats.durability +
      powerStats.power +
      powerStats.combat;

  // Compatibility getters
  int get intelligence => powerStats.intelligence;
  int get strength => powerStats.strength;
  int get speed => powerStats.speed;
  int get durability => powerStats.durability;
  int get power => powerStats.power;
  int get combat => powerStats.combat;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final biography = Biography.fromJson(
        Map<String, dynamic>.from(json['biography'] as Map? ?? {}));
    final appearance = Appearance.fromJson(
        Map<String, dynamic>.from(json['appearance'] as Map? ?? {}));
    final work = WorkInfo.fromJson(
        Map<String, dynamic>.from(json['work'] as Map? ?? {}));
    final connections = Connections.fromJson(
        Map<String, dynamic>.from(json['connections'] as Map? ?? {}));

    return HeroModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: (json['image'] as Map?)?['url'] as String? ?? '',
      powerStats: PowerStats.fromJson(
          Map<String, dynamic>.from(json['powerstats'] as Map? ?? {})),
      biography: biography,
      appearance: appearance,
      work: work,
      connections: connections,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'powerstats': powerStats.toJson(),
        'biography': biography.toJson(),
        'appearance': appearance.toJson(),
        'work': work.toJson(),
        'connections': connections.toJson(),
      };

  Map<String, dynamic> toMap() {
    return toJson();
  }

  factory HeroModel.fromMap(Map<String, dynamic> map) {
    return HeroModel(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      powerStats: PowerStats.fromJson(
          Map<String, dynamic>.from(map['powerstats'] as Map? ?? {})),
      biography: Biography.fromJson(
          Map<String, dynamic>.from(map['biography'] as Map? ?? {})),
      appearance: Appearance.fromJson(
          Map<String, dynamic>.from(map['appearance'] as Map? ?? {})),
      work: WorkInfo.fromJson(
          Map<String, dynamic>.from(map['work'] as Map? ?? {})),
      connections: Connections.fromJson(
          Map<String, dynamic>.from(map['connections'] as Map? ?? {})),
    );
  }
}
