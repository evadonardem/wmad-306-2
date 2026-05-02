class PlayerStats {
  final String name;
  final int totalWins;
  final int totalMatches;

  const PlayerStats({
    required this.name,
    this.totalWins = 0,
    this.totalMatches = 0,
  });

  double get winRate => totalMatches == 0 ? 0.0 : totalWins / totalMatches;

  PlayerStats copyWith({String? name, int? totalWins, int? totalMatches}) {
    return PlayerStats(
      name: name ?? this.name,
      totalWins: totalWins ?? this.totalWins,
      totalMatches: totalMatches ?? this.totalMatches,
    );
  }
}