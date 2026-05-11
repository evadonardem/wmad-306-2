class BattleRecord {
  final int? id;
  final String playerHero;
  final String aiHero;
  final String? aiName;
  final bool playerWon;
  final int roundsPlayed;
  final String playedAt;
  final String playerDeckImages;
  final String aiDeckImages;
  final String? playerDeckJson;
  final String? aiDeckJson;

  const BattleRecord({
    this.id,
    required this.playerHero,
    required this.aiHero,
    this.aiName,
    required this.playerWon,
    required this.roundsPlayed,
    required this.playedAt,
    required this.playerDeckImages,
    required this.aiDeckImages,
    this.playerDeckJson,
    this.aiDeckJson,
  });

  factory BattleRecord.fromMap(Map<String, dynamic> map) => BattleRecord(
        id: map['id'] as int?,
        playerHero: map['player_hero'] as String,
        aiHero: map['ai_hero'] as String,
        aiName: map['ai_name'] as String?,
        playerWon: (map['player_won'] as int) == 1,
        roundsPlayed: map['rounds_played'] as int,
        playedAt: map['played_at'] as String,
        playerDeckImages: map['player_deck_images'] as String? ?? '[]',
        aiDeckImages: map['ai_deck_images'] as String? ?? '[]',
        playerDeckJson: map['player_deck_json'] as String?,
        aiDeckJson: map['ai_deck_json'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'player_hero': playerHero,
        'ai_hero': aiHero,
        'ai_name': aiName,
        'player_won': playerWon ? 1 : 0,
        'rounds_played': roundsPlayed,
        'played_at': playedAt,
        'player_deck_images': playerDeckImages,
        'ai_deck_images': aiDeckImages,
        'player_deck_json': playerDeckJson,
        'ai_deck_json': aiDeckJson,
      };
}
