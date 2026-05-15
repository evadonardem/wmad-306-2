import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';
import '../engine/battle_engine.dart';

class BattleLog {
  final String text;
  final String? actorName;
  final String? actionName;
  final bool? isPlayerActor;

  BattleLog(this.text, {this.actorName, this.actionName, this.isPlayerActor});
}

class BattleProvider extends ChangeNotifier {
  List<HeroModel> _playerDeck = [];
  List<HeroModel> _aiDeck = [];
  final Set<int> _faintedPlayerIndices = {};
  final Set<int> _faintedAiIndices = {};
  String? _aiName;

  int _currentPlayerIndex = -1;
  int _currentAiIndex = -1;

  int _playerHp = 0;
  int _aiHp = 0;

  bool _isPlayerTurn = true;
  bool _isAwaitingSwitch = false;
  final List<BattleLog> _logs = [];
  bool _isGameOver = false;
  String? _winner;

  // Getters
  HeroModel? get playerHero => (_currentPlayerIndex != -1 && _currentPlayerIndex < _playerDeck.length) 
      ? _playerDeck[_currentPlayerIndex] : null;
  HeroModel? get aiHero => (_currentAiIndex != -1 && _currentAiIndex < _aiDeck.length) 
      ? _aiDeck[_currentAiIndex] : null;
  
  List<HeroModel> get playerDeck => _playerDeck;
  List<HeroModel> get aiDeck => _aiDeck;
  Set<int> get faintedPlayerIndices => _faintedPlayerIndices;
  Set<int> get faintedAiIndices => _faintedAiIndices;
  int get currentPlayerIndex => _currentPlayerIndex;
  int get currentAiIndex => _currentAiIndex;

  String? get aiName => _aiName;
  int get playerHp => _playerHp;
  int get aiHp => _aiHp;
  bool get isPlayerTurn => _isPlayerTurn;
  bool get isAwaitingSwitch => _isAwaitingSwitch;
  List<BattleLog> get logs => List.unmodifiable(_logs);
  bool get isGameOver => _isGameOver;
  String? get winner => _winner;

  bool _isIntroActive = false;
  bool get isIntroActive => _isIntroActive;

  /// Transitions from intro to active battle.
  /// If AI has initiative (lower speed), its turn is automatically queued.
  void setIntroActive(bool active) {
    _isIntroActive = active;
    notifyListeners();

    if (!active && !_isPlayerTurn && !_isGameOver && !isAwaitingSwitch) {
      Future.delayed(const Duration(milliseconds: 1500), () => aiTurn());
    }
  }

  void reset() {
    _playerDeck = [];
    _aiDeck = [];
    _faintedPlayerIndices.clear();
    _faintedAiIndices.clear();
    _currentPlayerIndex = -1;
    _currentAiIndex = -1;
    _playerHp = 0;
    _aiHp = 0;
    _logs.clear();
    _isGameOver = false;
    _winner = null;
    _isIntroActive = false;
    _isAwaitingSwitch = false;
    notifyListeners();
  }

  /// Initializes decks and determines initial initiative based on speed stats.
  void startBattle(List<HeroModel> playerDeck, List<HeroModel> allHeroes, int startingIndex) {
    reset();
    _playerDeck = List.from(playerDeck);
    _aiDeck = _generateAiDeck(allHeroes);

    final aiNames = [
      'The Annihilator', 'Shadow Stalker', 'Cyber Phantom', 'Crimson Fury',
      'Void Harbinger', 'Iron Sovereign', 'Midnight Marauder', 'Solar Flare',
      'Quantum Ghost', 'Titan Prime', 'Frost Bite', 'Storm Weaver'
    ];
    _aiName = aiNames[Random().nextInt(aiNames.length)];

    _currentPlayerIndex = startingIndex;
    _currentAiIndex = 0;
    
    _deployNewPlayerHero();
    _deployNewAiHero();

    _isGameOver = false;
    _logs.add(BattleLog('BATTLE COMMENCED!'));
    _logs.add(BattleLog('Player vs $_aiName'));

    _determineTurnOrder();
    notifyListeners();
  }

  /// Selects a balanced AI roster within the 15-cost constraint.
  List<HeroModel> _generateAiDeck(List<HeroModel> allHeroes) {
    List<HeroModel> deck = [];
    int totalCost = 0;
    final random = Random();
    List<HeroModel> pool = List.from(allHeroes)..shuffle(random);
    
    for (var hero in pool) {
      if (totalCost + hero.cost <= 15) {
        deck.add(hero);
        totalCost += hero.cost;
      }
      if (totalCost >= 13 || deck.length >= 5) break; 
    }
    return deck;
  }

  void _deployNewPlayerHero() {
    if (_currentPlayerIndex != -1) {
      _playerHp = _playerDeck[_currentPlayerIndex].maxHp;
      _isAwaitingSwitch = false;
    }
  }

  void _deployNewAiHero() {
    if (_currentAiIndex != -1) {
      _aiHp = _aiDeck[_currentAiIndex].maxHp;
    }
  }

  void _determineTurnOrder() {
    final p = playerHero;
    final a = aiHero;
    if (p == null || a == null) return;

    _isPlayerTurn = p.initiative >= a.initiative;
    _logs.add(BattleLog(
      _isPlayerTurn 
        ? '${p.name} is faster! Your turn.' 
        : '$_aiName is faster! AI turn.'
    ));
  }

  /// Calculates damage, handles fainted states, and manages turn transitions for the player.
  void executeMove(String moveType) {
    if (_isGameOver || !_isPlayerTurn || _isAwaitingSwitch || playerHero == null || aiHero == null) return;

    final result = BattleEngine.calculateDamage(playerHero!, aiHero!, moveType);
    _aiHp = max(0, _aiHp - result.damage);

    _logs.add(BattleLog(
      '${playerHero!.name} uses ${result.moveName}! Deals ${result.damage} damage.',
      actorName: playerHero!.name,
      actionName: result.moveName,
      isPlayerActor: true,
    ));

    if (_aiHp <= 0) {
      _logs.add(BattleLog('${aiHero!.name} has fainted!'));
      _faintedAiIndices.add(_currentAiIndex);
      
      int nextIdx = -1;
      for (int i = 0; i < _aiDeck.length; i++) {
        if (!_faintedAiIndices.contains(i)) {
          nextIdx = i;
          break;
        }
      }

      if (nextIdx != -1) {
        _currentAiIndex = nextIdx;
        _deployNewAiHero();
        _logs.add(BattleLog('$_aiName deploys ${aiHero!.name}!'));
        _determineTurnOrder();
      } else {
        _endGame(playerHero!.name);
      }
    } else {
      _isPlayerTurn = false;
    }

    notifyListeners();
  }

  /// AI decision-making loop. Randomly selects moves and handles player knockout logic.
  void aiTurn() {
    if (_isGameOver || _isPlayerTurn || _isAwaitingSwitch || aiHero == null || playerHero == null) return;

    final moveType = BattleEngine.getRandomMove();
    final result = BattleEngine.calculateDamage(aiHero!, playerHero!, moveType);
    _playerHp = max(0, _playerHp - result.damage);

    _logs.add(BattleLog(
      '${aiHero!.name} uses ${result.moveName}! Deals ${result.damage} damage.',
      actorName: aiHero!.name,
      actionName: result.moveName,
      isPlayerActor: false,
    ));

    if (_playerHp <= 0) {
      _logs.add(BattleLog('${playerHero!.name} has fainted!'));
      _faintedPlayerIndices.add(_currentPlayerIndex);
      
      bool hasSurvivors = false;
      for (int i = 0; i < _playerDeck.length; i++) {
        if (!_faintedPlayerIndices.contains(i)) {
          hasSurvivors = true;
          break;
        }
      }

      if (hasSurvivors) {
        _isAwaitingSwitch = true;
        _logs.add(BattleLog('Choose your next hero!'));
      } else {
        _endGame(_aiName!);
      }
    } else {
      _isPlayerTurn = true;
    }

    notifyListeners();
  }

  void switchHero(int newIndex) {
    if (_isGameOver || newIndex == _currentPlayerIndex || _faintedPlayerIndices.contains(newIndex)) return;
    
    final oldHero = playerHero;
    _currentPlayerIndex = newIndex;
    _deployNewPlayerHero();
    
    if (oldHero != null && _playerHp > 0) {
      _logs.add(BattleLog(
        '${oldHero.name} retreats! Go, ${playerHero!.name}!',
        actorName: oldHero.name,
        actionName: 'Retreat',
        isPlayerActor: true,
      ));
    } else {
      _logs.add(BattleLog('Go, ${playerHero!.name}!'));
    }
    
    _isPlayerTurn = false;
    notifyListeners();
  }

  void _endGame(String winnerName) {
    _isGameOver = true;
    _winner = winnerName;
    _logs.add(BattleLog('GAME OVER! $winnerName is the winner!'));
    _saveResult();
    notifyListeners();
  }

  /// Persists full deck snapshots and outcomes to history.
  Future<void> _saveResult() async {
    if (_playerDeck.isEmpty || _aiDeck.isEmpty) return;
    
    final playerImages = jsonEncode(_playerDeck.map((h) => h.imageUrl).toList());
    final aiImages = jsonEncode(_aiDeck.map((h) => h.imageUrl).toList());
    final playerJson = jsonEncode(_playerDeck.map((h) => h.toJson()).toList());
    final aiJson = jsonEncode(_aiDeck.map((h) => h.toJson()).toList());

    final record = BattleRecord(
      playerHero: _playerHeroAtEnd(),
      aiHero: _aiHeroAtEnd(),
      aiName: _aiName,
      playerWon: _winner != _aiName,
      roundsPlayed: (_logs.length / 2).floor(),
      playedAt: DateTime.now().toIso8601String(),
      playerDeckImages: playerImages,
      aiDeckImages: aiImages,
      playerDeckJson: playerJson,
      aiDeckJson: aiJson,
    );
    await DatabaseService().saveBattleRecord(record);
  }

  String _playerHeroAtEnd() {
    if (_currentPlayerIndex != -1 && _currentPlayerIndex < _playerDeck.length) {
      return _playerDeck[_currentPlayerIndex].name;
    }
    return _playerDeck[0].name;
  }

  String _aiHeroAtEnd() {
    if (_currentAiIndex != -1 && _currentAiIndex < _aiDeck.length) {
      return _aiDeck[_currentAiIndex].name;
    }
    return _aiDeck[0].name;
  }
}
