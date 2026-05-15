import 'dart:math';

import '../models/hero_model.dart';

class BattleResult {
  const BattleResult({
    required this.playerScore,
    required this.opponentScore,
    required this.didWin,
    required this.rounds,
  });

  final int playerScore;
  final int opponentScore;
  final bool didWin;
  final List<String> rounds;
}

class BattleEngine {
  final Random _random = Random();

  BattleResult battle(List<HeroModel> playerDeck, List<HeroModel> opponents) {
    var playerScore = 0;
    var opponentScore = 0;
    final rounds = <String>[];
    final count = min(playerDeck.length, opponents.length);

    for (var i = 0; i < count; i++) {
      final player = playerDeck[i];
      final opponent = opponents[i];
      final playerRoll = player.battleScore + _random.nextInt(61);
      final opponentRoll = opponent.battleScore + _random.nextInt(61);
      playerScore += playerRoll;
      opponentScore += opponentRoll;
      rounds.add(
        '${player.name} scored $playerRoll vs ${opponent.name} at $opponentRoll',
      );
    }

    return BattleResult(
      playerScore: playerScore,
      opponentScore: opponentScore,
      didWin: playerScore >= opponentScore,
      rounds: rounds,
    );
  }
}
