import 'dart:math';

import 'package:flutter/foundation.dart';
import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';
import '../services/superhero_api_service.dart';

enum HeroAnimationState { normal, defeated, exiting, entering }

class BattleProvider extends ChangeNotifier {
  final SuperheroApiService _heroService = SuperheroApiService();

  List<HeroModel> _playerTeam = [];
  List<HeroModel> _aiTeam = [];
  List<HeroModel> _originalPlayerTeam = []; // Store original teams
  List<HeroModel> _originalAiTeam = []; // Store original teams
  HeroModel? _currentPlayerHero;
  HeroModel? _currentAiHero;
  int _currentPlayerHp = 0;
  int _currentAiHp = 0;
  int _roundsPlayed = 0;
  bool _battleInProgress = false;
  String _battleLog = '';
  bool _choosingHero = false;
  String _backgroundUrl = '';
  String _aiOpponentName = 'AI Opponent';
  HeroAnimationState _playerAnimationState = HeroAnimationState.normal;
  HeroAnimationState _aiAnimationState = HeroAnimationState.normal;
  String? _winner;

  List<HeroModel> get playerTeam => _playerTeam;
  List<HeroModel> get aiTeam => _aiTeam;
  HeroModel? get currentPlayerHero => _currentPlayerHero;
  HeroModel? get currentAiHero => _currentAiHero;
  int get currentPlayerHp => _currentPlayerHp;
  int get currentAiHp => _currentAiHp;
  int get roundsPlayed => _roundsPlayed;
  bool get battleInProgress => _battleInProgress;
  String get battleLog => _battleLog;
  bool get choosingHero => _choosingHero;
  String get backgroundUrl => _backgroundUrl;
  String get aiOpponentName => _aiOpponentName;
  HeroAnimationState get playerAnimationState => _playerAnimationState;
  HeroAnimationState get aiAnimationState => _aiAnimationState;
  String? get winner => _winner;

  Future<void> initializeBattle(List<HeroModel> playerTeam) async {
    _playerTeam = List.from(playerTeam);
    _originalPlayerTeam = List.from(playerTeam); // Store original player team
    _aiTeam = [];

    // Fetch all AI heroes concurrently
    final futures = List.generate(
      5,
      (_) => _heroService.fetchRandomHeroes(count: 1),
    );
    final results = await Future.wait(futures);

    for (final heroes in results) {
      if (heroes.isNotEmpty) {
        _aiTeam.add(heroes.first);
      }
    }

    // Ensure we have exactly 5 AI heroes
    while (_aiTeam.length < 5) {
      final heroes = await _heroService.fetchRandomHeroes(count: 1);
      if (heroes.isNotEmpty) {
        _aiTeam.add(heroes.first);
      }
    }

    _originalAiTeam = List.from(_aiTeam); // Store original AI team

    // Player selects first hero, for now auto-select first
    _currentPlayerHero = _playerTeam.isNotEmpty ? _playerTeam[0] : null;
    _currentAiHero = _aiTeam.isNotEmpty ? _aiTeam[0] : null;
    _currentPlayerHp = _currentPlayerHero?.maxHp ?? 0;
    _currentAiHp = _currentAiHero?.maxHp ?? 0;
    _roundsPlayed = 0;
    _battleInProgress = true;
    _choosingHero = false;
    _playerAnimationState = HeroAnimationState.normal;
    _aiAnimationState = HeroAnimationState.normal;
    _aiOpponentName = _getRandomOpponentName();
    _battleLog = 'Battle started! Player team vs $_aiOpponentName\'s force\n';
    _battleLog += 'Round 1 begins...\n';
    _backgroundUrl = await _fetchRandomBackground();
    _winner = null;
    notifyListeners();
  }

  Future<String> _fetchRandomBackground() async {
    // Use the specified Pinterest image URL as permanent battle field background
    return 'https://i.pinimg.com/736x/37/72/e5/3772e5f2c9d0bdeb64deb0837067dd49.jpg';
  }

  String _getRandomOpponentName() {
    const names = [
      'The Marauder',
      'Night Stalker',
      'Shadow Titan',
      'Storm Sentinel',
      'Iron Warden',
      'Void Reaper',
      'Celestial Fury',
      'Rogue Specter',
      'Thunder Judge',
      'Phantom Commander',
    ];
    return names[Random().nextInt(names.length)];
  }

  void selectPlayerHero(HeroModel hero) {
    if (_playerTeam.contains(hero) && hero != _currentPlayerHero) {
      _currentPlayerHero = hero;
      _currentPlayerHp = hero.maxHp;
      _choosingHero = false;
      _playerAnimationState = HeroAnimationState.entering;
      _battleLog += 'Player deploys ${hero.name} with ${hero.maxHp} HP!\n';
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () {
        _playerAnimationState = HeroAnimationState.normal;
        notifyListeners();
      });
    }
  }

  void startBattle() {
    // This is now initializeBattle
  }

  void fightRound() {
    if (!_battleInProgress ||
        _currentPlayerHero == null ||
        _currentAiHero == null ||
        _choosingHero) {
      return;
    }

    final result = BattleEngine.simulateRound(
      _currentPlayerHero!,
      _currentAiHero!,
      _currentPlayerHp,
      _currentAiHp,
    );

    _battleLog += 'Round ${_roundsPlayed + 1}: ${_currentPlayerHero!.name} vs ${_currentAiHero!.name}\n';
    _battleLog += BattleEngine.getAttackDescription(
      true,
      _currentPlayerHero!.name,
      _currentAiHero!.name,
      result.playerHit,
      result.playerDamage,
    );
    if (result.playerHit) {
      _battleLog +=
          ' ${_currentAiHero!.name} has ${
              (_currentAiHp - result.playerDamage).clamp(0, _currentAiHero!.maxHp)
            } HP remaining.';
    }
    _battleLog += '\n';
    _battleLog += BattleEngine.getAttackDescription(
      false,
      _currentAiHero!.name,
      _currentPlayerHero!.name,
      result.aiHit,
      result.aiDamage,
    );
    if (result.aiHit) {
      _battleLog +=
          ' ${_currentPlayerHero!.name} has ${
              (_currentPlayerHp - result.aiDamage).clamp(0, _currentPlayerHero!.maxHp)
            } HP remaining.';
    }
    _battleLog += '\n';

    _currentPlayerHp = (_currentPlayerHp - result.aiDamage).clamp(
      0,
      _currentPlayerHero!.maxHp,
    );
    _currentAiHp = (_currentAiHp - result.playerDamage).clamp(
      0,
      _currentAiHero!.maxHp,
    );
    _roundsPlayed++;

    final playerDefeated = _currentPlayerHp == 0;
    final aiDefeated = _currentAiHp == 0;

    if (playerDefeated && aiDefeated) {
      _battleLog +=
          '${_currentPlayerHero!.name} and ${_currentAiHero!.name} have both been defeated!\n';
      _playerAnimationState = HeroAnimationState.defeated;
      _aiAnimationState = HeroAnimationState.defeated;
      _playerTeam.remove(_currentPlayerHero);
      _aiTeam.remove(_currentAiHero);
      notifyListeners();

      Future.delayed(const Duration(seconds: 1), () {
        _playerAnimationState = HeroAnimationState.exiting;
        _aiAnimationState = HeroAnimationState.exiting;
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (_playerTeam.isEmpty && _aiTeam.isEmpty) {
            _battleLog += 'Both teams eliminated! The battle ends in a draw.\n';
            _battleInProgress = false;
            _winner = 'draw';
            notifyListeners();
            endBattle(null);
            return;
          }

          if (_playerTeam.isEmpty) {
            _battleLog += 'All player heroes defeated! AI wins!\n';
            _battleInProgress = false;
            _winner = 'ai';
            notifyListeners();
            endBattle(false);
            return;
          }

          if (_aiTeam.isEmpty) {
            _battleLog += 'All AI heroes defeated! Player wins!\n';
            _battleInProgress = false;
            _winner = 'player';
            notifyListeners();
            endBattle(true);
            return;
          }

          _choosingHero = true;
          _currentPlayerHero = null;

          _currentAiHero = _aiTeam[Random().nextInt(_aiTeam.length)];
          _currentAiHp = _currentAiHero!.maxHp;
          _battleLog += 'AI switched to ${_currentAiHero!.name}\n';
          _aiAnimationState = HeroAnimationState.entering;
          notifyListeners();

          Future.delayed(const Duration(milliseconds: 500), () {
            _aiAnimationState = HeroAnimationState.normal;
            notifyListeners();
          });
        });
      });
      return;
    }

    if (playerDefeated) {
      _battleLog += '${_currentPlayerHero!.name} has been defeated!\n';
      _playerTeam.remove(_currentPlayerHero);
      _playerAnimationState = HeroAnimationState.defeated;
      notifyListeners();
      // After defeat animation, set to exiting
      Future.delayed(const Duration(seconds: 1), () {
        _playerAnimationState = HeroAnimationState.exiting;
        notifyListeners();
      });
      if (_playerTeam.isEmpty) {
        _battleLog += 'All player heroes defeated! AI wins!\n';
        _battleInProgress = false;
        _winner = 'ai';
        notifyListeners();
        endBattle(false);
        return;
      } else {
        _choosingHero = true;
        _currentPlayerHero = null;
        _battleLog += 'Choose a new hero to keep the fight alive.\n';
        notifyListeners();
        return;
      }
    }

    if (aiDefeated) {
      _battleLog += '${_currentAiHero!.name} has been defeated!\n';
      _aiTeam.remove(_currentAiHero);
      _aiAnimationState = HeroAnimationState.defeated;
      notifyListeners();
      // After defeat, set to exiting, then switch to new hero with entering
      Future.delayed(const Duration(seconds: 1), () {
        _aiAnimationState = HeroAnimationState.exiting;
        notifyListeners();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_aiTeam.isEmpty) {
            _battleLog += 'All AI heroes defeated! Player wins!\n';
            _battleInProgress = false;
            _winner = 'player';
            notifyListeners();
            endBattle(true);
            return;
          } else {
            // AI randomly selects next hero
            _currentAiHero = _aiTeam[Random().nextInt(_aiTeam.length)];
            _currentAiHp = _currentAiHero!.maxHp;
            _battleLog += 'AI switched to ${_currentAiHero!.name}\n';
            _aiAnimationState = HeroAnimationState.entering;
            notifyListeners();
            Future.delayed(const Duration(milliseconds: 500), () {
              _aiAnimationState = HeroAnimationState.normal;
              notifyListeners();
            });
          }
        });
      });
    }

    notifyListeners();
  }

  void endBattle(bool? playerWon) async {
    _battleInProgress = false;

    if (_currentPlayerHero != null &&
        _currentAiHero != null &&
        playerWon != null) {
      final record = BattleRecord(
        playerHero: _currentPlayerHero!.name,
        aiHero: _currentAiHero!.name,
        playerTeam: _originalPlayerTeam, // Save original teams
        aiTeam: _originalAiTeam, // Save original teams
        playerWon: playerWon,
        roundsPlayed: _roundsPlayed,
        playedAt: DateTime.now().toIso8601String(),
      );
      await DatabaseService().saveBattleRecord(record);
    }
  }

  void clearBattle() {
    _playerTeam.clear();
    _aiTeam.clear();
    _originalPlayerTeam.clear(); // Clear original teams
    _originalAiTeam.clear(); // Clear original teams
    _currentPlayerHero = null;
    _currentAiHero = null;
    _currentPlayerHp = 0;
    _currentAiHp = 0;
    _roundsPlayed = 0;
    _battleInProgress = false;
    _choosingHero = false;
    _playerAnimationState = HeroAnimationState.normal;
    _aiAnimationState = HeroAnimationState.normal;
    _battleLog = '';
    _backgroundUrl = '';
    _winner = null;
    notifyListeners();
  }

  void addBattleLog(String message) {
    _battleLog += '$message\n';
    notifyListeners();
  }
}
