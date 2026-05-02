import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleResult {
  final bool playerWon;
  final int roundsPlayed;
  final List<String> battleLog;

  BattleResult({
    required this.playerWon,
    required this.roundsPlayed,
    required this.battleLog,
  });
}

class BattleEngine {
  static Future<BattleResult> simulateBattle(HeroModel playerHero, HeroModel aiHero) async {
    final List<String> battleLog = [];
    int playerHp = 100;
    int aiHp = 100;
    int rounds = 0;
    bool playerWon = false;

    battleLog.add('Battle started: $playerHero vs $aiHero');

    while (playerHp > 0 && aiHp > 0 && rounds < 20) {
      rounds++;
      
      // Simple battle logic - random damage based on hero stats
      final playerDamage = _calculateDamage(playerHero);
      final aiDamage = _calculateDamage(aiHero);
      
      aiHp -= playerDamage;
      playerHp -= aiDamage;
      
      battleLog.add('Round $rounds: $playerHero deals $playerDamage, $aiHero deals $aiDamage');
      
      if (aiHp <= 0) {
        playerWon = true;
        battleLog.add('$playerHero wins!');
        break;
      } else if (playerHp <= 0) {
        playerWon = false;
        battleLog.add('$aiHero wins!');
        break;
      }
    }

    // Save battle record to database
    final record = BattleRecord(
      playerHero: playerHero.name,
      aiHero: aiHero.name,
      playerWon: playerWon,
      roundsPlayed: rounds,
      playedAt: DateTime.now().toIso8601String(),
    );
    
    await DatabaseService().saveBattleRecord(record);

    return BattleResult(
      playerWon: playerWon,
      roundsPlayed: rounds,
      battleLog: battleLog,
    );
  }

  static int _calculateDamage(HeroModel hero) {
    // Simple damage calculation based on hero stats
    final baseDamage = 10;
    final statBonus = (hero.powerStats.power + hero.powerStats.speed + hero.defense) ~/ 10;
    return baseDamage + statBonus + (hero.powerStats.power % 5);
  }
}