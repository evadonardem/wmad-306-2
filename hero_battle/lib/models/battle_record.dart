class BattleRecord {
  final int? id;
  final String playerHeroId;
  final String playerHeroName;
  final String opponentHeroId;
  final String opponentHeroName;
  final String winnerId;
  final String winnerName;
  final DateTime date;

  BattleRecord({
    this.id,
    required this.playerHeroId,
    required this.playerHeroName,
    required this.opponentHeroId,
    required this.opponentHeroName,
    required this.winnerId,
    required this.winnerName,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'playerHeroId': playerHeroId,
      'playerHeroName': playerHeroName,
      'opponentHeroId': opponentHeroId,
      'opponentHeroName': opponentHeroName,
      'winnerId': winnerId,
      'winnerName': winnerName,
      'date': date.toIso8601String(),
    };
  }

  factory BattleRecord.fromMap(Map<String, dynamic> map) {
    return BattleRecord(
      id: map['id'],
      playerHeroId: map['playerHeroId'],
      playerHeroName: map['playerHeroName'],
      opponentHeroId: map['opponentHeroId'],
      opponentHeroName: map['opponentHeroName'],
      winnerId: map['winnerId'],
      winnerName: map['winnerName'],
      date: DateTime.parse(map['date']),
    );
  }
}