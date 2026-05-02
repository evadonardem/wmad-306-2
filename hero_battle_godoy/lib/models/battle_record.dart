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
playerHero: map['player_hero'] as String? ?? map['player1_hero'] as String? ?? 'Unknown',
aiHero: map['ai_hero'] as String? ?? map['opponent_hero'] as String? ?? map['player2_hero'] as String? ?? 'Unknown',
playerWon: (map['player_won'] as int? ?? map['player1_won'] as int? ?? 0) == 1,
roundsPlayed: map['rounds_played'] as int? ?? 0,
playedAt: map['played_at'] as String? ?? '',
);
Map<String, dynamic> toMap() => {
if (id != null) 'id': id,
'player_hero': playerHero,
'ai_hero': aiHero,
'player_won': playerWon ? 1 : 0,
'rounds_played': roundsPlayed,
'played_at': playedAt,
};
}