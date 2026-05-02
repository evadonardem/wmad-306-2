import 'dart:async';

import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
  HeroModel? _playerHero;
  HeroModel? _aiHero;
  int _playerHp = 0;
  int _aiHp = 0;
  int _playerMana = 0;
  int _aiMana = 0;
  int _round = 0;
  bool _isBattleOver = false;
  bool _playerWon = false;
  List<String> _battleLog = <String>[];
  String? _roundWinner;
  int? _lastPlayerDamage;
  int? _lastAiDamage;
  bool _playerCritical = false;
  bool _aiCritical = false;
  HeroSkill? _selectedSkill;

  HeroModel? get playerHero => _playerHero;
  HeroModel? get aiHero => _aiHero;
  int get playerHp => _playerHp;
  int get aiHp => _aiHp;
  int get playerMana => _playerMana;
  int get aiMana => _aiMana;
  int get round => _round;
  bool get isBattleOver => _isBattleOver;
  bool get playerWon => _playerWon;
  List<String> get battleLog => List.unmodifiable(_battleLog);
  String? get roundWinner => _roundWinner;
  int? get lastPlayerDamage => _lastPlayerDamage;
  int? get lastAiDamage => _lastAiDamage;
  bool get playerCritical => _playerCritical;
  bool get aiCritical => _aiCritical;
  HeroSkill? get selectedSkill => _selectedSkill;

  void startBattle({required HeroModel playerHero, required HeroModel aiHero}) {
    _playerHero = playerHero;
    _aiHero = aiHero;
    _playerHp = playerHero.maxHp;
    _aiHp = aiHero.maxHp;
    _playerMana = playerHero.maxMana;
    _aiMana = aiHero.maxMana;
    _round = 0;
    _isBattleOver = false;
    _playerWon = false;
    _roundWinner = null;
    _lastPlayerDamage = null;
    _lastAiDamage = null;
    _playerCritical = false;
    _aiCritical = false;
    _selectedSkill = null;
    _battleLog = <String>[
      'Battle started: ${playerHero.name} vs ${aiHero.name}',
    ];
    notifyListeners();
  }

  Future<void> nextTurn() async {
    if (_isBattleOver || _playerHero == null || _aiHero == null) {
      return;
    }

    _round++;

    final playerSkill = _selectedSkill;
    HeroSkill aiSkill = _aiHero!.skills.firstWhere(
      (skill) => skill.manaCost <= _aiMana,
      orElse: () => _aiHero!.skills.first,
    );

    final canUsePlayerSkill = playerSkill != null && playerSkill.manaCost <= _playerMana;
    final usedPlayerSkill = canUsePlayerSkill ? playerSkill : null;
    if (playerSkill != null && !canUsePlayerSkill) {
      _battleLog = <String>[
        ..._battleLog,
        '${_playerHero!.name} tried to use ${playerSkill.name} but did not have enough mana.',
      ];
    }

    final result = BattleEngine.resolveTurn(
      round: _round,
      playerAttack: _playerHero!.attack,
      playerSpecialAttack: _playerHero!.specialAttack,
      playerDefense: _playerHero!.defense,
      aiAttack: _aiHero!.attack,
      aiSpecialAttack: _aiHero!.specialAttack,
      aiDefense: _aiHero!.defense,
      playerSkill: usedPlayerSkill,
      aiSkill: aiSkill,
    );

    if (usedPlayerSkill != null) {
      _playerMana = (_playerMana - usedPlayerSkill.manaCost).clamp(0, _playerHero!.maxMana);
    }
    if (aiSkill.manaCost <= _aiMana) {
      _aiMana = (_aiMana - aiSkill.manaCost).clamp(0, _aiHero!.maxMana);
    }

    _aiHp = (_aiHp - result.playerDamage).clamp(0, _aiHero!.maxHp);
    _playerHp = (_playerHp - result.aiDamage).clamp(0, _playerHero!.maxHp);
    _lastPlayerDamage = result.playerDamage;
    _lastAiDamage = result.aiDamage;
    _playerCritical = result.playerCritical;
    _aiCritical = result.aiCritical;

    if (result.playerDamage > result.aiDamage) {
      _roundWinner = _playerHero!.name;
    } else if (result.aiDamage > result.playerDamage) {
      _roundWinner = _aiHero!.name;
    } else {
      _roundWinner = null;
    }

    _battleLog = <String>[
      ..._battleLog,
      'Round $_round: ${_playerHero!.name}${usedPlayerSkill != null ? ' used ${usedPlayerSkill.name}' : ''} and dealt ${result.playerDamage}${result.playerCritical ? ' (CRITICAL)' : ''}',
      'Round $_round: ${_aiHero!.name} used ${aiSkill.name} and dealt ${result.aiDamage}${result.aiCritical ? ' (CRITICAL)' : ''}',
      'Round $_round: Damage taken — you ${result.aiDamage}, enemy ${result.playerDamage}',
    ];

    if (_playerHp <= 0 || _aiHp <= 0) {
      _isBattleOver = true;
      _playerWon = _aiHp <= 0 && _playerHp > 0;
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
            playerHero: _playerHero!.name,
            aiHero: _aiHero!.name,
            playerWon: _playerWon,
            roundsPlayed: _round,
            playedAt: finishedAt.toIso8601String(),
          ),
        ),
      );
    }

    notifyListeners();
  }

  void switchHero(HeroModel newHero, int newHp) {
    final oldHero = _playerHero;
    _playerHero = newHero;
    _playerHp = newHp;
    _playerMana = newHero.maxMana;
    _selectedSkill = null;
    _battleLog = <String>[
      ..._battleLog,
      'Hero switched: ${oldHero?.name ?? 'Unknown'} → ${newHero.name} (HP: $newHp, Mana: ${newHero.maxMana})',
    ];
    notifyListeners();
  }

  void selectSkill(HeroSkill? skill) {
    if (_playerHero == null || skill == null) {
      _selectedSkill = null;
      notifyListeners();
      return;
    }

    if (skill.manaCost <= _playerMana) {
      _selectedSkill = skill;
      _battleLog = <String>[
        ..._battleLog,
        '${_playerHero!.name} is ready to use ${skill.name} next turn.',
      ];
    } else {
      _selectedSkill = null;
      _battleLog = <String>[
        ..._battleLog,
        '${_playerHero!.name} does not have enough mana for ${skill.name}.',
      ];
    }
    notifyListeners();
  }

  void reset({bool notify = true}) {
    _playerHero = null;
    _aiHero = null;
    _playerHp = 0;
    _aiHp = 0;
    _playerMana = 0;
    _aiMana = 0;
    _round = 0;
    _isBattleOver = false;
    _playerWon = false;
    _roundWinner = null;
    _lastPlayerDamage = null;
    _lastAiDamage = null;
    _playerCritical = false;
    _aiCritical = false;
    _selectedSkill = null;
    _battleLog = <String>[];
    if (notify) {
      notifyListeners();
    }
  }
}
