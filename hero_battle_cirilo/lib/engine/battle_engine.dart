import 'dart:math';

import '../models/hero_model.dart';

class BattleResult {
  final HeroModel winner;
  final HeroModel loser;
  final String summary;

  BattleResult({required this.winner, required this.loser, required this.summary});
}

class BattleEngine {
  static BattleResult simulate(HeroModel a, HeroModel b) {
    final rnd = Random();
    final scoreA = a.totalPower + rnd.nextInt(30);
    final scoreB = b.totalPower + rnd.nextInt(30);
    final winner = scoreA >= scoreB ? a : b;
    final loser = winner == a ? b : a;
    final margin = (scoreA - scoreB).abs();

    final summary = margin < 15
        ? '${winner.name} narrowly edges out ${loser.name} with a clever move.'
        : '${winner.name} dominates ${loser.name} with overwhelming force.';

    return BattleResult(winner: winner, loser: loser, summary: summary);
  }
}
