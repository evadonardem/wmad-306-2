class PlayerStats {
  int wins;
  int losses;
  int draws;

  PlayerStats({this.wins = 0, this.losses = 0, this.draws = 0});

  int get totalBattles => wins + losses + draws;
  double get winRate => totalBattles == 0 ? 0 : wins / totalBattles;

  void recordResult({required bool win, bool draw = false}) {
    if (draw) {
      draws++;
    } else if (win) {
      wins++;
    } else {
      losses++;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'wins': wins,
      'losses': losses,
      'draws': draws,
    };
  }

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
    );
  }
}
