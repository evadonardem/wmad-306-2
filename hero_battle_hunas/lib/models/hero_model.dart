import 'dart:convert';

class HeroModel {
  const HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
    this.publisher,
    this.fullName,
  });

  final int id;
  final String name;
  final String imageUrl;
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;
  final String? publisher;
  final String? fullName;

  int get battleScore =>
      intelligence + strength + speed + durability + power + combat;

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final stats = _parseMap(json['powerstats']);
    final biography = _parseMap(json['biography']);
    final images = _parseMap(json['images']);
    final image = json['image'];

    String imageUrl = json['imageUrl']?.toString() ?? '';
    if (image is Map) imageUrl = image['url']?.toString() ?? '';
    if (imageUrl.isEmpty) {
      imageUrl = images['md']?.toString() ??
          images['sm']?.toString() ??
          images['lg']?.toString() ??
          '';
    }

    return HeroModel(
      id: _parseId(json['id']),
      name: json['name']?.toString() ?? 'Unknown Hero',
      imageUrl: imageUrl,
      intelligence: _parseInt(stats['intelligence']),
      strength: _parseInt(stats['strength']),
      speed: _parseInt(stats['speed']),
      durability: _parseInt(stats['durability']),
      power: _parseInt(stats['power']),
      combat: _parseInt(stats['combat']),
      publisher: biography['publisher']?.toString(),
      fullName: biography['fullName']?.toString() ??
          biography['full-name']?.toString(),
    );
  }

  factory HeroModel.fromMap(Map<String, dynamic> map) => HeroModel.fromJson(map);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'powerstats': {
          'intelligence': intelligence,
          'strength': strength,
          'speed': speed,
          'durability': durability,
          'power': power,
          'combat': combat,
        },
        'biography': {
          'publisher': publisher,
          'fullName': fullName,
        },
      };

  Map<String, dynamic> toMap() => toJson();

  static String encodeList(List<HeroModel> heroes) =>
      jsonEncode(heroes.map((hero) => hero.toJson()).toList());

  static List<HeroModel> decodeList(String value) {
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded
        .map((item) => HeroModel.fromJson(_parseMap(item)))
        .toList();
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value.clamp(0, 100).toInt();
    if (value is num) return value.round().clamp(0, 100).toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    return (parsed ?? 0).clamp(0, 100).toInt();
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
