class PlayerStats {
  final int totalWins;
  final int totalLosses;
  final int totalBattles;
  final double winRate;

  const PlayerStats({
    required this.totalWins,
    required this.totalLosses,
    required this.totalBattles,
    required this.winRate,
  });

  factory PlayerStats.fromValues(int wins, int losses) {
    final total = wins + losses;
    final rate = total > 0 ? (wins / total) : 0.0;
    return PlayerStats(
      totalWins: wins,
      totalLosses: losses,
      totalBattles: total,
      winRate: rate,
    );
  }
}
