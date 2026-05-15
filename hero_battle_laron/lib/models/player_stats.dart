class PlayerStats {
  final int wins;
  final int losses;
  final int totalBattles;
  final double winRate;

  PlayerStats({
    required this.wins,
    required this.losses,
    required this.totalBattles,
    required this.winRate,
  });

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      totalBattles: map['totalBattles'] ?? 0,
      winRate: map['winRate'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wins': wins,
      'losses': losses,
      'totalBattles': totalBattles,
      'winRate': winRate,
    };
  }
}