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

  int get total =>
      intelligence + strength + speed + durability + power + combat;
}

class HeroModel {
  final String id, name, imageUrl, publisher, alignment, fullName;
  final String groupAffiliation, relatives;
  final PowerStats powerStats;

  const HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerStats,
    required this.publisher,
    required this.alignment,
    required this.fullName,
    required this.groupAffiliation,
    required this.relatives,
  });

  /// Vital calculations based on DUR and STR.
  int get maxHp => (powerStats.durability * 5) + powerStats.strength;
  int get initiative => powerStats.speed;

  /// Tiered cost mechanic: Heroes with higher total stats cost more (1-6 range).
  int get cost {
    final total = powerStats.total;
    if (total >= 600) return 6;
    if (total >= 500) return 5;
    if (total >= 400) return 4;
    if (total >= 300) return 3;
    if (total >= 150) return 2;
    return 1;
  }

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final String idStr = json['id'].toString();

    // Handles schema variations between Akabab and Superhero APIs.
    final bio = json['biography'] is Map ? json['biography'] as Map : json;
    final connections =
        json['connections'] is Map ? json['connections'] as Map : json;
    final powerstatsJson = json['powerstats'] is Map
        ? json['powerstats'] as Map
        : (json['powerStats'] is Map ? json['powerStats'] as Map : {});

    final images = json['images'] as Map?;
    String akababImg = (images?['lg'] ?? '').toString();
    if (akababImg.isEmpty) {
      akababImg =
          'https://cdn.jsdelivr.net/gh/akabab/superhero-api@master/api/images/lg/$idStr.jpg';
    }

    final imageMap = json['image'] as Map?;
    String apiImageUrl =
        (json['imageUrl'] ?? imageMap?['url'] ?? akababImg).toString();

    if (apiImageUrl.startsWith('http://')) {
      apiImageUrl = apiImageUrl.replaceFirst('http://', 'https://');
    }

    return HeroModel(
      id: idStr,
      name: (json['name'] ?? 'Unknown').toString(),
      imageUrl: apiImageUrl,
      powerStats:
          PowerStats.fromJson(Map<String, dynamic>.from(powerstatsJson)),
      publisher:
          (json['publisher'] ?? bio['publisher'] ?? 'Unknown').toString(),
      alignment:
          (json['alignment'] ?? bio['alignment'] ?? 'neutral').toString(),
      fullName: (json['fullName'] ??
              bio['fullName'] ??
              bio['full-name'] ??
              'Unknown')
          .toString(),
      groupAffiliation: (json['groupAffiliation'] ??
              connections['groupAffiliation'] ??
              connections['group-affiliation'] ??
              'None')
          .toString(),
      relatives: (json['relatives'] ?? connections['relatives'] ?? 'Unknown')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'publisher': publisher,
        'alignment': alignment,
        'fullName': fullName,
        'groupAffiliation': groupAffiliation,
        'relatives': relatives,
        'powerStats': powerStats.toJson(),
      };
}
