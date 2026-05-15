class BattleRecord {
  const BattleRecord({
    this.id,
    required this.playerDeckName,
    required this.opponentName,
    required this.didWin,
    required this.playerScore,
    required this.opponentScore,
    required this.createdAt,
  });

  final int? id;
  final String playerDeckName;
  final String opponentName;
  final bool didWin;
  final int playerScore;
  final int opponentScore;
  final DateTime createdAt;

  factory BattleRecord.fromMap(Map<String, dynamic> map) => BattleRecord(
        id: _parseNullableInt(map['id']),
        playerDeckName: map['player_deck_name']?.toString() ?? 'Deck',
        opponentName: map['opponent_name']?.toString() ?? 'Opponent',
        didWin: _parseBool(map['did_win']),
        playerScore: _parseInt(map['player_score']),
        opponentScore: _parseInt(map['opponent_score']),
        createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  factory BattleRecord.fromJson(Map<String, dynamic> json) =>
      BattleRecord.fromMap(json);

  Map<String, dynamic> toMap() => {
        'id': id,
        'player_deck_name': playerDeckName,
        'opponent_name': opponentName,
        'did_win': didWin ? 1 : 0,
        'player_score': playerScore,
        'opponent_score': opponentScore,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => toMap();

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    return _parseInt(value);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().toLowerCase();
    return normalized == 'true' || normalized == '1';
  }
}
