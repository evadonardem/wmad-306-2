class PlayerStats {
  final String playerName;
  final int totalWins;
  final int totalBattles;
  final bool isDarkTheme;

  const PlayerStats({
    required this.playerName,
    required this.totalWins,
    required this.totalBattles,
    required this.isDarkTheme,
  });

  double get winRate =>
      totalBattles == 0 ? 0 : (totalWins / totalBattles) * 100;
}
