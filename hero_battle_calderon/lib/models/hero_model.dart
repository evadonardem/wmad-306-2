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
  final String id, name, imageUrl, akababImageUrl;
  final String publisher, alignment, fullName, placeOfBirth, firstAppearance;
  final List<String> aliases;
  final String gender, race, height, weight, eyeColor, hairColor;
  final String groupAffiliation;
  final PowerStats powerStats;

  const HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.akababImageUrl,
    required this.powerStats,
    required this.publisher,
    required this.alignment,
    required this.fullName,
    required this.placeOfBirth,
    required this.firstAppearance,
    required this.aliases,
    required this.gender,
    required this.race,
    required this.height,
    required this.weight,
    required this.eyeColor,
    required this.hairColor,
    required this.groupAffiliation,
  });

  // Game Stats
  int get maxHp => ((powerStats.durability + powerStats.power) / 2).round();
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack => ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();
  int get initiative => powerStats.speed;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final String idStr = json['id'].toString();
    
    // Akabab API and Superhero API have different structures
    final bio = json['biography'] is Map ? json['biography'] as Map : json;
    final appearance = json['appearance'] is Map ? json['appearance'] as Map : json;
    final connections = json['connections'] is Map ? json['connections'] as Map : json;
    final powerstatsJson = json['powerstats'] is Map ? json['powerstats'] as Map : 
                          (json['powerStats'] is Map ? json['powerStats'] as Map : {});

    // Akabab API nested images
    final images = json['images'] as Map?;
    String akababImg = (images?['lg'] ?? '').toString();
    if (akababImg.isEmpty) {
      akababImg = 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@master/api/images/lg/$idStr.jpg';
    }

    final imageMap = json['image'] as Map?;
    String apiImageUrl = (json['imageUrl'] ?? imageMap?['url'] ?? akababImg).toString();
    
    if (apiImageUrl.startsWith('http://')) {
      apiImageUrl = apiImageUrl.replaceFirst('http://', 'https://');
    }

    final dynamic rawAliases = json['aliases'] ?? bio['aliases'];
    final List<String> aliasesList = rawAliases is List 
        ? List<String>.from(rawAliases.map((e) => e.toString())) 
        : [];

    return HeroModel(
      id: idStr,
      name: (json['name'] ?? 'Unknown').toString(),
      imageUrl: apiImageUrl,
      akababImageUrl: akababImg,
      powerStats: PowerStats.fromJson(Map<String, dynamic>.from(powerstatsJson)),
      publisher: (json['publisher'] ?? bio['publisher'] ?? 'Unknown').toString(),
      alignment: (json['alignment'] ?? bio['alignment'] ?? 'neutral').toString(),
      fullName: (json['fullName'] ?? bio['fullName'] ?? bio['full-name'] ?? 'Unknown').toString(),
      placeOfBirth: (json['placeOfBirth'] ?? bio['placeOfBirth'] ?? bio['place-of-birth'] ?? 'Unknown').toString(),
      firstAppearance: (json['firstAppearance'] ?? bio['firstAppearance'] ?? bio['first-appearance'] ?? 'Unknown').toString(),
      aliases: aliasesList,
      gender: (json['gender'] ?? appearance['gender'] ?? 'Unknown').toString(),
      race: (json['race'] ?? appearance['race'] ?? 'Unknown').toString(),
      height: (json['height'] ?? (appearance['height'] is List ? (appearance['height'] as List).first : 'Unknown')).toString(),
      weight: (json['weight'] ?? (appearance['weight'] is List ? (appearance['weight'] as List).first : 'Unknown')).toString(),
      eyeColor: (json['eyeColor'] ?? appearance['eyeColor'] ?? appearance['eye-color'] ?? 'Unknown').toString(),
      hairColor: (json['hairColor'] ?? appearance['hairColor'] ?? appearance['hair-color'] ?? 'Unknown').toString(),
      groupAffiliation: (json['groupAffiliation'] ?? connections['groupAffiliation'] ?? connections['group-affiliation'] ?? 'None').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'akababImageUrl': akababImageUrl,
    'powerStats': powerStats.toJson(),
    'publisher': publisher,
    'alignment': alignment,
    'fullName': fullName,
    'placeOfBirth': placeOfBirth,
    'firstAppearance': firstAppearance,
    'aliases': aliases,
    'gender': gender,
    'race': race,
    'height': height,
    'weight': weight,
    'eyeColor': eyeColor,
    'hairColor': hairColor,
    'groupAffiliation': groupAffiliation,
  };
}
