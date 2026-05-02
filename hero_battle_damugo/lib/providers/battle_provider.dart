import 'dart:async';

import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  static const int _switchCooldownDurationSeconds = 6;
  static const int _bansPerSide = 3;

  List<HeroModel> _playerTeam = <HeroModel>[];
  List<HeroModel> _aiTeam = <HeroModel>[];
  List<int> _playerTeamHp = <int>[];
  List<int> _aiTeamHp = <int>[];
  List<int> _playerSwitchCooldowns = <int>[];
  List<int> _aiSwitchCooldowns = <int>[];
  Timer? _switchCooldownTicker;
  int _playerActiveIndex = -1;
  int _aiActiveIndex = -1;
  int _lastPlayerDamage = 0;
  int _lastAiDamage = 0;
  int _round = 0;
  bool _isBattleOver = false;
  bool _playerWon = false;
  List<String> _battleLog = <String>[];
  String? _roundWinner;

  // Banning phase variables
  bool _isInBanningPhase = false;
  List<HeroModel> _availableHeroesForBanning = <HeroModel>[];
  Set<String> _playerBannedHeroes = <String>{};
  Set<String> _aiEnemyBannedHeroes = <String>{};
  bool _isPlayerTurnToBan = true;
  int _banRound = 0;

  List<HeroModel> get playerTeam => List.unmodifiable(_playerTeam);
  List<HeroModel> get aiTeam => List.unmodifiable(_aiTeam);
  List<int> get playerTeamHp => List.unmodifiable(_playerTeamHp);
  List<int> get aiTeamHp => List.unmodifiable(_aiTeamHp);
  List<int> get playerSwitchCooldowns =>
      List.unmodifiable(_playerSwitchCooldowns);
  List<int> get aiSwitchCooldowns => List.unmodifiable(_aiSwitchCooldowns);
  int get playerActiveIndex => _playerActiveIndex;
  int get aiActiveIndex => _aiActiveIndex;
  HeroModel? get playerHero => _activeHero(_playerTeam, _playerActiveIndex);
  HeroModel? get aiHero => _activeHero(_aiTeam, _aiActiveIndex);
  int get playerHp => _activeHp(_playerTeamHp, _playerActiveIndex);
  int get aiHp => _activeHp(_aiTeamHp, _aiActiveIndex);
  int get lastPlayerDamage => _lastPlayerDamage;
  int get lastAiDamage => _lastAiDamage;
  int get round => _round;
  bool get isBattleOver => _isBattleOver;
  bool get playerWon => _playerWon;
  List<String> get battleLog => List.unmodifiable(_battleLog);
  String? get roundWinner => _roundWinner;
  int get switchCooldownDurationSeconds => _switchCooldownDurationSeconds;
  bool get canSwitchPlayerHero =>
      !_isBattleOver && _playerAliveCount > 1 && _playerActiveIndex >= 0;

  // Banning phase getters
  bool get isInBanningPhase => _isInBanningPhase;
  List<HeroModel> get availableHeroesForBanning =>
      List.unmodifiable(_availableHeroesForBanning);
  Set<String> get playerBannedHeroes =>
      <String>{..._playerBannedHeroes};
  Set<String> get aiEnemyBannedHeroes =>
      <String>{..._aiEnemyBannedHeroes};
  List<HeroModel> get playerBannedHeroModels => _heroesFromNames(
        _playerBannedHeroes,
      );
  List<HeroModel> get aiBannedHeroModels => _heroesFromNames(
        _aiEnemyBannedHeroes,
      );
  bool get isPlayerTurnToBan => _isPlayerTurnToBan;
  int get banRound => _banRound;
  int get playerBanCount => _playerBannedHeroes.length;
  int get aiBanCount => _aiEnemyBannedHeroes.length;
  int get bansPerSide => _bansPerSide;

  int get _playerAliveCount => _playerTeamHp.where((hp) => hp > 0).length;
  int get _aiAliveCount => _aiTeamHp.where((hp) => hp > 0).length;

  void startBanningPhase({
    required List<HeroModel> playerTeam,
    required List<HeroModel> aiTeam,
    List<HeroModel>? banPool,
  }) {
    final sourcePool = banPool ?? <HeroModel>[...playerTeam, ...aiTeam];
    final uniqueHeroes = <String, HeroModel>{};
    for (final hero in sourcePool) {
      uniqueHeroes[hero.name.toLowerCase()] = hero;
    }

    _availableHeroesForBanning = uniqueHeroes.values.toList()
      ..sort((a, b) => _heroScore(b).compareTo(_heroScore(a)));
    _playerBannedHeroes = <String>{};
    _aiEnemyBannedHeroes = <String>{};
    _isPlayerTurnToBan = true;
    _banRound = 0;
    _isInBanningPhase = true;
    _battleLog = <String>[
      'Banning phase started!',
      'Each side can ban up to $_bansPerSide heroes.',
    ];
    notifyListeners();
  }

  bool playerBanHero(String heroName) {
    if (!_isInBanningPhase || !_isPlayerTurnToBan) {
      return false;
    }
    if (_playerBannedHeroes.length >= _bansPerSide) {
      return false;
    }
    if (_playerBannedHeroes.contains(heroName)) {
      return false;
    }

    _playerBannedHeroes.add(heroName);
    _battleLog = <String>[
      ..._battleLog,
      'You banned ${_getHeroDisplayName(heroName)}',
    ];

    // Switch turn if player is done or AI needs to ban
    if (_playerBannedHeroes.length < _bansPerSide) {
      _isPlayerTurnToBan = false;
      _scheduleAiBan();
    } else {
      _isPlayerTurnToBan = false;
      _scheduleAiBan();
    }

    notifyListeners();
    return true;
  }

  void _scheduleAiBan() {
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      _aiAutoBan();
    });
  }

  void _aiAutoBan() {
    if (!_isInBanningPhase || _isPlayerTurnToBan) {
      return;
    }

    if (_aiEnemyBannedHeroes.length >= _bansPerSide) {
      // AI is done banning
      _checkIfBanningPhaseComplete();
      return;
    }

    // AI picks a random strong hero to ban
    final availableToBan = _availableHeroesForBanning
        .where((hero) =>
            !_aiEnemyBannedHeroes.contains(hero.name) &&
            !_playerBannedHeroes.contains(hero.name))
        .toList();

    if (availableToBan.isEmpty) {
      _checkIfBanningPhaseComplete();
      return;
    }

    // AI bans a strong hero (highest score)
    final heroToBan = availableToBan.reduce((a, b) =>
        _heroScore(a) > _heroScore(b) ? a : b);
    
    _aiEnemyBannedHeroes.add(heroToBan.name);
    _battleLog = <String>[
      ..._battleLog,
      'Opponent banned ${heroToBan.name}',
    ];

    notifyListeners();

    // Check if AI should ban more
    if (_aiEnemyBannedHeroes.length < _bansPerSide &&
        _playerBannedHeroes.length < _bansPerSide) {
      _isPlayerTurnToBan = true;
      notifyListeners();
    } else if (_aiEnemyBannedHeroes.length >= _bansPerSide &&
        _playerBannedHeroes.length >= _bansPerSide) {
      _checkIfBanningPhaseComplete();
    } else {
      // AI bans again if player hasn't filled quota
      _scheduleAiBan();
    }
  }

  void _checkIfBanningPhaseComplete() {
    if (_playerBannedHeroes.length >= _bansPerSide &&
        _aiEnemyBannedHeroes.length >= _bansPerSide) {
      _isInBanningPhase = false;
      _battleLog = <String>[
        ..._battleLog,
        'Banning phase complete! Starting battle...',
      ];
      notifyListeners();
    }
  }

  String _getHeroDisplayName(String heroName) {
    try {
      final hero = _availableHeroesForBanning
          .firstWhere((h) => h.name == heroName);
      return hero.name;
    } catch (e) {
      return heroName;
    }
  }

  void startBattle({
    required List<HeroModel> playerTeam,
    required List<HeroModel> aiTeam,
    int? playerStartingIndex,
    int? aiStartingIndex,
  }) {
    // Filter out banned heroes
    final filteredPlayerTeam = playerTeam
        .where((hero) => !_playerBannedHeroes.contains(hero.name))
        .take(5)
        .toList();
    final filteredAiTeam = aiTeam
        .where((hero) => !_aiEnemyBannedHeroes.contains(hero.name))
        .take(5)
        .toList();

    _playerTeam = filteredPlayerTeam;
    _aiTeam = filteredAiTeam;
    _playerTeamHp = _playerTeam.map((hero) => hero.maxHp).toList();
    _aiTeamHp = _aiTeam.map((hero) => hero.maxHp).toList();
    _playerSwitchCooldowns = List<int>.filled(_playerTeam.length, 0);
    _aiSwitchCooldowns = List<int>.filled(_aiTeam.length, 0);
    _playerActiveIndex = _resolveStartingIndex(
      hpValues: _playerTeamHp,
      requestedIndex: playerStartingIndex,
    );
    _aiActiveIndex = _resolveStartingIndex(
      hpValues: _aiTeamHp,
      requestedIndex: aiStartingIndex,
    );
    _round = 0;
    _lastPlayerDamage = 0;
    _lastAiDamage = 0;
    _isBattleOver = false;
    _playerWon = false;
    _roundWinner = null;
    _isInBanningPhase = false;
    _battleLog = <String>[
      'Team battle started: ${_teamLabel(_playerTeam)} vs ${_teamLabel(_aiTeam)}',
      'Tap a bench hero to switch before the next turn.',
    ];
    notifyListeners();
  }

  bool switchPlayerHero(int index) {
    if (_isBattleOver || !_isValidIndex(_playerTeam, index)) {
      return false;
    }
    if (_playerTeamHp[index] <= 0 || index == _playerActiveIndex) {
      return false;
    }
    if (_playerSwitchCooldowns[index] > 0) {
      return false;
    }

    final previousIndex = _playerActiveIndex;
    _playerActiveIndex = index;
    if (_isValidIndex(_playerTeam, previousIndex)) {
      _playerSwitchCooldowns[previousIndex] = _switchCooldownDurationSeconds;
    }
    _ensureSwitchCooldownTicker();
    _battleLog = <String>[
      ..._battleLog,
      'You switched to ${_playerTeam[index].name}.',
      '${_playerTeam[previousIndex].name} is on ${_switchCooldownDurationSeconds}s switch cooldown.',
      'Switching cost your action this round.',
    ];
    notifyListeners();
    return true;
  }

  Future<void> nextTurn() async {
    if (_isBattleOver || _playerTeam.isEmpty || _aiTeam.isEmpty) {
      return;
    }

    if (_playerActiveIndex < 0 || _playerTeamHp[_playerActiveIndex] <= 0) {
      _playerActiveIndex = _firstAliveIndex(_playerTeamHp);
    }
    if (_aiActiveIndex < 0 || _aiTeamHp[_aiActiveIndex] <= 0) {
      _aiActiveIndex = _firstAliveIndex(_aiTeamHp);
    }

    if (_playerActiveIndex < 0 || _aiActiveIndex < 0) {
      _finishBattle();
      return;
    }

    _aiStrategicSwitch();

    if (_playerActiveIndex < 0 || _aiActiveIndex < 0) {
      _finishBattle();
      return;
    }

    _round++;

    final playerHero = _playerTeam[_playerActiveIndex];
    final aiHero = _aiTeam[_aiActiveIndex];

    final result = BattleEngine.resolveTurn(
      round: _round,
      playerAttack: playerHero.attack,
      playerSpecialAttack: playerHero.specialAttack,
      playerDefense: playerHero.defense,
      aiAttack: aiHero.attack,
      aiSpecialAttack: aiHero.specialAttack,
      aiDefense: aiHero.defense,
    );

    _aiTeamHp[_aiActiveIndex] =
        (_aiTeamHp[_aiActiveIndex] - result.playerDamage).clamp(
          0,
          aiHero.maxHp,
        );
    _playerTeamHp[_playerActiveIndex] =
        (_playerTeamHp[_playerActiveIndex] - result.aiDamage).clamp(
          0,
          playerHero.maxHp,
        );
    _lastPlayerDamage = result.playerDamage;
    _lastAiDamage = result.aiDamage;

    if (result.playerDamage > result.aiDamage) {
      _roundWinner = playerHero.name;
    } else if (result.aiDamage > result.playerDamage) {
      _roundWinner = aiHero.name;
    } else {
      _roundWinner = null;
    }

    _battleLog = <String>[
      ..._battleLog,
      'Round $_round: You dealt ${result.playerDamage} with ${playerHero.name}',
      'Round $_round: Opponent dealt ${result.aiDamage} with ${aiHero.name}',
    ];

    if (_aiTeamHp[_aiActiveIndex] <= 0) {
      final nextAi = _nextAliveIndex(_aiTeamHp, fromIndex: _aiActiveIndex);
      if (nextAi != null) {
        _aiActiveIndex = nextAi;
        _battleLog = <String>[
          ..._battleLog,
          'Opponent switched to ${_aiTeam[_aiActiveIndex].name}.',
        ];
      }
    }

    if (_playerTeamHp[_playerActiveIndex] <= 0) {
      final nextPlayer = _nextAliveIndex(
        _playerTeamHp,
        fromIndex: _playerActiveIndex,
      );
      if (nextPlayer != null) {
        _playerActiveIndex = nextPlayer;
        _battleLog = <String>[
          ..._battleLog,
          'You auto-switched to ${_playerTeam[_playerActiveIndex].name}.',
        ];
      }
    }

    if (_aiAliveCount == 0 || _playerAliveCount == 0) {
      _finishBattle();
      return;
    }

    notifyListeners();
  }

  void reset({bool notify = true}) {
    _stopSwitchCooldownTicker();
    _playerTeam = <HeroModel>[];
    _aiTeam = <HeroModel>[];
    _playerTeamHp = <int>[];
    _aiTeamHp = <int>[];
    _playerSwitchCooldowns = <int>[];
    _aiSwitchCooldowns = <int>[];
    _playerActiveIndex = -1;
    _aiActiveIndex = -1;
    _lastPlayerDamage = 0;
    _lastAiDamage = 0;
    _round = 0;
    _isBattleOver = false;
    _playerWon = false;
    _roundWinner = null;
    _battleLog = <String>[];
    _isInBanningPhase = false;
    _availableHeroesForBanning = <HeroModel>[];
    _playerBannedHeroes = <String>{};
    _aiEnemyBannedHeroes = <String>{};
    _isPlayerTurnToBan = true;
    _banRound = 0;
    if (notify) {
      notifyListeners();
    }
  }

  void _finishBattle() {
    if (_isBattleOver) {
      return;
    }

    _stopSwitchCooldownTicker();

    _isBattleOver = true;
    _playerWon = _aiAliveCount == 0 && _playerAliveCount > 0;
    final finishedAt = DateTime.now();
    final mm = finishedAt.month.toString().padLeft(2, '0');
    final dd = finishedAt.day.toString().padLeft(2, '0');
    final hh = finishedAt.hour.toString().padLeft(2, '0');
    final min = finishedAt.minute.toString().padLeft(2, '0');
    final playedAtLabel = '${finishedAt.year}-$mm-$dd $hh:$min';
    _battleLog = <String>[
      ..._battleLog,
      _playerWon ? 'You won the battle!' : 'You lost the battle.',
      'Played at: $playedAtLabel',
    ];

    unawaited(
      DatabaseService().saveBattleRecord(
        BattleRecord(
          playerHero: _playerTeam.isEmpty ? 'Unknown' : _playerTeam.first.name,
          aiHero: _aiTeam.isEmpty ? 'Unknown' : _aiTeam.first.name,
          playerWon: _playerWon,
          roundsPlayed: _round,
          playedAt: finishedAt.toIso8601String(),
        ),
      ),
    );

    notifyListeners();
  }

  void _aiStrategicSwitch() {
    if (_aiActiveIndex < 0 || _aiActiveIndex >= _aiTeam.length) {
      return;
    }

    final currentHero = _aiTeam[_aiActiveIndex];
    final currentHp = _aiTeamHp[_aiActiveIndex];
    final threshold = (currentHero.maxHp * 0.35).ceil();
    final bestIndex = _bestAliveIndex(
      _aiTeam,
      _aiTeamHp,
      cooldowns: _aiSwitchCooldowns,
      excludeIndex: _aiActiveIndex,
    );
    if (bestIndex == null || currentHp > threshold) {
      return;
    }

    final currentScore = _heroScore(currentHero);
    final bestScore = _heroScore(_aiTeam[bestIndex]);
    if (bestScore <= currentScore) {
      return;
    }

    final previousIndex = _aiActiveIndex;
    _aiActiveIndex = bestIndex;
    if (_isValidIndex(_aiTeam, previousIndex)) {
      _aiSwitchCooldowns[previousIndex] = _switchCooldownDurationSeconds;
    }
    _ensureSwitchCooldownTicker();
    _battleLog = <String>[
      ..._battleLog,
      'Opponent switched to ${_aiTeam[_aiActiveIndex].name}.',
    ];
  }

  void _decrementSwitchCooldownsBySecond() {
    for (var i = 0; i < _playerSwitchCooldowns.length; i++) {
      if (_playerSwitchCooldowns[i] > 0) {
        _playerSwitchCooldowns[i]--;
      }
    }
    for (var i = 0; i < _aiSwitchCooldowns.length; i++) {
      if (_aiSwitchCooldowns[i] > 0) {
        _aiSwitchCooldowns[i]--;
      }
    }
  }

  bool get _hasActiveSwitchCooldown {
    for (final value in _playerSwitchCooldowns) {
      if (value > 0) {
        return true;
      }
    }
    for (final value in _aiSwitchCooldowns) {
      if (value > 0) {
        return true;
      }
    }
    return false;
  }

  void _ensureSwitchCooldownTicker() {
    if (_switchCooldownTicker != null) {
      return;
    }
    _switchCooldownTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_hasActiveSwitchCooldown || _isBattleOver) {
        _stopSwitchCooldownTicker();
        return;
      }

      _decrementSwitchCooldownsBySecond();
      notifyListeners();

      if (!_hasActiveSwitchCooldown) {
        _stopSwitchCooldownTicker();
      }
    });
  }

  void _stopSwitchCooldownTicker() {
    _switchCooldownTicker?.cancel();
    _switchCooldownTicker = null;
  }

  @override
  void dispose() {
    _stopSwitchCooldownTicker();
    super.dispose();
  }

  int _heroScore(HeroModel hero) {
    return hero.maxHp +
        hero.attack +
        hero.specialAttack +
        hero.defense +
        hero.initiative;
  }

  bool _isValidIndex(List<HeroModel> team, int index) =>
      index >= 0 && index < team.length;

  int _firstAliveIndex(List<int> hpValues) {
    for (var i = 0; i < hpValues.length; i++) {
      if (hpValues[i] > 0) {
        return i;
      }
    }
    return -1;
  }

  int _resolveStartingIndex({
    required List<int> hpValues,
    required int? requestedIndex,
  }) {
    if (requestedIndex != null &&
        requestedIndex >= 0 &&
        requestedIndex < hpValues.length &&
        hpValues[requestedIndex] > 0) {
      return requestedIndex;
    }
    return _firstAliveIndex(hpValues);
  }

  int? _nextAliveIndex(List<int> hpValues, {required int fromIndex}) {
    if (hpValues.isEmpty) {
      return null;
    }

    for (var offset = 1; offset <= hpValues.length; offset++) {
      final index = (fromIndex + offset) % hpValues.length;
      if (hpValues[index] > 0) {
        return index;
      }
    }

    return null;
  }

  int? _bestAliveIndex(
    List<HeroModel> team,
    List<int> hpValues, {
    required List<int> cooldowns,
    required int excludeIndex,
  }) {
    int? bestIndex;
    var bestScore = -1;
    for (var i = 0; i < team.length; i++) {
      if (i == excludeIndex || hpValues[i] <= 0 || cooldowns[i] > 0) {
        continue;
      }

      final score = _heroScore(team[i]);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    return bestIndex;
  }

  HeroModel? _activeHero(List<HeroModel> team, int index) {
    if (!_isValidIndex(team, index)) {
      return null;
    }
    return team[index];
  }

  List<HeroModel> _heroesFromNames(Set<String> names) {
    return _availableHeroesForBanning
        .where((hero) => names.contains(hero.name))
        .toList();
  }

  int _activeHp(List<int> hpValues, int index) {
    if (index < 0 || index >= hpValues.length) {
      return 0;
    }
    return hpValues[index];
  }

  String _teamLabel(List<HeroModel> team) {
    return team.map((hero) => hero.name).join(', ');
  }
}
