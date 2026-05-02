import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/battle_types.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final SuperheroApiService _api = SuperheroApiService(apiToken: kApiToken);
  late Future<List<HeroModel>> _enemyFuture;
  BattleFormat _selectedFormat = BattleFormat.threeVsThree;
  bool _didStart = false;
  bool _savedResult = false;
  final ScrollController _logScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _enemyFuture = _loadEnemy(count: _selectedFormat.teamSize);
  }

  @override
  void dispose() {
    _logScroll.dispose();
    super.dispose();
  }

  Future<List<HeroModel>> _loadEnemy({required int count}) async {
    final heroes = await _api.fetchRandomHeroes(count: count);
    if (heroes.isEmpty) throw Exception('No AI opponent available.');
    return heroes;
  }

  void _setBattleFormat(BattleFormat format) {
    setState(() {
      _selectedFormat = format;
      _didStart = false;
      _savedResult = false;
      _enemyFuture = _loadEnemy(count: format.teamSize);
    });
  }

  void _scrollLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logScroll.hasClients) {
        _logScroll.animateTo(
          _logScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _logColor(LogType t) {
    switch (t) {
      case LogType.damage:  return Colors.redAccent;
      case LogType.heal:    return Colors.greenAccent;
      case LogType.debuff:  return Colors.orangeAccent;
      case LogType.system:  return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>().deck;

    if (deck.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Battle')),
        body: const Center(child: Text('Add heroes to your deck first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: FutureBuilder<List<HeroModel>>(
        future: _enemyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final aiTeam = snapshot.data!;
          final battle = context.watch<BattleProvider>();
          final requiredSize = _selectedFormat.teamSize;
          final canStartBattle = deck.length >= requiredSize;
          final selectedPlayerTeam = deck.take(requiredSize).toList();

          // Start battle once
          if (!_didStart && canStartBattle) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.read<BattleProvider>().startBattle(
                    selectedPlayerTeam,
                    aiTeam,
                    format: _selectedFormat,
                  );
              _didStart = true;
            });
          }

          // Save result once
          if (battle.isBattleOver && !_savedResult) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              _savedResult = true;
              final battleProvider = context.read<BattleProvider>();
              final playerProvider = context.read<PlayerProvider>();
              await battleProvider.saveBattleHistory();
              if (!mounted) return;
              playerProvider.addExperience(battle.experienceEarned);
              if (battle.playerWon) {
                playerProvider.incrementWins();
                playerProvider.addCurrency(battle.rewardEarned);
              }
            });
          }

          _scrollLog();

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              image: DecorationImage(
                image: NetworkImage(
                    'https://img.freepik.com/premium-photo/gladiators-arena-colosseum-coliseum-front-view-ancient-battlefield-war-zone-warrior_510654-324.jpg?w=2000'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: BattleFormat.values.map((format) {
                      final enabled = deck.length >= format.teamSize;
                      return ChoiceChip(
                        label: Text(format.label),
                        selected: _selectedFormat == format,
                        onSelected: enabled ? (_) => _setBattleFormat(format) : null,
                        backgroundColor: Colors.white12,
                        selectedColor: Colors.deepPurpleAccent,
                        disabledColor: Colors.white10,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 6),
                  if (deck.length < _selectedFormat.teamSize)
                    Text(
                      'Add ${_selectedFormat.teamSize - deck.length} more hero${_selectedFormat.teamSize - deck.length == 1 ? '' : 'es'} to fight ${_selectedFormat.label}.',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  const SizedBox(height: 6),

                  // ── Teams row (side by side) ──────────────────
                  Expanded(
                    child: Row(
                      children: [
                        // Enemy team
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _teamLabel('Enemy', Colors.redAccent),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Row(
                                  children: battle.aiTeam.asMap().entries.map((e) =>
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: battle.isPlayerTurn && e.value.isAlive && !battle.isBattleOver
                                            ? () => context.read<BattleProvider>().setTarget(e.key)
                                            : null,
                                        child: _HeroBattleCard(
                                          hero:      e.value,
                                          isCurrent: !battle.isPlayerTurn &&
                                                     battle.currentAiHeroIndex == e.key,
                                          isTargeted: battle.targetIndex == e.key,
                                          color:     Colors.red,
                                        ),
                                      ),
                                    ),
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Player team
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _teamLabel('Your Team', Colors.greenAccent),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Row(
                                  children: battle.playerTeam.asMap().entries.map((e) =>
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: battle.isPlayerTurn && e.value.isAlive && !battle.isBattleOver
                                            ? () => context.read<BattleProvider>().selectPlayerHero(e.key)
                                            : null,
                                        child: _HeroBattleCard(
                                          hero:      e.value,
                                          isCurrent: battle.isPlayerTurn &&
                                                     battle.currentPlayerHeroIndex == e.key,
                                          isTargeted: false,
                                          color:     Colors.green,
                                        ),
                                      ),
                                    ),
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ── Round info & status ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Round ${battle.round}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      if (!battle.isBattleOver)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  battle.isPlayerTurn ? Icons.person : Icons.smart_toy,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    battle.isPlayerTurn
                                        ? battle.targetIndex != null
                                            ? '${battle.currentPlayerHero.name} → ${battle.aiTeam[battle.targetIndex!].name}'
                                            : battle.currentPlayerHero.name
                                        : 'AI Turn',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    battle.isBattleOver
                        ? 'Battle finished'
                        : battle.isPlayerTurn
                            ? '👆 Tap your hero, then enemy, use skill!'
                            : '🤖 AI acting...',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),

                  // ── Skill bar ────────────────────────────────
                  if (battle.isPlayerTurn &&
                      !battle.isBattleOver &&
                      battle.playerTeam.isNotEmpty)
                    SizedBox(
                      height: 60,
                      child: _SkillBar(
                        hero: battle.currentPlayerHero,
                        onSkillTap: (skill) {
                          if (!mounted) return;
                          if (skill.type != SkillType.heal &&
                              battle.targetIndex == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('👆 Tap enemy to target first!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          context.read<BattleProvider>().useSkill(skill);
                        },
                      ),
                    ),
                  const SizedBox(height: 4),

                  // ── Battle log ───────────────────────────────
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: battle.logEntries.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tap your hero, then enemy, use skill',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic),
                                ),
                              )
                            : ListView.separated(
                                controller: _logScroll,
                                itemCount: battle.logEntries.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 4),
                                itemBuilder: (_, i) {
                                  final entry = battle.logEntries[i];
                                  return Text(
                                    entry.message,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: _logColor(entry.type),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ── Battle over ──────────────────────────────
                  if (battle.isBattleOver) ...[
                    Text(
                      battle.playerWon
                          ? '🏆 Victory! +${battle.experienceEarned} XP, +${battle.rewardEarned} coins.'
                          : '💀 Defeat... +${battle.experienceEarned} XP.',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BattleProvider>().resetBattle();
                        Navigator.pop(context);
                      },
                      icon: Icon(battle.playerWon
                          ? Icons.emoji_events
                          : Icons.close),
                      label: Text(
                        battle.playerWon ? 'You Win!' : 'You Lose',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            battle.playerWon ? Colors.green : Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _teamLabel(String text, Color color) => Text(
        text,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12),
      );
}

// ── Skill Bar ─────────────────────────────────────────────────────────────────

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.hero, required this.onSkillTap});

  final HeroModel hero;
  final void Function(HeroSkill) onSkillTap;

  Color _skillColor(SkillType t) {
    switch (t) {
      case SkillType.attack: return Colors.redAccent;
      case SkillType.heal:   return Colors.green;
      case SkillType.debuff: return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skills',
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        const SizedBox(height: 6),
        Row(
          children: hero.skills.map((skill) {
            final ready = skill.isReady;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Tooltip(
                  message:
                      '${skill.description}\nDamage: ${skill.baseDamage < 0 ? "Heals ${skill.baseDamage.abs()}" : skill.baseDamage}',
                  child: ElevatedButton(
                    onPressed: ready ? () => onSkillTap(skill) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ready
                          ? _skillColor(skill.type)
                          : Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(skill.icon, size: 18, color: Colors.white),
                        const SizedBox(height: 2),
                        Text(
                          skill.name,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        if (!ready)
                          Text(
                            'CD: ${skill.currentCooldown}',
                            style: const TextStyle(
                                fontSize: 9, color: Colors.white60),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Hero Battle Card ──────────────────────────────────────────────────────────

class _HeroBattleCard extends StatefulWidget {
  const _HeroBattleCard({
    required this.hero,
    required this.isCurrent,
    required this.isTargeted,
    required this.color,
  });

  final HeroModel hero;
  final bool isCurrent;
  final bool isTargeted;
  final Color color;

  @override
  State<_HeroBattleCard> createState() => _HeroBattleCardState();
}

class _HeroBattleCardState extends State<_HeroBattleCard>
    with TickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _shakeCtrl = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0,   end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end:  10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0,  end:   0.0), weight: 1),
    ]).animate(_shakeCtrl);

    _glowCtrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 4, end: 18).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant _HeroBattleCard old) {
    super.didUpdateWidget(old);
    if (widget.hero.currentHp < old.hero.currentHp) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dead = !widget.hero.isAlive;

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnim, _glowAnim]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(_shakeAnim.value, 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                if (widget.isCurrent)
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.75),
                    blurRadius: _glowAnim.value,
                    spreadRadius: 2,
                  ),
                if (widget.isTargeted)
                  const BoxShadow(
                    color: Colors.yellowAccent,
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: widget.isTargeted
                    ? const BorderSide(color: Colors.yellowAccent, width: 2)
                    : BorderSide.none,
              ),
              elevation: widget.isCurrent ? 8 : 4,
              color: widget.isCurrent
                  ? widget.color.withValues(alpha: 0.2)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Grayscale when dead
                    ColorFiltered(
                      colorFilter: dead
                          ? const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0,      0,      0,      1, 0,
                            ])
                          : const ColorFilter.matrix([
                              1, 0, 0, 0, 0,
                              0, 1, 0, 0, 0,
                              0, 0, 1, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.hero.imageUrl),
                        radius: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.hero.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: dead ? Colors.grey : null,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!dead) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Lv. ${widget.hero.level}',
                        style: TextStyle(
                          fontSize: 9,
                          color: dead ? Colors.grey : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: widget.hero.role.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.hero.role.name,
                          style: TextStyle(
                            fontSize: 8,
                            color: widget.hero.role.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (dead)
                      const Text('💀',
                          style: TextStyle(fontSize: 12))
                    else ...[
                      const SizedBox(height: 4),
                      HpBar(
                        currentHp: widget.hero.currentHp,
                        maxHp:     widget.hero.maxHp,
                        color:     widget.color,
                      ),
                      // Status effect chips
                      if (widget.hero.statusEffects.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: widget.hero.statusEffects.map((e) =>
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: e.color.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${e.name} ${e.duration}',
                                style: const TextStyle(
                                    fontSize: 8, color: Colors.white),
                              ),
                            ),
                          ).toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}