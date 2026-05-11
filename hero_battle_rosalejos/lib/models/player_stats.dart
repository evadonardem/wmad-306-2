class PlayerStats {
  final String name;
  final bool isDarkTheme;
  final int totalWins;

  const PlayerStats({
    required this.name,
    required this.isDarkTheme,
    this.totalWins = 0,
  });

  PlayerStats copyWith({
    String? name,
    bool? isDarkTheme,
    int? totalWins,
  }) {
    return PlayerStats(
      name: name ?? this.name,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      totalWins: totalWins ?? this.totalWins,
    );
  }
}
