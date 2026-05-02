// lib/models/player_stats.dart
class PlayerStats {
  final String playerName;
  final bool isDarkTheme;
  final int totalWins;

  const PlayerStats({
    required this.playerName,
    required this.isDarkTheme,
    required this.totalWins,
  });
}