import 'package:flutter_test/flutter_test.dart';
import 'package:hero_battle/models/hero_model.dart';
import 'package:hero_battle/providers/battle_provider.dart';

HeroModel hero(
  String id, {
  required String name,
  int intelligence = 50,
  int strength = 50,
  int speed = 50,
  int durability = 50,
  int power = 50,
  int combat = 50,
  String publisher = 'Test',
  String alignment = 'good',
}) {
  return HeroModel(
    id: id,
    name: name,
    imageUrl: '',
    powerStats: PowerStats(
      intelligence: intelligence,
      strength: strength,
      speed: speed,
      durability: durability,
      power: power,
      combat: combat,
    ),
    publisher: publisher,
    alignment: alignment,
    fullName: name,
  );
}

List<HeroModel> buildTeam({required String prefix}) {
  return List.generate(
    5,
    (index) => hero(
      '$prefix-$index',
      name: '$prefix Hero ${index + 1}',
      strength: 70,
      combat: 60,
      speed: 55,
      durability: 70,
      power: 60,
      intelligence: 55,
    ),
  );
}

void main() {
  test('battle initializes correctly', () {
    final provider = BattleProvider(
      playerActionDelay: Duration.zero,
      opponentTurnDelay: Duration.zero,
      opponentActionDelay: Duration.zero,
      persistBattleResults: false,
    );
    final playerTeam = buildTeam(prefix: 'Player');
    final aiTeam = buildTeam(prefix: 'AI');

    provider.prepareMatch(playerTeam: playerTeam, aiTeam: aiTeam, difficulty: 'Easy');
    provider.startBattle(playerHeroId: playerTeam.first.id);

    expect(provider.isBattleActive, isTrue);
    expect(provider.playerHero?.id, playerTeam.first.id);
    expect(provider.aiTeam, hasLength(5));
    expect(provider.playerRemainingHeroes, 5);
    expect(provider.aiRemainingHeroes, 5);
    expect(provider.playerWon, isNull);
    expect(provider.briefing, contains('enters the arena'));
  });

  test('player attack happens before the opponent counterattacks', () async {
    final provider = BattleProvider(
      playerActionDelay: const Duration(milliseconds: 50),
      opponentTurnDelay: const Duration(milliseconds: 50),
      opponentActionDelay: const Duration(milliseconds: 50),
      persistBattleResults: false,
    );
    final playerTeam = buildTeam(prefix: 'Player');
    final aiTeam = buildTeam(prefix: 'AI');

    provider.prepareMatch(playerTeam: playerTeam, aiTeam: aiTeam, difficulty: 'Normal');
    provider.startBattle(playerHeroId: playerTeam.first.id);

    final actionFuture = provider.performPlayerAction(BattleActionType.attack);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(provider.isBusy, isTrue);
    expect(provider.aiHp, lessThan(aiTeam.first.maxHp));
    expect(provider.playerHp, playerTeam.first.maxHp);

    await actionFuture;

    expect(provider.playerHp, lessThan(playerTeam.first.maxHp));
    expect(provider.playerWon, isNull);
  });

  test('defense activates shield without ending the turn', () async {
    final provider = BattleProvider(
      playerActionDelay: Duration.zero,
      opponentTurnDelay: Duration.zero,
      opponentActionDelay: Duration.zero,
      persistBattleResults: false,
    );
    final playerTeam = buildTeam(prefix: 'Player');
    final aiTeam = buildTeam(prefix: 'AI');

    provider.prepareMatch(playerTeam: playerTeam, aiTeam: aiTeam, difficulty: 'Easy');
    provider.startBattle(playerHeroId: playerTeam.first.id);

    provider.useDefense();

    expect(provider.playerShieldAvailable, isFalse);
    expect(provider.isBusy, isFalse);
    expect(provider.briefing, contains('raised a shield'));
  });

  test('team elimination flow and match end work correctly', () async {
    final provider = BattleProvider(
      playerActionDelay: Duration.zero,
      opponentTurnDelay: Duration.zero,
      opponentActionDelay: Duration.zero,
      persistBattleResults: false,
    );
    final playerTeam = List.generate(
      5,
      (index) => hero(
        'player-$index',
        name: 'Player $index',
        strength: 100,
        combat: 100,
        speed: 90,
        durability: 100,
        power: 100,
        intelligence: 80,
      ),
    );
    final aiTeam = List.generate(
      5,
      (index) => hero(
        'ai-$index',
        name: 'AI $index',
        strength: 10,
        combat: 10,
        speed: 10,
        durability: 10,
        power: 10,
        intelligence: 10,
        alignment: 'bad',
      ),
    );

    provider.prepareMatch(playerTeam: playerTeam, aiTeam: aiTeam, difficulty: 'Hard');
    provider.startBattle(playerHeroId: playerTeam.first.id);

    for (var i = 0; i < 5; i++) {
      await provider.performPlayerAction(BattleActionType.attack);
    }

    expect(provider.playerWon, isTrue);
    expect(provider.isBattleActive, isFalse);
    expect(provider.aiRemainingHeroes, 0);
    expect(provider.finalScore, isNotEmpty);
    expect(provider.mvpHero, isNotEmpty);
  });
}
