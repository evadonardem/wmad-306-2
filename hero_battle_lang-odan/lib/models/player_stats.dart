class PlayerStats {
  final String playerName;
  final bool isDarkTheme;
  final int totalWins;

  const PlayerStats({
    required this.playerName,
    required this.isDarkTheme,
    required this.totalWins,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        playerName: json['player_name'] as String? ?? 'Hero',
        isDarkTheme: json['theme_dark'] as bool? ?? true,
        totalWins: json['total_wins'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'player_name': playerName,
        'theme_dark': isDarkTheme,
        'total_wins': totalWins,
      };
}
