class PlayerStats {
	final String playerName;
	final int totalWins;
	final bool isDarkTheme;

	const PlayerStats({
		required this.playerName,
		required this.totalWins,
		required this.isDarkTheme,
	});

	factory PlayerStats.fromJson(Map<String, dynamic> json) {
		return PlayerStats(
			playerName: json['playerName'] as String? ?? 'Hero',
			totalWins: json['totalWins'] as int? ?? 0,
			isDarkTheme: json['isDarkTheme'] as bool? ?? true,
		);
	}

	Map<String, dynamic> toJson() => {
				'playerName': playerName,
				'totalWins': totalWins,
				'isDarkTheme': isDarkTheme,
			};
}
