class PlayerStats {
	final String playerName;
	final bool isDarkTheme;
	final int totalWins;

	const PlayerStats({
		required this.playerName,
		required this.isDarkTheme,
		required this.totalWins,
	});

	factory PlayerStats.fromJson(Map<String, dynamic> json) {
		return PlayerStats(
			playerName: json['playerName'] as String? ?? 'Hero',
			isDarkTheme: json['isDarkTheme'] as bool? ?? true,
			totalWins: json['totalWins'] as int? ?? 0,
		);
	}

	Map<String, dynamic> toJson() => {
				'playerName': playerName,
				'isDarkTheme': isDarkTheme,
				'totalWins': totalWins,
			};
}

