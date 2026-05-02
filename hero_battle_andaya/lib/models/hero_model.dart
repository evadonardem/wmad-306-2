class PowerStats {
  final int intelligence, strength, speed;
  final int durability, power, combat;
  
  const PowerStats({
    required this.intelligence, required this.strength,
    required this.speed, required this.durability,
    required this.power, required this.combat,
  });

  // Acabab API returns integers directly; missing values fall back to 50
  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic v) {
      if (v == null) return 50;
      if (v is int) return v;
      if (v is String) {
        if (v == 'null' || v.isEmpty) return 50;
        return int.tryParse(v) ?? 50;
      }
      return 50;
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
    'intelligence': this.intelligence, 'strength': this.strength,
    'speed': this.speed, 'durability': this.durability,
    'power': this.power, 'combat': this.combat,
  };
}

class HeroModel {
  final String id, name, imageUrl, publisher, alignment, fullName;
  final PowerStats powerStats;
  static const String _defaultImageUrl = 'https://via.placeholder.com/300x400/cccccc/666666?text=No+Image';
  static const String _fallbackImageUrl = 'https://picsum.photos/seed/hero/300/400.jpg';

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
  int get attack => ((powerStats.strength + powerStats.combat) / 2).round();
  int get specialAttack => ((powerStats.intelligence + powerStats.power) / 2).round();
  int get defense => ((powerStats.durability + powerStats.combat) / 4).round();

  int get initiative => powerStats.speed;

  // Image helpers
  String get displayImageUrl {
    if (imageUrl.isEmpty) return _defaultImageUrl;
    if (!_isValidImageUrl(imageUrl)) return _fallbackImageUrl;
    return imageUrl;
  }

  bool get hasValidImage => _isValidImageUrl(imageUrl);

  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    return HeroModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: _parseImageUrl(json),
      powerStats: PowerStats.fromJson(json['powerstats'] ?? {}),
      publisher: (json['biography'] as Map?)?['publisher'] as String? ?? '',
      alignment: (json['biography'] as Map?)?['alignment'] as String? ?? 'neutral',
      fullName: (json['biography'] as Map?)?['fullName'] as String? ?? '',
    );
  }

  static String _parseImageUrl(Map<String, dynamic> json) {
    try {
      // Acabab API provides images in different sizes, use 'lg' (large) by default
      final images = json['images'] as Map?;
      if (images != null) {
        final imageUrl = images['lg'] as String? ?? images['md'] as String? ?? images['sm'] as String? ?? '';
        if (imageUrl.isNotEmpty) {
          // Validate URL format
          final uri = Uri.parse(imageUrl);
          if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
            return imageUrl;
          }
        }
      }
      return '';
    } catch (e) {
      return '';
    }
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