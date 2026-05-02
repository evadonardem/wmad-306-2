// lib/models/battle_record.dart

class BattleRecord {
  final int? id; // SQLite row id (null before insert)
  final String playerHero; // hero name
  final String aiHero;
  final bool playerWon;
  final int roundsPlayed;
  final String playedAt; // ISO 8601 string

  const BattleRecord({
    this.id,
    required this.playerHero,
    required this.aiHero,
    required this.playerWon,
    required this.roundsPlayed,
    required this.playedAt,
  });

  factory BattleRecord.fromMap(Map<String, dynamic> map) => BattleRecord(
    id: map['id'] as int?,
    playerHero: map['player_hero'] as String,
    aiHero: map['ai_hero'] as String,
    playerWon: (map['player_won'] as int) == 1,
    roundsPlayed: map['rounds_played'] as int,
    playedAt: map['played_at'] as String,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'player_hero': playerHero,
    'ai_hero': aiHero,
    'player_won': playerWon ? 1 : 0,
    'rounds_played': roundsPlayed,
    'played_at': playedAt,
  };

  // Getter for the winner's name
  String get winner => playerWon ? playerHero : aiHero;

  // Helper method to get formatted date string for display
  String get formattedDate {
    try {
      final DateTime dateTime = DateTime.parse(playedAt);
      return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return playedAt;
    }
  }

  // Helper method to get result text
  String get resultText => playerWon ? 'Victory! 🎉' : 'Defeat 💀';

  // Helper method to get result color (for UI)
  int get resultColor => playerWon ? 0xFF4CAF50 : 0xFFF44336;

  // Create a copy with updated fields
  BattleRecord copyWith({
    int? id,
    String? playerHero,
    String? aiHero,
    bool? playerWon,
    int? roundsPlayed,
    String? playedAt,
  }) {
    return BattleRecord(
      id: id ?? this.id,
      playerHero: playerHero ?? this.playerHero,
      aiHero: aiHero ?? this.aiHero,
      playerWon: playerWon ?? this.playerWon,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  String toString() {
    return 'BattleRecord(id: $id, playerHero: $playerHero, aiHero: $aiHero, '
        'playerWon: $playerWon, roundsPlayed: $roundsPlayed, playedAt: $playedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BattleRecord &&
        other.id == id &&
        other.playerHero == playerHero &&
        other.aiHero == aiHero &&
        other.playerWon == playerWon &&
        other.roundsPlayed == roundsPlayed &&
        other.playedAt == playedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, playerHero, aiHero, playerWon, roundsPlayed, playedAt);
  }
}