import 'dart:math';

import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

enum BattleActionType { attack, special, defend }

enum _AiTurnResult { resolved, playerHeroDefeated, playerTeamDefeated }

class BattleProvider extends ChangeNotifier {
  BattleProvider({
    Duration? playerActionDelay,
    Duration? opponentTurnDelay,
    Duration? opponentActionDelay,
    bool persistBattleResults = true,
  })  : _playerActionDelay = playerActionDelay ?? const Duration(milliseconds: 2000),
        _opponentTurnDelay = opponentTurnDelay ?? const Duration(milliseconds: 1500),
        _opponentActionDelay = opponentActionDelay ?? const Duration(milliseconds: 2000),
        _persistBattleResults = persistBattleResults;

  final Random _random = Random();
  final Duration _playerActionDelay;
  final Duration _opponentTurnDelay;
  final Duration _opponentActionDelay;
  final bool _persistBattleResults;

  List<HeroModel> _playerTeam = [];
  List<HeroModel> _aiTeam = [];
  final Map<String, int> _playerHp = {};
  final Map<String, int> _aiHp = {};
  final Map<String, int> _playerSpecialsRemaining = {};
  final Map<String, int> _aiSpecialsRemaining = {};
  final Map<String, bool> _playerShieldUsed = {};
  final Map<String, bool> _playerShieldActive = {};
  final Map<String, bool> _aiShieldUsed = {};
  final Map<String, bool> _aiShieldActive = {};
  final Map<String, int> _damageLedger = {};

  int _playerActiveIndex = 0;
  int _aiActiveIndex = 0;
  bool _isBattleActive = false;
  bool _isBusy = false;
  bool _awaitingPlayerSwitch = false;
  bool? _playerWon;
  int _playerShakeTick = 0;
  int _aiShakeTick = 0;
  String _difficulty = 'Easy';
  String _briefing = 'Choose your starting hero.';
  String _finalScore = '';
  String _mvpHero = '';
  int _mvpDamage = 0;

  List<HeroModel> get playerTeam => List.unmodifiable(_playerTeam);
  List<HeroModel> get aiTeam => List.unmodifiable(_aiTeam);
  HeroModel? get playerHero => _heroAt(_playerTeam, _playerActiveIndex);
  HeroModel? get aiHero => _heroAt(_aiTeam, _aiActiveIndex);
  int get playerHp => _currentHp(_playerTeam, _playerActiveIndex, _playerHp);
  int get aiHp => _currentHp(_aiTeam, _aiActiveIndex, _aiHp);
  bool get isBattleActive => _isBattleActive;
  bool get isBusy => _isBusy;
  bool get awaitingPlayerSwitch => _awaitingPlayerSwitch;
  bool? get playerWon => _playerWon;
  int get playerShakeTick => _playerShakeTick;
  int get aiShakeTick => _aiShakeTick;
  String get difficulty => _difficulty;
  String get briefing => _briefing;
  String get finalScore => _finalScore;
  String get mvpHero => _mvpHero;
  int get mvpDamage => _mvpDamage;
  int get playerRemainingHeroes => _playerTeam.where((hero) => _isAlive(hero, _playerHp)).length;
  int get aiRemainingHeroes => _aiTeam.where((hero) => _isAlive(hero, _aiHp)).length;
  bool get playerShieldAvailable =>
      playerHero != null && (_playerShieldUsed[playerHero!.id] ?? false) == false;
  bool get aiShieldAvailable => aiHero != null && (_aiShieldUsed[aiHero!.id] ?? false) == false;
  int get playerSpecialsRemaining => playerHero == null ? 0 : (_playerSpecialsRemaining[playerHero!.id] ?? 0);
  int get aiSpecialsRemaining => aiHero == null ? 0 : (_aiSpecialsRemaining[aiHero!.id] ?? 0);

  List<HeroModel> get playerBenchHeroes {
    final activeId = playerHero?.id;
    return _playerTeam.where((hero) {
      if (hero.id == activeId) return false;
      return _isAlive(hero, _playerHp);
    }).toList();
  }

  List<HeroModel> get aiBenchHeroes {
    final activeId = aiHero?.id;
    return _aiTeam.where((hero) {
      if (hero.id == activeId) return false;
      return _isAlive(hero, _aiHp);
    }).toList();
  }

  int hpForPlayerHero(String heroId) => _playerHp[heroId] ?? 0;
  int hpForAiHero(String heroId) => _aiHp[heroId] ?? 0;

  HeroModel? _heroAt(List<HeroModel> heroes, int index) {
    if (index < 0 || index >= heroes.length) return null;
    return heroes[index];
  }

  int _currentHp(
    List<HeroModel> team,
    int index,
    Map<String, int> hpMap,
  ) {
    final hero = _heroAt(team, index);
    if (hero == null) return 0;
    return hpMap[hero.id] ?? hero.maxHp;
  }

  bool _isAlive(HeroModel hero, Map<String, int> hpMap) {
    return (hpMap[hero.id] ?? hero.maxHp) > 0;
  }

  void prepareMatch({
    required List<HeroModel> playerTeam,
    required List<HeroModel> aiTeam,
    String difficulty = 'Easy',
  }) {
    _playerTeam = List<HeroModel>.from(playerTeam.take(5));
    _aiTeam = List<HeroModel>.from(aiTeam.take(5));
    _difficulty = difficulty;
    _playerHp
      ..clear()
      ..addEntries(_playerTeam.map((hero) => MapEntry(hero.id, hero.maxHp)));
    _aiHp
      ..clear()
      ..addEntries(_aiTeam.map((hero) => MapEntry(hero.id, hero.maxHp)));
    _playerSpecialsRemaining
      ..clear()
      ..addEntries(_playerTeam.map((hero) => MapEntry(hero.id, 1)));
    _aiSpecialsRemaining
      ..clear()
      ..addEntries(_aiTeam.map((hero) => MapEntry(hero.id, 1)));
    _playerShieldUsed
      ..clear()
      ..addEntries(_playerTeam.map((hero) => MapEntry(hero.id, false)));
    _playerShieldActive
      ..clear()
      ..addEntries(_playerTeam.map((hero) => MapEntry(hero.id, false)));
    _aiShieldUsed
      ..clear()
      ..addEntries(_aiTeam.map((hero) => MapEntry(hero.id, false)));
    _aiShieldActive
      ..clear()
      ..addEntries(_aiTeam.map((hero) => MapEntry(hero.id, false)));
    _damageLedger.clear();
    _playerActiveIndex = 0;
    _aiActiveIndex = 0;
    _isBattleActive = false;
    _isBusy = false;
    _awaitingPlayerSwitch = false;
    _playerWon = null;
    _playerShakeTick = 0;
    _aiShakeTick = 0;
    _briefing = 'Choose your starting hero.';
    _finalScore = '';
    _mvpHero = '';
    _mvpDamage = 0;
    notifyListeners();
  }

  void startBattle({required String playerHeroId}) {
    if (_playerTeam.isEmpty || _aiTeam.isEmpty) return;

    final playerIndex = _playerTeam.indexWhere((hero) => hero.id == playerHeroId);
    _playerActiveIndex = playerIndex >= 0 ? playerIndex : 0;
    _aiActiveIndex = _chooseAiStarterIndex();
    _playerShakeTick++;
    _aiShakeTick++;
    _isBattleActive = true;
    _briefing = '${playerHero?.name ?? 'Your hero'} enters the arena!';
    notifyListeners();
  }

  void selectPlayerHero(String heroId) {
    if (!_awaitingPlayerSwitch || _playerWon != null) return;

    switchPlayerHero(heroId);
  }

  bool switchPlayerHero(String heroId) {
    if (!_isBattleActive || _isBusy || _playerWon != null) return false;

    final index = _playerTeam.indexWhere((hero) => hero.id == heroId && _isAlive(hero, _playerHp));
    if (index == -1 || index == _playerActiveIndex) return false;

    _playerActiveIndex = index;
    _playerShakeTick++;
    if (_awaitingPlayerSwitch) {
      _awaitingPlayerSwitch = false;
      _briefing = '${playerHero?.name ?? 'Your hero'} enters the fight!';
    } else {
      _briefing = '${playerHero?.name ?? 'Your hero'} is now active.';
    }
    notifyListeners();
    return true;
  }

  void useDefense() {
    if (!_isBattleActive || _isBusy || _awaitingPlayerSwitch || playerHero == null || _playerWon != null) {
      return;
    }

    if (!playerShieldAvailable) {
      _briefing = '${playerHero!.name} has no shield left.';
      notifyListeners();
      return;
    }

    _playerShieldUsed[playerHero!.id] = true;
    _playerShieldActive[playerHero!.id] = true;
    _briefing = '${playerHero!.name} raised a shield!';
    notifyListeners();
  }

  Future<void> performPlayerAction(BattleActionType action) async {
    if (!_isBattleActive || _isBusy || _awaitingPlayerSwitch || _playerWon != null) return;
    if (playerHero == null || aiHero == null) return;

    if (action == BattleActionType.defend) {
      _isBusy = true;
      useDefense();
      await Future.delayed(_playerActionDelay);
      await _resolveOpponentTurn();
      return;
    }

    if (action == BattleActionType.special && playerSpecialsRemaining <= 0) {
      _briefing = '${playerHero!.name} has no special attacks left.';
      notifyListeners();
      return;
    }

    _isBusy = true;
    final attacker = playerHero!;
    final defender = aiHero!;
    final usingSpecial = action == BattleActionType.special;
    final attackLabel = usingSpecial ? 'Special Attack' : 'Attack';
    final attackValue = usingSpecial ? attacker.specialAttack : attacker.attack;
    final damage = BattleEngine.calculateDamage(
      attack: attackValue,
      defense: defender.defense,
      isSpecial: usingSpecial,
    );

    if (usingSpecial) {
      _playerSpecialsRemaining[attacker.id] = playerSpecialsRemaining - 1;
    }

    _registerDamage(attacker.name, damage);
    _applyDamageToAi(damage);
    _briefing = '${attacker.name} used $attackLabel! $damage Damage';
    notifyListeners();
    await Future.delayed(_playerActionDelay);

    if (_isTeamDefeated(_aiTeam, _aiHp)) {
      await _finishBattle(playerWon: true);
      return;
    }

    if (aiHp <= 0) {
      _briefing = '${defender.name} was defeated!';
      notifyListeners();
      await Future.delayed(_opponentTurnDelay);
      _advanceAiHero();
      if (_isTeamDefeated(_aiTeam, _aiHp)) {
        await _finishBattle(playerWon: true);
        return;
      }
      _briefing = '${aiHero?.name ?? 'AI hero'} enters the arena!';
      _isBusy = false;
      notifyListeners();
      return;
    }

    await _resolveOpponentTurn();
  }

  Future<void> _resolveOpponentTurn() async {
    _briefing = 'Opponent turn...';
    notifyListeners();
    await Future.delayed(_opponentTurnDelay);

    var aiTurnResult = await _performAiAttack();
    while (aiTurnResult == _AiTurnResult.playerHeroDefeated) {
      final defeatedName = playerHero?.name ?? 'Your hero';
      _briefing = '$defeatedName was defeated!';
      notifyListeners();
      await Future.delayed(_opponentTurnDelay);

      final switched = _advancePlayerHero();
      if (!switched || _isTeamDefeated(_playerTeam, _playerHp)) {
        await _finishBattle(playerWon: false);
        return;
      }

      _briefing = '${playerHero?.name ?? 'Your hero'} enters the fight!';
      notifyListeners();
      await Future.delayed(_opponentTurnDelay);

      _briefing = 'Opponent keeps the turn...';
      notifyListeners();
      await Future.delayed(_opponentTurnDelay);
      aiTurnResult = await _performAiAttack();
    }

    if (aiTurnResult == _AiTurnResult.playerTeamDefeated) {
      await _finishBattle(playerWon: false);
      return;
    }

    _isBusy = false;
    _briefing = 'Battle continues.';
    notifyListeners();
  }

  Future<void> resumeAfterPlayerSwitch() async {
    if (_playerWon != null || !_isBattleActive) return;
    _briefing = '${playerHero?.name ?? 'Your hero'} is ready.';
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    _briefing = 'Battle resumes.';
    notifyListeners();
  }

  int _chooseAiStarterIndex() {
    if (_aiTeam.isEmpty) return 0;

    final scoredHeroes = _aiTeam.asMap().entries.map((entry) {
      final hero = entry.value;
      final score = hero.attack * 2 + hero.specialAttack * 2 + hero.defense + hero.initiative;
      final difficultyBias = _difficulty.toLowerCase() == 'hard'
          ? 20
          : _difficulty.toLowerCase() == 'easy'
              ? -20
              : 0;
      return MapEntry(entry.key, score + difficultyBias + _random.nextInt(31));
    }).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return scoredHeroes.first.key;
  }

  BattleActionType _chooseAiAction() {
    final hero = aiHero;
    final player = playerHero;
    if (hero == null || player == null) return BattleActionType.attack;

    final specialsLeft = aiSpecialsRemaining;
    final projectedSpecialDamage = BattleEngine.calculateDamage(
      attack: hero.specialAttack,
      defense: player.defense,
      isSpecial: true,
    );
    final projectedBasicDamage = BattleEngine.calculateDamage(
      attack: hero.attack,
      defense: player.defense,
    );
    final canFinishWithSpecial = projectedSpecialDamage >= playerHp;
    final canFinishWithBasic = projectedBasicDamage >= playerHp;
    final playerThreat = BattleEngine.calculateDamage(
      attack: player.attack,
      defense: hero.defense,
    );
    final aiHpRatio = aiHp / max(hero.maxHp, 1);
    final difficulty = _difficulty.toLowerCase();
    final canUseShield = aiShieldAvailable;

    if (specialsLeft > 0 && canFinishWithSpecial) {
      return BattleActionType.special;
    }

    if (canUseShield && aiHpRatio < 0.25 && playerThreat > aiHp && difficulty != 'easy') {
      return BattleActionType.defend;
    }

    if (specialsLeft > 0 && canFinishWithBasic && difficulty != 'easy') {
      return BattleActionType.special;
    }

    if (specialsLeft > 0 && aiHpRatio < 0.35 && playerThreat > aiHp && difficulty != 'easy') {
      return BattleActionType.special;
    }

    if (specialsLeft > 0 && difficulty == 'hard' && _random.nextBool()) {
      return BattleActionType.special;
    }

    if (difficulty == 'easy' && _random.nextInt(100) < 75) {
      return BattleActionType.attack;
    }

    if (specialsLeft > 0 && _random.nextInt(100) < 40) {
      return BattleActionType.special;
    }

    return canFinishWithBasic ? BattleActionType.attack : BattleActionType.attack;
  }

  void _applyDamageToPlayer(int damage) {
    final hero = playerHero;
    if (hero == null) return;
    final current = _playerHp[hero.id] ?? hero.maxHp;
    final next = (current - damage).clamp(0, hero.maxHp);
    _playerHp[hero.id] = next;
    if (next < current) {
      _playerShakeTick++;
    }
  }

  void _applyDamageToAi(int damage) {
    final hero = aiHero;
    if (hero == null) return;
    final mitigatedDamage = _applyAiShield(damage);
    final current = _aiHp[hero.id] ?? hero.maxHp;
    final next = (current - mitigatedDamage).clamp(0, hero.maxHp);
    _aiHp[hero.id] = next;
    if (next < current) {
      _aiShakeTick++;
    }
  }

  int _applyPlayerShield(int damage) {
    final hero = playerHero;
    if (hero == null) return damage;
    if (!(_playerShieldActive[hero.id] ?? false)) return damage;

    _playerShieldActive[hero.id] = false;
    return max(0, damage - hero.defense);
  }

  int _applyAiShield(int damage) {
    final hero = aiHero;
    if (hero == null) return damage;
    if (!(_aiShieldActive[hero.id] ?? false)) return damage;

    _aiShieldActive[hero.id] = false;
    return max(0, damage - hero.defense);
  }

  Future<_AiTurnResult> _performAiAttack() async {
    final aiAttacker = aiHero;
    final defender = playerHero;
    if (aiAttacker == null || defender == null) return _AiTurnResult.resolved;

    final aiAction = _chooseAiAction();

    if (aiAction == BattleActionType.defend) {
      _aiShieldUsed[aiAttacker.id] = true;
      _aiShieldActive[aiAttacker.id] = true;
      _briefing = '${aiAttacker.name} raised a shield!';
      notifyListeners();
      await Future.delayed(_opponentActionDelay);
      return _AiTurnResult.resolved;
    }

    final aiAttackLabel = aiAction == BattleActionType.special ? 'Special Attack' : 'Attack';
    final aiUsingSpecial = aiAction == BattleActionType.special;
    final aiAttackValue = aiUsingSpecial ? aiAttacker.specialAttack : aiAttacker.attack;
    final aiDamage = BattleEngine.calculateDamage(
      attack: aiAttackValue,
      defense: defender.defense,
      isSpecial: aiUsingSpecial,
    );

    if (aiUsingSpecial) {
      _aiSpecialsRemaining[aiAttacker.id] = aiSpecialsRemaining - 1;
    }

    final mitigatedAiDamage = _applyPlayerShield(aiDamage);
    _registerDamage(aiAttacker.name, mitigatedAiDamage);
    _applyDamageToPlayer(mitigatedAiDamage);
    _briefing = '${aiAttacker.name} used $aiAttackLabel! $mitigatedAiDamage Damage';
    notifyListeners();
    await Future.delayed(_opponentActionDelay);

    if (_isTeamDefeated(_playerTeam, _playerHp)) {
      return _AiTurnResult.playerTeamDefeated;
    }

    if (playerHp <= 0) {
      return _AiTurnResult.playerHeroDefeated;
    }

    return _AiTurnResult.resolved;
  }

  void _advanceAiHero() {
    final remaining = _aiTeam
        .asMap()
        .entries
        .where((entry) => _isAlive(entry.value, _aiHp))
        .toList();
    if (remaining.isEmpty) return;

    final best = remaining.reduce((currentBest, entry) {
      final currentHero = currentBest.value;
      final candidate = entry.value;
      final currentScore = currentHero.attack * 2 + currentHero.specialAttack * 2 + currentHero.defense + currentHero.initiative;
      final candidateScore = candidate.attack * 2 + candidate.specialAttack * 2 + candidate.defense + candidate.initiative;
      return candidateScore > currentScore ? entry : currentBest;
    });

    _aiActiveIndex = best.key;
    _aiShakeTick++;
  }

  bool _advancePlayerHero() {
    final remaining = _playerTeam
        .asMap()
        .entries
        .where((entry) => _isAlive(entry.value, _playerHp))
        .toList();
    if (remaining.isEmpty) return false;

    final best = remaining.reduce((currentBest, entry) {
      final currentHero = currentBest.value;
      final candidate = entry.value;
      final currentScore = currentHero.attack * 2 + currentHero.specialAttack * 2 + currentHero.defense + currentHero.initiative;
      final candidateScore = candidate.attack * 2 + candidate.specialAttack * 2 + candidate.defense + candidate.initiative;
      return candidateScore > currentScore ? entry : currentBest;
    });

    _playerActiveIndex = best.key;
    _playerShakeTick++;
    _awaitingPlayerSwitch = false;
    return true;
  }

  bool _isTeamDefeated(List<HeroModel> heroes, Map<String, int> hpMap) {
    return heroes.every((hero) => (hpMap[hero.id] ?? hero.maxHp) <= 0);
  }

  void _registerDamage(String heroName, int damage) {
    if (damage <= 0) return;
    final total = (_damageLedger[heroName] ?? 0) + damage;
    _damageLedger[heroName] = total;
    if (total >= _mvpDamage) {
      _mvpDamage = total;
      _mvpHero = heroName;
    }
  }

  Future<void> _finishBattle({required bool playerWon}) async {
    _isBattleActive = false;
    _isBusy = false;
    _awaitingPlayerSwitch = false;
    _playerWon = playerWon;
    _finalScore = '$playerRemainingHeroes-$aiRemainingHeroes';
    _briefing = playerWon ? 'VICTORY!' : 'DEFEAT!';

    final playerTeamSummary = _playerTeam.map((hero) => hero.name).join(' | ');
    final aiTeamSummary = _aiTeam.map((hero) => hero.name).join(' | ');

    if (_persistBattleResults) {
      await DatabaseService().saveBattleRecord(
        BattleRecord(
          playerHero: playerTeamSummary,
          aiHero: aiTeamSummary,
          playerWon: playerWon,
          roundsPlayed: (_playerTeam.length - playerRemainingHeroes) + (_aiTeam.length - aiRemainingHeroes),
          playedAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    notifyListeners();
  }

  void resetBattle() {
    _playerTeam = [];
    _aiTeam = [];
    _playerHp.clear();
    _aiHp.clear();
    _playerSpecialsRemaining.clear();
    _aiSpecialsRemaining.clear();
    _playerShieldUsed.clear();
    _playerShieldActive.clear();
    _aiShieldUsed.clear();
    _aiShieldActive.clear();
    _damageLedger.clear();
    _playerActiveIndex = 0;
    _aiActiveIndex = 0;
    _isBattleActive = false;
    _isBusy = false;
    _awaitingPlayerSwitch = false;
    _playerWon = null;
    _playerShakeTick = 0;
    _aiShakeTick = 0;
    _briefing = 'Choose your starting hero.';
    _difficulty = 'Easy';
    _finalScore = '';
    _mvpHero = '';
    _mvpDamage = 0;
    notifyListeners();
  }
}
