class BattleHistoryModel {
  final String id;
  final String playerTeamName;
  final String opponentName;
  final String finalScore;
  final DateTime battleDate;
  final String winner;
  final List<String> playerHeroes;
  final List<String> opponentHeroes;
  final String battleSummary;

  BattleHistoryModel({
    required this.id,
    required this.playerTeamName,
    required this.opponentName,
    required this.finalScore,
    required this.battleDate,
    required this.winner,
    required this.playerHeroes,
    required this.opponentHeroes,
    required this.battleSummary,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerTeamName': playerTeamName,
      'opponentName': opponentName,
      'finalScore': finalScore,
      'battleDate': battleDate.toIso8601String(),
      'winner': winner,
      'playerHeroes': playerHeroes.join(','),
      'opponentHeroes': opponentHeroes.join(','),
      'battleSummary': battleSummary,
    };
  }

  // Create from Map (from SQLite)
  factory BattleHistoryModel.fromMap(Map<String, dynamic> map) {
    return BattleHistoryModel(
      id: map['id'],
      playerTeamName: map['playerTeamName'],
      opponentName: map['opponentName'],
      finalScore: map['finalScore'],
      battleDate: DateTime.parse(map['battleDate']),
      winner: map['winner'],
      playerHeroes: map['playerHeroes'].toString().split(','),
      opponentHeroes: map['opponentHeroes'].toString().split(','),
      battleSummary: map['battleSummary'] ?? '',
    );
  }
}
