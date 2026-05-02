import 'package:flutter/foundation.dart';
import '../models/hero_model.dart';
import '../models/battle_record.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<HeroModel> _playerDeck = [];
  HeroModel? _playerHero;
  HeroModel? _aiHero;
  int _playerHp = 0;
  int _aiHp = 0;
  int _round = 0;
  bool _battleOver = false;
  bool _playerWon = false;
  String _battleLog = '';
  String _winnerText = '';
  static const int minRounds = 3;

  // Bench heroes and HP preservation
  List<HeroModel> _benchHeroes = [];
  final Map<String, int> _heroHpMap = {}; // Maps hero.id to current HP
  
  // Turn-based battle logs
  final List<String> _battleLogs = [];

  List<HeroModel> get playerDeck => _playerDeck;
  HeroModel? get playerHero => _playerHero;
  HeroModel? get aiHero => _aiHero;
  int get playerHp => _playerHp;
  int get aiHp => _aiHp;
  bool get playerWon => _playerWon;
  int get round => _round;
  bool get battleOver => _battleOver;
  String get battleLog => _battleLog;
  List<HeroModel> get benchHeroes => _benchHeroes;
  List<String> get battleLogs => List.unmodifiable(_battleLogs);
  String get winnerText => _winnerText;

  void setPlayerDeck(List<HeroModel> deck) {
    _playerDeck = deck;
    notifyListeners();
  }

  void startBattle(HeroModel player, HeroModel ai, List<HeroModel> deck) {
    _playerHero = player;
    _aiHero = ai;
    _playerDeck = deck;
    _playerHp = player.maxHp;
    _aiHp = ai.maxHp;
    _round = 0;
    _battleOver = false;
    _playerWon = false;
    _battleLog = 'Battle starts: ${player.name} vs ${ai.name}!\n';
    _winnerText = '';
    
    // Initialize battle logs
    _battleLogs.clear();
    _battleLogs.add('Battle starts: ${player.name} vs ${ai.name}!');
    
    // Initialize bench heroes (deck excluding active player)
    _benchHeroes = deck.where((h) => h.id != player.id).toList();
    
    // Initialize HP map
    _heroHpMap.clear();
    _heroHpMap[player.id] = player.maxHp;
    for (final hero in _benchHeroes) {
      _heroHpMap[hero.id] = hero.maxHp;
    }
    
    notifyListeners();
  }

  Future<void> playRound() async {
    if (_battleOver) return;
    _round++;

    // Both sides attack - player vs AI combat
    // Add randomness to initiative: 20% chance to reverse turn order
    final initiativeDiff = _playerHero!.initiative - _aiHero!.initiative;
    final playerFirst = initiativeDiff >= 0 && (DateTime.now().millisecondsSinceEpoch % 5 != 0);

    if (playerFirst) {
      _attack(attacker: _playerHero!, defender: _aiHero!, isPlayer: true);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_battleOver) {
        _attack(attacker: _aiHero!, defender: _playerHero!, isPlayer: false);
        notifyListeners();
      }
    } else {
      _attack(attacker: _aiHero!, defender: _playerHero!, isPlayer: false);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 800));
      if (!_battleOver) {
        _attack(attacker: _playerHero!, defender: _aiHero!, isPlayer: true);
        notifyListeners();
      }
    }
  }

  void swapActiveHero(HeroModel newHero) {
    if (_battleOver || _playerHero == null) return;
    
    // Preserve current hero's HP
    _heroHpMap[_playerHero!.id] = _playerHp;
    
    // Move old hero to bench
    _benchHeroes.add(_playerHero!);
    _benchHeroes.remove(newHero);
    
    // Set new hero and restore its HP
    _playerHero = newHero;
    _playerHp = _heroHpMap[newHero.id] ?? newHero.maxHp;
    
    final swapLog = '${newHero.name} swapped in! HP: $_playerHp';
    _battleLog += '$swapLog\n';
    _battleLogs.add(swapLog);
    
    // AI attacks immediately (costs player's turn)
    _attack(attacker: _aiHero!, defender: _playerHero!, isPlayer: false);
    
    notifyListeners();
  }

  void _attack({
    required HeroModel attacker,
    required HeroModel defender,
    required bool isPlayer,
  }) {
    final baseDamage = (attacker.attack - defender.defense).clamp(1, attacker.attack);
    final isSpecial = _round % 3 == 0;
    
    // Add randomness: 15% variance in damage
    final variance = (baseDamage * 0.15).toInt();
    final randomVariance = (DateTime.now().millisecondsSinceEpoch % (variance * 2 + 1)) - variance;
    var actualDamage = baseDamage + randomVariance;
    
    // 10% chance for critical hit (double damage)
    final isCritical = DateTime.now().millisecondsSinceEpoch % 10 == 0;
    if (isCritical) {
      actualDamage *= 2;
    }
    
    // Add special attack bonus
    if (isSpecial) {
      actualDamage += attacker.specialAttack ~/ 2;
    }
    
    // Ensure minimum damage of 1
    actualDamage = actualDamage.clamp(1, actualDamage);

    if (isPlayer) {
      _aiHp = (_aiHp - actualDamage).clamp(0, _aiHp - actualDamage > 0 ? _aiHp - actualDamage : 0);
      if (_aiHp < 0) _aiHp = 0;
      final logEntry = 'R$_round: ${attacker.name} ${isCritical ? "CRITICAL " : ""}${isSpecial ? "SPECIAL" : "attacks"} for $actualDamage dmg! AI HP: $_aiHp';
      _battleLog += '$logEntry\n';
      _battleLogs.add(logEntry);
      // End battle immediately when HP reaches 0
      if (_aiHp <= 0) {
        _battleOver = true;
        _playerWon = true;
        _winnerText = '${_playerHero!.name} Wins!';
        final winLog = '${_playerHero!.name} wins!';
        _battleLog += '$winLog\n';
        _battleLogs.add(winLog);
        _saveRecord();
      }
    } else {
      _playerHp = (_playerHp - actualDamage).clamp(0, _playerHp);
      if (_playerHp < 0) _playerHp = 0;
      final logEntry = 'R$_round: ${attacker.name} ${isCritical ? "CRITICAL " : ""}${isSpecial ? "SPECIAL" : "attacks"} for $actualDamage dmg! Player HP: $_playerHp';
      _battleLog += '$logEntry\n';
      _battleLogs.add(logEntry);
      // End battle immediately when HP reaches 0
      if (_playerHp <= 0) {
        _battleOver = true;
        _playerWon = false;
        _winnerText = '${_aiHero!.name} Wins!';
        final winLog = '${_aiHero!.name} wins!';
        _battleLog += '$winLog\n';
        _battleLogs.add(winLog);
        _saveRecord();
      }
    }
  }

  Future<void> _saveRecord() async {
    final record = BattleRecord(
      playerHero: _playerHero!.name,
      aiHero: _aiHero!.name,
      playerWon: _playerWon,
      roundsPlayed: _round,
      playedAt: DateTime.now().toIso8601String(),
    );
    await _db.saveBattleRecord(record);
  }

  void resetBattle() {
    _playerHero = null;
    _aiHero = null;
    _playerHp = 0;
    _aiHp = 0;
    _round = 0;
    _battleOver = false;
    _playerWon = false;
    _battleLog = '';
    _winnerText = '';
    _battleLogs.clear();
    _benchHeroes.clear();
    _heroHpMap.clear();
    notifyListeners();
  }

  void restartBattle() {
    if (_playerHero == null || _aiHero == null) return;
    _playerHp = _playerHero!.maxHp;
    _aiHp = _aiHero!.maxHp;
    _round = 0;
    _battleOver = false;
    _playerWon = false;
    _battleLog = 'Battle restarts: ${_playerHero!.name} vs ${_aiHero!.name}!\n';
    _winnerText = '';
    _battleLogs.clear();
    _battleLogs.add('Battle restarts: ${_playerHero!.name} vs ${_aiHero!.name}!');
    
    // Reset HP for all heroes
    _heroHpMap[_playerHero!.id] = _playerHero!.maxHp;
    for (final hero in _benchHeroes) {
      _heroHpMap[hero.id] = hero.maxHp;
    }
    
    notifyListeners();
  }
}
