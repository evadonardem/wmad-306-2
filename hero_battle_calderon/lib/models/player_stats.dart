class PlayerStats {
  final int totalGames;
  final int totalWins;
  final int totalLosses;

  PlayerStats({
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
  });

  double get winRate => totalGames == 0 ? 0.0 : totalWins / totalGames;

  PlayerStats copyWith({
    int? totalGames,
    int? totalWins,
    int? totalLosses,
  }) {
    return PlayerStats(
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
    );
  }
}
