import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';

const String kApiToken = String.fromEnvironment(
  'SUPERHERO_API_TOKEN',
  defaultValue: '86fc32080c6be7c63070313609482a39',
);

enum _BattleStage { setup, loading, arena }

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  final SuperheroApiService? _api = kApiToken.isEmpty ? null : SuperheroApiService(apiToken: kApiToken);
  late final AnimationController _loadingController;

  _BattleStage _stage = _BattleStage.setup;
  String? _selectedSetupHeroId;
  String _selectedDifficulty = 'Easy';
  bool _startingBattle = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final deck = context.read<DeckProvider>();
    if (deck.battleTeam.isNotEmpty &&
        (_selectedSetupHeroId == null || deck.battleTeam.every((hero) => hero.id != _selectedSetupHeroId))) {
      _selectedSetupHeroId = deck.battleTeam.first.id;
    }
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  String _slugify(String value) {
    final lower = value.toLowerCase();
    final replaced = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    return replaced.replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _cdnHeroImageUrl(HeroModel hero) {
    final slug = _slugify(hero.name);
    if (hero.id.isEmpty || slug.isEmpty) return '';
    return 'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/images/lg/${hero.id}-$slug.jpg';
  }

  String _diceBearFallbackUrl(HeroModel hero) {
    final seed = hero.name.isNotEmpty ? hero.name : 'hero';
    return 'https://api.dicebear.com/9.x/bottts/avif?seed=${Uri.encodeComponent(seed)}';
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _buildHeroImage(HeroModel hero, BuildContext context) {
    final primaryUrl = _isValidUrl(hero.imageUrl) ? hero.imageUrl : '';
    final cdnUrl = _cdnHeroImageUrl(hero);

    Widget initialFallback() {
      return Center(
        child: Text(
          hero.name.isEmpty ? '?' : hero.name[0],
          style: Theme.of(context).textTheme.displaySmall,
        ),
      );
    }

    Widget diceBearFallback() {
      return Image.network(
        _diceBearFallbackUrl(hero),
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) => initialFallback(),
      );
    }

    Widget cdnFallback() {
      if (cdnUrl.isEmpty) return diceBearFallback();
      return Image.network(
        cdnUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (_, __, ___) => diceBearFallback(),
      );
    }

    if (primaryUrl.isEmpty) return cdnFallback();

    return Image.network(
      primaryUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) => cdnFallback(),
    );
  }

  Widget _buildHeroMiniAvatar(HeroModel hero) {
    final primaryUrl = _isValidUrl(hero.imageUrl) ? hero.imageUrl : '';
    final cdnUrl = _cdnHeroImageUrl(hero);

    Widget letterFallback() {
      return Center(
        child: Text(
          hero.name.isEmpty ? '?' : hero.name[0],
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      );
    }

    Widget diceBearFallback() {
      return Image.network(
        _diceBearFallbackUrl(hero),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => letterFallback(),
      );
    }

    Widget cdnFallback() {
      if (cdnUrl.isEmpty) return diceBearFallback();
      return Image.network(
        cdnUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => diceBearFallback(),
      );
    }

    final child = primaryUrl.isEmpty
        ? cdnFallback()
        : Image.network(
            primaryUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => cdnFallback(),
          );

    return ClipOval(child: SizedBox(width: 36, height: 36, child: child));
  }

  Future<List<HeroModel>> _buildAiTeam(List<HeroModel> playerTeam) async {
    final fallbackDeck = context.read<DeckProvider>().deck;
    final api = _api;
    if (api != null) {
      try {
        final aiHeroes = await api.fetchRandomHeroes(count: 5);
        if (aiHeroes.isNotEmpty) {
          return aiHeroes;
        }
      } catch (_) {
        // Fall back to the roster deck below.
      }
    }

    final fallback = [...fallbackDeck]..shuffle();
    if (fallback.isEmpty) return playerTeam.take(5).toList();
    return fallback.take(5).toList();
  }

  Future<String?> _showDifficultyDialog() async {
    String selected = _selectedDifficulty;
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Deploy to Battle Arena'),
          content: StatefulBuilder(
            builder: (context, setLocalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose difficulty'),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(value: 'Easy', label: Text('Easy')),
                      ButtonSegment<String>(value: 'Normal', label: Text('Normal')),
                      ButtonSegment<String>(value: 'Hard', label: Text('Hard')),
                    ],
                    showSelectedIcon: false,
                    selected: {selected},
                    onSelectionChanged: (selection) {
                      setLocalState(() => selected = selection.first);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startBattleSequence(DeckProvider deck) async {
    if (_startingBattle) return;
    if (!deck.isBattleTeamReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick 5 heroes for your battle team first.')),
      );
      return;
    }

    final difficulty = await _showDifficultyDialog();
    if (difficulty == null) return;
    if (!mounted) return;

    setState(() {
      _startingBattle = true;
      _selectedDifficulty = difficulty;
      _stage = _BattleStage.loading;
    });

    _loadingController.forward(from: 0);
    final aiTeamFuture = _buildAiTeam(deck.battleTeam);

    await Future.delayed(const Duration(seconds: 5));
    final aiTeam = await aiTeamFuture;
    if (!mounted) return;

    final battle = context.read<BattleProvider>();
    battle.prepareMatch(
      playerTeam: deck.battleTeam,
      aiTeam: aiTeam,
      difficulty: difficulty,
    );
    battle.startBattle(playerHeroId: deck.battleTeam.first.id);

    setState(() {
      _stage = _BattleStage.arena;
      _startingBattle = false;
    });
  }

  Widget _buildTeamStatus({
    required BuildContext context,
    required String title,
    required List<HeroModel> heroes,
    required BattleProvider battle,
    required bool isPlayer,
    bool alignToEnd = false,
  }) {
    final remaining = isPlayer ? battle.playerRemainingHeroes : battle.aiRemainingHeroes;

    return Column(
      crossAxisAlignment: alignToEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: alignToEnd ? TextAlign.right : TextAlign.left,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Team Remaining: $remaining/${heroes.length}',
          textAlign: alignToEnd ? TextAlign.right : TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: alignToEnd ? WrapAlignment.end : WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children: heroes.map((hero) {
            final hp = isPlayer ? battle.hpForPlayerHero(hero.id) : battle.hpForAiHero(hero.id);
            final active = (isPlayer ? battle.playerHero?.id : battle.aiHero?.id) == hero.id;
            final alive = hp > 0;
            final borderColor = active
                ? Theme.of(context).colorScheme.primary
                : alive
                    ? Theme.of(context).colorScheme.outline
                    : Colors.grey.shade600;

            return Tooltip(
              message: isPlayer
                  ? (active ? '${hero.name} (active)' : 'Tap to use ${hero.name}')
                  : '${hero.name} ($hp HP)',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isPlayer && alive && !active
                      ? () => context.read<BattleProvider>().switchPlayerHero(hero.id)
                      : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: borderColor,
                        width: active ? 2.5 : 1.5,
                      ),
                      color: alive ? null : Colors.black26,
                    ),
                    child: Opacity(
                      opacity: alive ? 1 : 0.35,
                      child: _buildHeroMiniAvatar(hero),
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

  Widget _buildBattleStatLine({
    required BuildContext context,
    required String label,
    required Widget icon,
    required int value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 22, height: 22, child: Center(child: icon)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBattleStatCard({
    required BuildContext context,
    required HeroModel hero,
    required bool isPlayer,
  }) {
    final label = isPlayer ? 'Your Stats' : 'AI Stats';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            _buildBattleStatLine(
              context: context,
              label: 'ATK',
              value: hero.attack,
              icon: const Text('⚔', style: TextStyle(fontSize: 16, height: 1)),
            ),
            _buildBattleStatLine(
              context: context,
              label: 'SPC',
              value: hero.specialAttack,
              icon: const Icon(Icons.auto_awesome, size: 18),
            ),
            _buildBattleStatLine(
              context: context,
              label: 'DEF',
              value: hero.defense,
              icon: const Icon(Icons.shield, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleHeroPanel({
    required BuildContext context,
    required HeroModel hero,
    required int currentHp,
    required bool active,
    required int shakeTick,
  }) {
    return _DamageShake(
      trigger: shakeTick,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: _buildHeroImage(hero, context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hero.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey('$currentHp-${hero.id}'),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'HP: $currentHp / ${hero.maxHp}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required Widget icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: label,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: icon,
      ),
    );
  }

  Widget _buildSetupHeroSlot({
    required BuildContext context,
    required DeckProvider deck,
    required HeroModel hero,
    required bool selected,
  }) {
    final currentIndex = deck.battleTeam.indexWhere((h) => h.id == hero.id);

    return SizedBox(
      width: 200,
      height: 292,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            if (_selectedSetupHeroId == null) {
              _selectedSetupHeroId = hero.id;
              return;
            }

            if (_selectedSetupHeroId == hero.id) {
              _selectedSetupHeroId = null;
              return;
            }

            final firstIndex = deck.battleTeam.indexWhere((h) => h.id == _selectedSetupHeroId);
            if (firstIndex != -1 && currentIndex != -1) {
              deck.swapBattleTeamHeroes(firstIndex, currentIndex);
            }
            _selectedSetupHeroId = null;
          });
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.45),
              width: selected ? 2.2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 222,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: _buildHeroImage(hero, context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hero.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupView(BuildContext context, DeckProvider deck) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Battle Team: ${deck.battleTeamSize}/${DeckProvider.maxBattleTeamSize}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: deck.battleTeam.map((hero) {
                  return _buildSetupHeroSlot(
                    context: context,
                    deck: deck,
                    hero: hero,
                    selected: hero.id == _selectedSetupHeroId,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: FilledButton(
                  onPressed: deck.isBattleTeamReady ? () => _startBattleSequence(deck) : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text('Deploy To Arena'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(strokeWidth: 4),
              ),
              const SizedBox(height: 16),
              Text('Deploying to Battle Arena', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              const Text('Preparing heroes and generating the AI team...'),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return LinearProgressIndicator(value: _loadingController.value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArenaView(BuildContext context, DeckProvider deck, BattleProvider battle) {
    final playerHero = battle.playerHero;
    final aiHero = battle.aiHero;
    if (playerHero == null || aiHero == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final busy = battle.isBusy || battle.awaitingPlayerSwitch || battle.playerWon != null;

    return SafeArea(
      child: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTeamStatus(
                            context: context,
                            title: 'Your Team',
                            heroes: battle.playerTeam,
                            battle: battle,
                            isPlayer: true,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _buildTeamStatus(
                            context: context,
                            title: 'AI Team',
                            heroes: battle.aiTeam,
                            battle: battle,
                            isPlayer: false,
                            alignToEnd: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBattleHeroPanel(
                                context: context,
                                hero: playerHero,
                                currentHp: battle.playerHp,
                                active: true,
                                shakeTick: battle.playerShakeTick,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildBattleHeroPanel(
                                context: context,
                                hero: aiHero,
                                currentHp: battle.aiHp,
                                active: true,
                                shakeTick: battle.aiShakeTick,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Align(
                            alignment: Alignment.center,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildActionButton(
                                  context: context,
                                  icon: const Text('⚔', style: TextStyle(fontSize: 20, height: 1)),
                                  label: 'Attack',
                                  onPressed: busy ? null : () => battle.performPlayerAction(BattleActionType.attack),
                                ),
                                _buildActionButton(
                                  context: context,
                                  icon: const Icon(Icons.auto_awesome),
                                  label: 'Special Attack',
                                  onPressed: busy || battle.playerSpecialsRemaining <= 0
                                      ? null
                                      : () => battle.performPlayerAction(BattleActionType.special),
                                ),
                                _buildActionButton(
                                  context: context,
                                  icon: const Icon(Icons.shield),
                                  label: 'Defense',
                                  onPressed: busy || !battle.playerShieldAvailable
                                      ? null
                                      : battle.useDefense,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(flex: 5, child: SizedBox.shrink()),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Transform.translate(
                      offset: const Offset(0, 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildBattleStatCard(
                              context: context,
                              hero: playerHero,
                              isPlayer: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildBattleStatCard(
                              context: context,
                              hero: aiHero,
                              isPlayer: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 38, 12, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: Container(
                      key: ValueKey(battle.briefing),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        battle.briefing,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (battle.playerWon != null)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: Card(
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          battle.playerWon == true ? 'VICTORY!' : 'DEFEAT!',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Winner: ${battle.playerWon == true ? 'Player' : 'AI'}'),
                                Text('Final Score: ${battle.finalScore}'),
                                Text('MVP Hit: ${battle.mvpHero.isEmpty ? 'N/A' : '${battle.mvpHero} (${battle.mvpDamage})'}'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: () {
                                battle.resetBattle();
                                setState(() {
                                  _stage = _BattleStage.setup;
                                  _loadingController.reset();
                                  _selectedSetupHeroId = deck.battleTeam.isNotEmpty ? deck.battleTeam.first.id : null;
                                });
                              },
                              child: const Text('New Battle'),
                            ),
                            OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Back'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle Arena')),
      body: Consumer2<DeckProvider, BattleProvider>(
        builder: (context, deck, battle, _) {
          if (deck.battleTeamSize < DeckProvider.maxBattleTeamSize) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select 5 heroes in Deck Builder before starting the battle.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pushNamed(context, RouteNames.deckBuilder),
                      child: const Text('Go to Deck Builder'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_stage == _BattleStage.setup) {
            return _buildSetupView(context, deck);
          }

          if (_stage == _BattleStage.loading) {
            return _buildLoadingView(context);
          }

          return _buildArenaView(context, deck, battle);
        },
      ),
    );
  }
}

class _DamageShake extends StatefulWidget {
  const _DamageShake({required this.child, required this.trigger});

  final Widget child;
  final int trigger;

  @override
  State<_DamageShake> createState() => _DamageShakeState();
}

class _DamageShakeState extends State<_DamageShake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _DamageShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = _controller.value;
        final damping = Curves.easeOut.transform(progress);
        final amplitude = (1 - damping) * 8;
        final x = math.sin(progress * math.pi * 10) * amplitude;
        final y = math.sin(progress * math.pi * 6) * amplitude * 0.12;
        return Transform.translate(
          offset: Offset(x, y),
          child: child,
        );
      },
    );
  }
}
