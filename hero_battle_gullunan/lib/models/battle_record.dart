import 'dart:convert';
import 'hero_model.dart';

class BattleRecord {
  final int? id;
  final String playerHero;
  final String aiHero;
  final List<HeroModel> playerTeam;
  final List<HeroModel> aiTeam;
  final bool playerWon;
  final int roundsPlayed;
  final String playedAt;

  const BattleRecord({
    this.id,
    required this.playerHero,
    required this.aiHero,
    required this.playerTeam,
    required this.aiTeam,
    required this.playerWon,
    required this.roundsPlayed,
    required this.playedAt,
  });

  factory BattleRecord.fromMap(Map<String, dynamic> map) {
    List<HeroModel> parseTeam(String? teamJson) {
      if (teamJson == null || teamJson.isEmpty) return [];
      try {
        final decoded = jsonDecode(teamJson) as List<dynamic>;
        return decoded
            .map((e) => HeroModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return BattleRecord(
      id: map['id'] as int?,
      playerHero: map['player_hero'] as String,
      aiHero: map['ai_hero'] as String,
      playerTeam: parseTeam(map['player_team'] as String?),
      aiTeam: parseTeam(map['ai_team'] as String?),
      playerWon: (map['player_won'] as int) == 1,
      roundsPlayed: map['rounds_played'] as int,
      playedAt: map['played_at'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'player_hero': playerHero,
    'ai_hero': aiHero,
    'player_team': jsonEncode(playerTeam.map((h) => h.toJson()).toList()),
    'ai_team': jsonEncode(aiTeam.map((h) => h.toJson()).toList()),
    'player_won': playerWon ? 1 : 0,
    'rounds_played': roundsPlayed,
    'played_at': playedAt,
  };
}
