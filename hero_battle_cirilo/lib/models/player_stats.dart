class PlayerStats {
  final int totalWins;
  final int totalBattles;
  final int winStreak;

  const PlayerStats({
    required this.totalWins,
    required this.totalBattles,
    required this.winStreak,
  });

  PlayerStats copyWith({
    int? totalWins,
    int? totalBattles,
    int? winStreak,
  }) {
    return PlayerStats(
      totalWins: totalWins ?? this.totalWins,
      totalBattles: totalBattles ?? this.totalBattles,
      winStreak: winStreak ?? this.winStreak,
    );
  }
}
