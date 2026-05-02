import 'dart:math';
import '../models/hero_model.dart';

// ── Immutable battle snapshot ─────────────────────────────────────────────

class BattleState {
  final HeroModel playerHero;
  final HeroModel aiHero;
  final int playerHp;
  final int aiHp;
  final int playerMaxHp;
  final int aiMaxHp;
  final int round;
  final bool isPlayerTurn;
  final List<String> battleLog;
  final bool isOver;
  final bool playerWon;

  const BattleState({
    required this.playerHero,
    required this.aiHero,
    required this.playerHp,
    required this.aiHp,
    required this.playerMaxHp,
    required this.aiMaxHp,
    required this.round,
    required this.isPlayerTurn,
    required this.battleLog,
    required this.isOver,
    required this.playerWon,
  });

  BattleState copyWith({
    int? playerHp,
    int? aiHp,
    int? round,
    bool? isPlayerTurn,
    List<String>? battleLog,
    bool? isOver,
    bool? playerWon,
  }) =>
      BattleState(
        playerHero: playerHero,
        aiHero: aiHero,
        playerHp: playerHp ?? this.playerHp,
        aiHp: aiHp ?? this.aiHp,
        playerMaxHp: playerMaxHp,
        aiMaxHp: aiMaxHp,
        round: round ?? this.round,
        isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
        battleLog: battleLog ?? this.battleLog,
        isOver: isOver ?? this.isOver,
        playerWon: playerWon ?? this.playerWon,
      );
}

// ── Engine (pure functions, no side-effects) ──────────────────────────────

class BattleEngine {
  static final _rng = Random();

  /// Initialise a new battle. Player always goes first.
  static BattleState init(HeroModel player, HeroModel ai) => BattleState(
        playerHero: player,
        aiHero: ai,
        playerHp: player.maxHp,
        aiHp: ai.maxHp,
        playerMaxHp: player.maxHp,
        aiMaxHp: ai.maxHp,
        round: 1,
        isPlayerTurn: true,
        battleLog: [
          '⚔️  Battle begins!',
          '${player.name}  vs  ${ai.name}',
          '💥 ${player.name} goes first!',
        ],
        isOver: false,
        playerWon: false,
      );

  /// Normal attack — player turn.
  static BattleState playerAttack(BattleState s) {
    if (s.isOver || !s.isPlayerTurn) return s;
    final dmg = _damage(s.playerHero.attack, s.aiHero.defense);
    final newAiHp = (s.aiHp - dmg).clamp(0, s.aiMaxHp);
    final log = [...s.battleLog, '🗡️ ${s.playerHero.name} attacks for $dmg dmg!'];
    if (newAiHp == 0) {
      return s.copyWith(
        aiHp: newAiHp,
        battleLog: [...log, '🏆 ${s.playerHero.name} wins!'],
        isOver: true,
        playerWon: true,
      );
    }
    return s.copyWith(aiHp: newAiHp, battleLog: log, isPlayerTurn: false);
  }

  /// Special attack — 80 % accuracy, 1.6× damage — player turn.
  static BattleState playerSpecial(BattleState s) {
    if (s.isOver || !s.isPlayerTurn) return s;
    if (_rng.nextDouble() < 0.20) {
      return s.copyWith(
        battleLog: [...s.battleLog, '✨ ${s.playerHero.name} Special — MISSED!'],
        isPlayerTurn: false,
      );
    }
    final dmg = _damage(s.playerHero.specialAttack, s.aiHero.defense,
        multiplier: 1.6);
    final newAiHp = (s.aiHp - dmg).clamp(0, s.aiMaxHp);
    final log = [
      ...s.battleLog,
      '✨ ${s.playerHero.name} Special hits for $dmg dmg!'
    ];
    if (newAiHp == 0) {
      return s.copyWith(
        aiHp: newAiHp,
        battleLog: [...log, '🏆 ${s.playerHero.name} wins!'],
        isOver: true,
        playerWon: true,
      );
    }
    return s.copyWith(aiHp: newAiHp, battleLog: log, isPlayerTurn: false);
  }

  /// AI turn — called after every player action (inside BattleProvider).
  static BattleState aiTurn(BattleState s) {
    if (s.isOver || s.isPlayerTurn) return s;
    final useSpecial = _rng.nextDouble() < 0.30;
    int dmg;
    String action;
    if (useSpecial) {
      if (_rng.nextDouble() < 0.20) {
        return s.copyWith(
          battleLog: [...s.battleLog, '✨ ${s.aiHero.name} Special — MISSED!'],
          isPlayerTurn: true,
          round: s.round + 1,
        );
      }
      dmg = _damage(s.aiHero.specialAttack, s.playerHero.defense, multiplier: 1.6);
      action = '✨ ${s.aiHero.name} Special hits for $dmg dmg!';
    } else {
      dmg = _damage(s.aiHero.attack, s.playerHero.defense);
      action = '🗡️ ${s.aiHero.name} attacks for $dmg dmg!';
    }
    final newPlayerHp = (s.playerHp - dmg).clamp(0, s.playerMaxHp);
    final log = [...s.battleLog, action];
    if (newPlayerHp == 0) {
      return s.copyWith(
        playerHp: newPlayerHp,
        battleLog: [...log, '💀 ${s.aiHero.name} wins!'],
        isOver: true,
        playerWon: false,
      );
    }
    return s.copyWith(
        playerHp: newPlayerHp,
        battleLog: log,
        isPlayerTurn: true,
        round: s.round + 1);
  }

  static int _damage(int atk, int def, {double multiplier = 1.0}) {
    final base = (atk * multiplier).round();
    final reduced = (base - def ~/ 2).clamp(1, 9999);
    final variance = _rng.nextInt(5) - 2; // –2 … +2
    return (reduced + variance).clamp(1, 9999);
  }
}
