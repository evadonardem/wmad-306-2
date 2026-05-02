class PlayerStats {
  final String playerName;
  final int totalBattles;
  final int wins;
  final int losses;
  final int totalWins;
  final double winRate;
  final DateTime lastBattleDate;

  const PlayerStats({
    required this.playerName,
    required this.totalBattles,
    required this.wins,
    required this.losses,
    required this.totalWins,
    required this.winRate,
    required this.lastBattleDate,
  });

  double get winPercentage => totalBattles > 0 ? (wins / totalBattles) * 100 : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'totalBattles': totalBattles,
      'wins': wins,
      'losses': losses,
      'totalWins': totalWins,
      'winRate': winRate,
      'lastBattleDate': lastBattleDate.millisecondsSinceEpoch,
    };
  }

  factory PlayerStats.fromMap(Map<String, dynamic> map) {
    return PlayerStats(
      playerName: map['playerName'],
      totalBattles: map['totalBattles'],
      wins: map['wins'],
      losses: map['losses'],
      totalWins: map['totalWins'],
      winRate: map['winRate'],
      lastBattleDate: DateTime.fromMillisecondsSinceEpoch(map['lastBattleDate']),
    );
  }

  @override
  String toString() {
    return 'PlayerStats{playerName: $playerName, totalBattles: $totalBattles, wins: $wins, losses: $losses, winRate: $winRate}';
  }
}