import '../models/hero_model.dart';
import 'dart:math';

class BattleResult {
  final List<String> log;
  final bool playerWon;
  final int rounds;

  BattleResult({required this.log, required this.playerWon, required this.rounds});
}

class BattleEngine {
  static final List<String> _aiNames = [
    'Thanos', 'Darkseid', 'Ultron', 'Brainiac', 'Loki', 'Venom', 'Hela', 'Zod',
    'Doomsday', 'Abomination', 'Carnage', 'Galactus', 'Apocalypse', 'Juggernaut',
    'Magneto', 'Mystique', 'Sabretooth', 'Sinestro', 'Steppenwolf', 'Parallax',
    'Dormammu', 'Mephisto', 'Onslaught', 'Stryfe', 'Despero', 'Mongul', 'Ares',
    'Eclipso', 'Bane', 'Joker', 'Riddler', 'Penguin', 'Scarecrow', 'Clayface'
  ];

  static String getRandomAiName() {
    final random = Random();
    return _aiNames[random.nextInt(_aiNames.length)];
  }

  static BattleResult simulate(HeroModel player, HeroModel ai) {
    List<String> log = [];
    int playerHp = player.maxHp;
    int aiHp = ai.maxHp;
    int rounds = 0;
    
    log.add('Battle Start: ${player.name} vs ${ai.name}');
    
    while (playerHp > 0 && aiHp > 0 && rounds < 50) {
      rounds++;
      log.add('--- Round $rounds ---');
      
      // Determine turn order based on initiative
      if (player.initiative >= ai.initiative) {
        // Player attacks first
        aiHp -= _performAttack(player, ai, log, isPlayer: true);
        if (aiHp <= 0) break;
        playerHp -= _performAttack(ai, player, log, isPlayer: false);
      } else {
        // AI attacks first
        playerHp -= _performAttack(ai, player, log, isPlayer: false);
        if (playerHp <= 0) break;
        aiHp -= _performAttack(player, ai, log, isPlayer: true);
      }
    }
    
    bool playerWon = playerHp > 0;
    log.add(playerWon ? '${player.name} Wins!' : '${ai.name} Wins!');
    
    return BattleResult(log: log, playerWon: playerWon, rounds: rounds);
  }

  static int _performAttack(HeroModel attacker, HeroModel defender, List<String> log, {required bool isPlayer}) {
    final random = Random();
    bool isSpecial = random.nextDouble() < 0.2;
    int rawDamage = isSpecial ? attacker.specialAttack : attacker.attack;
    int damage = max(1, rawDamage - defender.defense);
    
    log.add('${attacker.name} ${isSpecial ? "uses SPECIAL ATTACK and" : ""} deals $damage damage to ${defender.name}');
    return damage;
  }
}
