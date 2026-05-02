class PlayerStats {
  final String name;
  final int totalWins;
  final int totalLosses;

  const PlayerStats({
    required this.name,
    this.totalWins = 0,
    this.totalLosses = 0,
  });

  int get totalBattles => totalWins + totalLosses;

  double get winRate =>
      totalBattles == 0 ? 0 : totalWins / totalBattles;

  PlayerStats copyWith({String? name, int? totalWins, int? totalLosses}) =>
      PlayerStats(
        name: name ?? this.name,
        totalWins: totalWins ?? this.totalWins,
        totalLosses: totalLosses ?? this.totalLosses,
      );
}
