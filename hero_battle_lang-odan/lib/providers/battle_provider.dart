import 'package:flutter/foundation.dart';

import '../models/battle_record.dart';
import '../models/battle_types.dart';
import '../models/battlefield.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

enum LogType { damage, heal, debuff, system }

class BattleLogEntry {
  final String message;
  final LogType type;
  const BattleLogEntry(this.message, this.type);
}

class BattleProvider with ChangeNotifier {
  List<HeroModel> playerTeam = [];
  List<HeroModel> aiTeam = [];

  int currentPlayerHeroIndex = 0;
  int currentAiHeroIndex = 0;
  int? targetIndex;         // which AI hero the player has tapped

  bool isPlayerTurn = true;
  bool isBattleOver = false;
  bool playerWon = false;

  int round = 1;
  int experienceEarned = 0;
  int rewardEarned = 0;

  List<BattleLogEntry> logEntries = [];

  Battlefield battlefield =
      Battlefield(type: BattlefieldType.city, imageUrl: '');
  BattleFormat battleFormat = BattleFormat.threeVsThree;

  // ── Convenience getters ───────────────────────────────────────────────────

  HeroModel get currentPlayerHero => playerTeam[currentPlayerHeroIndex];
  HeroModel get currentAiHero     => aiTeam[currentAiHeroIndex];

  // ── Start / Reset ─────────────────────────────────────────────────────────

  void startBattle(
    List<HeroModel> playerDeck,
    List<HeroModel> aiDeck, {
    BattleFormat format = BattleFormat.threeVsThree,
  }) {
    battleFormat          = format;
    playerTeam            = playerDeck;
    aiTeam                = aiDeck;
    currentPlayerHeroIndex = 0;
    currentAiHeroIndex     = 0;
    targetIndex            = null;
    isPlayerTurn           = true;
    isBattleOver           = false;
    playerWon              = false;
    round                  = 1;
    experienceEarned       = 0;
    rewardEarned           = 0;
    logEntries             = [];
    _addLog('Battle started! Round 1 begins.', LogType.system);
    notifyListeners();
  }

  void resetBattle() {
    playerTeam.clear();
    aiTeam.clear();
    logEntries.clear();
    isBattleOver = false;
    notifyListeners();
  }

  // ── Target selection ──────────────────────────────────────────────────────

  void setTarget(int index) {
    if (!isPlayerTurn || isBattleOver) return;
    targetIndex = index;
    notifyListeners();
  }

  // ── Hero selection ──────────────────────────────────────────────────────

  void selectPlayerHero(int index) {
    if (!isPlayerTurn || isBattleOver || index < 0 || index >= playerTeam.length) return;
    if (!playerTeam[index].isAlive) return; // Can't select dead heroes
    currentPlayerHeroIndex = index;
    targetIndex = null; // Clear target when switching heroes
    notifyListeners();
  }

  // ── Player uses a skill ───────────────────────────────────────────────────

  void useSkill(HeroSkill skill) {
    if (!isPlayerTurn || isBattleOver || !skill.isReady) return;

    final attacker = currentPlayerHero;

    // Stun check
    if (attacker.isStunned) {
      _addLog('${attacker.name} is stunned and cannot act!', LogType.system);
      _finishPlayerTurn(attacker);
      return;
    }

    if (skill.type == SkillType.heal) {
      final amount = skill.baseDamage.abs();
      attacker.heal(amount);
      _addLog('${attacker.name} recovers $amount HP!', LogType.heal);
    } else {
      // Require a target for offensive skills
      final tIdx = targetIndex ?? currentAiHeroIndex;
      final target = aiTeam[tIdx];

      if (!target.isAlive) {
        _addLog('${target.name} is already defeated — pick another target!',
            LogType.system);
        return;
      }

      final prevHp = target.currentHp;
      target.takeDamage(skill.baseDamage);
      final dealt = prevHp - target.currentHp;

      _addLog(
        '${attacker.name} uses ${skill.name} on ${target.name} for $dealt damage!',
        LogType.damage,
      );

      if (skill.appliesEffect != null) {
        final effect = StatusEffect(
          type:     skill.appliesEffect!,
          duration: 3,
          value:    (skill.baseDamage * 0.4).round().clamp(1, 999),
        );
        target.applyStatusEffect(effect);
        _addLog(
          '${target.name} is now ${effect.name}ed!',
          LogType.debuff,
        );
      }

      if (!target.isAlive) {
        _addLog('${target.name} is defeated!', LogType.system);
        _advanceAiHero();
      }
    }

    _finishPlayerTurn(attacker);
  }

  void _finishPlayerTurn(HeroModel attacker) {
    attacker.tickSkillCooldowns();
    targetIndex  = null;
    isPlayerTurn = false;
    notifyListeners();

    if (_checkBattleOver()) return;

    // AI acts automatically after a short delay
    Future.delayed(const Duration(milliseconds: 900), _aiTurn);
  }

  // ── AI turn ───────────────────────────────────────────────────────────────

  void _aiTurn() {
    if (isBattleOver) return;

    final aiHero = currentAiHero;

    // Tick status effects first
    for (final msg in aiHero.tickStatusEffects()) {
      _addLog(msg, LogType.debuff);
    }

    if (!aiHero.isAlive) {
      _addLog('${aiHero.name} succumbed to status effects!', LogType.system);
      _advanceAiHero();
    } else if (!aiHero.isStunned) {
      _aiChooseAndAct(aiHero);
    }

    if (_checkBattleOver()) return;

    round++;
    isPlayerTurn = true;
    _addLog('Round $round begins.', LogType.system);
    notifyListeners();
  }

  void _aiChooseAndAct(HeroModel aiHero) {
    // Simple AI: heal if below 30 % HP and heal is ready, else attack
    final healSkill = aiHero.skills
        .where((s) => s.type == SkillType.heal && s.isReady)
        .firstOrNull;
    final attackSkill = aiHero.skills
        .where((s) => s.type == SkillType.attack && s.isReady)
        .firstOrNull
        ?? aiHero.skills.first;

    final useHeal = healSkill != null &&
        aiHero.currentHp < (aiHero.maxHp * 0.3).round();

    if (useHeal) {
      final amount = healSkill.baseDamage.abs();
      aiHero.heal(amount);
      healSkill.currentCooldown = healSkill.maxCooldown;
      _addLog('${aiHero.name} uses ${healSkill.name} and recovers $amount HP!',
          LogType.heal);
    } else {
      final target = playerTeam.firstWhere(
        (h) => h.isAlive,
        orElse: () => playerTeam.first,
      );
      final prevHp = target.currentHp;
      target.takeDamage(attackSkill.baseDamage);
      final dealt = prevHp - target.currentHp;

      _addLog(
        '${aiHero.name} uses ${attackSkill.name} on ${target.name} for $dealt damage!',
        LogType.damage,
      );

      attackSkill.currentCooldown = attackSkill.maxCooldown;

      if (!target.isAlive) {
        _addLog('${target.name} is defeated!', LogType.system);
        _advancePlayerHero();
      }
    }

    aiHero.tickSkillCooldowns();
  }

  // ── Hero advancement ──────────────────────────────────────────────────────

  void _advanceAiHero() {
    for (int i = 0; i < aiTeam.length; i++) {
      if (aiTeam[i].isAlive) {
        currentAiHeroIndex = i;
        return;
      }
    }
  }

  void _advancePlayerHero() {
    for (int i = 0; i < playerTeam.length; i++) {
      if (playerTeam[i].isAlive) {
        currentPlayerHeroIndex = i;
        return;
      }
    }
  }

  // ── Win / lose check ──────────────────────────────────────────────────────

  bool _checkBattleOver() {
    final playerAlive = playerTeam.any((h) => h.isAlive);
    final aiAlive     = aiTeam.any((h) => h.isAlive);

    if (playerAlive && aiAlive) return false;

    isBattleOver     = true;
    playerWon        = playerAlive;
    experienceEarned = playerWon ? 100 : 30;
    rewardEarned     = playerWon ? 50  : 0;

    if (playerWon) {
      final xpPerHero = (experienceEarned / playerTeam.length).round();
      for (final hero in playerTeam) {
        hero.addXp(xpPerHero);
      }
    }

    _addLog(
      playerWon ? '🏆 Victory! The player wins!' : '💀 The AI wins!',
      LogType.system,
    );
    notifyListeners();
    return true;
  }

  // ── Logging ───────────────────────────────────────────────────────────────

  void _addLog(String message, LogType type) {
    logEntries.add(BattleLogEntry(message, type));
  }

  // ── Persistence (unchanged) ───────────────────────────────────────────────

  Future<void> saveBattleHistory() async {
    if (!isBattleOver) return;
    final record = BattleRecord(
      playerHero:   playerTeam.map((h) => h.name).join(', '),
      aiHero:       aiTeam.map((h) => h.name).join(', '),
      playerWon:    playerWon,
      roundsPlayed: round - 1,
      playedAt:     DateTime.now().toIso8601String(),
    );
    await DatabaseService().saveBattleRecord(record);
  }
}