import 'package:flutter/material.dart';

// ── Hero Roles ───────────────────────────────────────────────────────────────

enum HeroRole { tank, damage, support }

extension HeroRoleExtension on HeroRole {
  String get name {
    switch (this) {
      case HeroRole.tank:    return 'Tank';
      case HeroRole.damage:  return 'Damage';
      case HeroRole.support: return 'Support';
    }
  }

  Color get color {
    switch (this) {
      case HeroRole.tank:    return Colors.blue;
      case HeroRole.damage:  return Colors.red;
      case HeroRole.support: return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case HeroRole.tank:    return Icons.shield;
      case HeroRole.damage:  return Icons.flash_on;
      case HeroRole.support: return Icons.healing;
    }
  }
}

class PowerStats {
  final int intelligence;
  final int strength;
  final int speed;
  final int durability;
  final int power;
  final int combat;

  const PowerStats({
    required this.intelligence,
    required this.strength,
    required this.speed,
    required this.durability,
    required this.power,
    required this.combat,
  });

  factory PowerStats.fromJson(Map<String, dynamic> json) {
    int parse(dynamic value) {
      final asString = value?.toString();
      if (asString == null || asString == 'null') return 50;
      return int.tryParse(asString) ?? 50;
    }

    return PowerStats(
      intelligence: parse(json['intelligence']),
      strength:     parse(json['strength']),
      speed:        parse(json['speed']),
      durability:   parse(json['durability']),
      power:        parse(json['power']),
      combat:       parse(json['combat']),
    );
  }

  Map<String, dynamic> toJson() => {
        'intelligence': intelligence,
        'strength':     strength,
        'speed':        speed,
        'durability':   durability,
        'power':        power,
        'combat':       combat,
      };
}

// ── Status Effects ────────────────────────────────────────────────────────────

enum StatusEffectType { poison, stun, shield, burn }

class StatusEffect {
  final StatusEffectType type;
  int duration;
  final int value;

  StatusEffect({
    required this.type,
    required this.duration,
    required this.value,
  });

  String get name {
    switch (type) {
      case StatusEffectType.poison: return 'Poison';
      case StatusEffectType.stun:   return 'Stun';
      case StatusEffectType.shield: return 'Shield';
      case StatusEffectType.burn:   return 'Burn';
    }
  }

  Color get color {
    switch (type) {
      case StatusEffectType.poison: return Colors.purple;
      case StatusEffectType.stun:   return Colors.yellow;
      case StatusEffectType.shield: return Colors.blue;
      case StatusEffectType.burn:   return Colors.orange;
    }
  }
}

// ── Skills ────────────────────────────────────────────────────────────────────

enum SkillType { attack, heal, debuff }

class HeroSkill {
  final String name;
  final String description;
  final int baseDamage;   // negative = healing
  final int maxCooldown;
  int currentCooldown;
  final SkillType type;
  final StatusEffectType? appliesEffect;
  final IconData icon;

  HeroSkill({
    required this.name,
    required this.description,
    required this.baseDamage,
    required this.maxCooldown,
    required this.type,
    required this.icon,
    this.appliesEffect,
    this.currentCooldown = 0,
  });

  bool get isReady => currentCooldown == 0;
}

// ── Hero Model ────────────────────────────────────────────────────────────────

class HeroModel {
  final String id;
  final String name;
  final String imageUrl;
  final String publisher;
  final String alignment;
  final String fullName;
  final PowerStats powerStats;
  int currentHp;
  List<StatusEffect> statusEffects;
  late List<HeroSkill> skills;
  late final HeroRole role;
  int level;
  int currentXp;

  HeroModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.powerStats,
    required this.publisher,
    required this.alignment,
    required this.fullName,
    required this.currentHp,
    List<StatusEffect>? statusEffects,
    this.level = 1,
    this.currentXp = 0,
  }) : statusEffects = statusEffects ?? [] {
    role = _determineRole();
    skills = _buildSkills();
  }

  // ── Derived stats (unchanged from your original) ──────────────────────────
  double get levelMultiplier => 1.0 + (level - 1) * 0.1; // 10% per level

  int get maxHp        => (((powerStats.durability + powerStats.power) / 2) * levelMultiplier).round();
  int get attack       => (((powerStats.strength + powerStats.combat) / 2) * levelMultiplier).round();
  int get specialAttack=> (((powerStats.intelligence + powerStats.power) / 2) * levelMultiplier).round();
  int get defense      => (((powerStats.durability + powerStats.combat) / 4) * levelMultiplier).round();
  int get initiative   => (powerStats.speed * levelMultiplier).round();

  bool get isAlive   => currentHp > 0;
  bool get isStunned => statusEffects.any((e) => e.type == StatusEffectType.stun);

  int get xpToNextLevel => level * 100;

  void addXp(int amount) {
    currentXp += amount;
    while (currentXp >= xpToNextLevel) {
      currentXp -= xpToNextLevel;
      _levelUp();
    }
  }

  void _levelUp() {
    level++;
    // Increase stats by 10%
    // But since powerStats is final, need to modify or recreate.
    // For simplicity, just increase derived stats multipliers.
    // Actually, since derived stats are calculated from powerStats, and powerStats is final,
    // perhaps add level bonuses.
    // To keep simple, just increase level, and maybe adjust skills.
    // For now, just level up, stats stay same.
  }

  HeroRole _determineRole() {
    final stats = powerStats;
    final durabilityScore = stats.durability;
    final strengthScore = stats.strength + stats.power;
    final intelligenceScore = stats.intelligence;

    if (durabilityScore > strengthScore && durabilityScore > intelligenceScore) {
      return HeroRole.tank;
    } else if (strengthScore > intelligenceScore) {
      return HeroRole.damage;
    } else {
      return HeroRole.support;
    }
  }

  // ── Skills built from actual powerstats ──────────────────────────────────
  List<HeroSkill> _buildSkills() => [
    HeroSkill(
      name: 'Strike',
      description: 'Basic attack based on strength.',
      baseDamage: attack,
      maxCooldown: 0,
      type: SkillType.attack,
      icon: Icons.flash_on,
    ),
    HeroSkill(
      name: 'Power Blow',
      description: 'Heavy attack. 2-turn cooldown.',
      baseDamage: (attack * 1.8).round(),
      maxCooldown: 2,
      type: SkillType.attack,
      icon: Icons.whatshot,
    ),
    HeroSkill(
      name: 'Poison',
      description: 'Deals ${(attack * 0.4).round()} damage/turn for 3 turns.',
      baseDamage: (attack * 0.5).round(),
      maxCooldown: 3,
      type: SkillType.debuff,
      appliesEffect: StatusEffectType.poison,
      icon: Icons.coronavirus,
    ),
    HeroSkill(
      name: 'Recover',
      description: 'Heals based on durability.',
      baseDamage: -(powerStats.durability ~/ 2),
      maxCooldown: 3,
      type: SkillType.heal,
      icon: Icons.favorite,
    ),
  ];

  // ── Combat helpers ────────────────────────────────────────────────────────

  void takeDamage(int amount) {
    final shieldVal = statusEffects
        .where((e) => e.type == StatusEffectType.shield)
        .fold(0, (sum, e) => sum + e.value);
    final effective = (amount - shieldVal - defense).clamp(1, 9999);
    currentHp = (currentHp - effective).clamp(0, maxHp);
  }

  void heal(int amount) {
    currentHp = (currentHp + amount).clamp(0, maxHp);
  }

  void applyStatusEffect(StatusEffect effect) {
    statusEffects.removeWhere((e) => e.type == effect.type);
    statusEffects.add(effect);
  }

  /// Ticks all status effects and returns log messages.
  List<String> tickStatusEffects() {
    final logs = <String>[];
    final toRemove = <StatusEffect>[];

    for (final effect in statusEffects) {
      switch (effect.type) {
        case StatusEffectType.poison:
        case StatusEffectType.burn:
          currentHp = (currentHp - effect.value).clamp(0, maxHp);
          logs.add('$name takes ${effect.value} ${effect.name} damage!');
          break;
        case StatusEffectType.stun:
          logs.add('$name is stunned and loses their turn!');
          break;
        case StatusEffectType.shield:
          break;
      }
      effect.duration--;
      if (effect.duration <= 0) toRemove.add(effect);
    }

    statusEffects.removeWhere(toRemove.contains);
    return logs;
  }

  void tickSkillCooldowns() {
    for (final skill in skills) {
      if (skill.currentCooldown > 0) skill.currentCooldown--;
    }
  }

  // ── Serialisation (keeps your original fields) ────────────────────────────

  factory HeroModel.fromJson(Map<String, dynamic> json) {
    final powerStats = PowerStats.fromJson(
      (json['powerstats'] as Map?)?.cast<String, dynamic>() ?? {},
    );
    final maxHp = ((powerStats.durability + powerStats.power) / 2).round();
    return HeroModel(
      id:         json['id'].toString(),
      name:       json['name'] as String? ?? 'Unknown',
      imageUrl:   (json['images'] as Map?)?['lg'] as String?
                      ?? (json['image'] as Map?)?['url'] as String?
                      ?? '',
      powerStats: powerStats,
      publisher:  (json['biography'] as Map?)?['publisher'] as String? ?? '',
      alignment:  (json['biography'] as Map?)?['alignment'] as String? ?? 'neutral',
      fullName:   (json['biography'] as Map?)?['full-name'] as String? ?? '',
      currentHp:  maxHp,
    );
  }

  Map<String, dynamic> toJson() => {
        'id':         id,
        'name':       name,
        'imageUrl':   imageUrl,
        'publisher':  publisher,
        'alignment':  alignment,
        'fullName':   fullName,
        'powerStats': powerStats.toJson(),
        'currentHp':  currentHp,
      };
}