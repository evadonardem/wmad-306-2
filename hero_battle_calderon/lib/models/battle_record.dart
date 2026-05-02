import 'dart:convert';

class BattleRecord {
  final int? id; // SQLite row id (null before insert)
  final String aiName; // Random name for the AI
  final List<String> playerTeam; // hero names
  final List<String> aiTeam;
  final bool playerWon;
  final int roundsPlayed;
  final String playedAt; // ISO 8601 string

  const BattleRecord({
    this.id,
    required this.aiName,
    required this.playerTeam,
    required this.aiTeam,
    required this.playerWon,
    required this.roundsPlayed,
    required this.playedAt,
  });

  factory BattleRecord.fromMap(Map<String, dynamic> map) {
    return BattleRecord(
      id: map['id'] as int?,
      aiName: map['ai_name'] as String? ?? 'Enemy AI',
      playerTeam: (jsonDecode(map['player_team'] as String) as List).cast<String>(),
      aiTeam: (jsonDecode(map['ai_team'] as String) as List).cast<String>(),
      playerWon: (map['player_won'] as int) == 1,
      roundsPlayed: map['rounds_played'] as int,
      playedAt: map['played_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'ai_name': aiName,
        'player_team': jsonEncode(playerTeam),
        'ai_team': jsonEncode(aiTeam),
        'player_won': playerWon ? 1 : 0,
        'rounds_played': roundsPlayed,
        'played_at': playedAt,
      };
}
