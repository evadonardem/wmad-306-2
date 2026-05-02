import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../engine/battle_engine.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});
  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  final _api = SuperheroApiService(apiToken: kApiToken);
  final _logController = ScrollController();
  bool _fetchingAi = false;
  String? _fetchError;

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  // ── Start battle: fetch random AI hero ──────────────────────────────────
  Future<void> _startBattle(HeroModel playerHero) async {
    setState(() { _fetchingAi = true; _fetchError = null; });
    try {
      final id = Random().nextInt(731) + 1;
      final aiHero = await _api.fetchHero(id);
      if (!mounted) return;
      context.read<BattleProvider>().startBattle(playerHero, aiHero);
    } catch (e) {
      if (!mounted) return;
      setState(() => _fetchError = 'Could not fetch opponent: $e');
    } finally {
      if (mounted) setState(() => _fetchingAi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fetchingAi) return _buildLoading();

    return Consumer<BattleProvider>(
      builder: (_, battle, __) {
        if (battle.state == null) return _buildHeroSelection();
        return _buildArena(battle);
      },
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading() => Scaffold(
        appBar: AppBar(title: const Text('Battle Arena')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Summoning your opponent…'),
              if (_fetchError != null) ...[
                const SizedBox(height: 12),
                Text(_fetchError!,
                    style: const TextStyle(color: Colors.redAccent)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => setState(() => _fetchError = null),
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      );

  // ── Hero selection ───────────────────────────────────────────────────────
  Widget _buildHeroSelection() => Scaffold(
        appBar: AppBar(title: const Text('Select Your Fighter')),
        body: Consumer<DeckProvider>(
          builder: (_, deck, __) {
            if (deck.deck.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Your deck is empty!',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text('Add heroes to your deck before battling.',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Build Deck'),
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, RouteNames.deckBuilder),
                    ),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Who will you send into battle?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: deck.deck.length,
                    itemBuilder: (_, i) => HeroCard(
                      hero: deck.deck[i],
                      onTap: () => _startBattle(deck.deck[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

  // ── Battle arena ─────────────────────────────────────────────────────────
  Widget _buildArena(BattleProvider battle) {
    final state = battle.state!;

    // Auto-scroll log to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_logController.hasClients) {
        _logController.animateTo(
          _logController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Round ${state.round}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            battle.reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // ── VS panels ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: _HeroPanel(
                        hero: state.playerHero,
                        hp: state.playerHp,
                        maxHp: state.playerMaxHp,
                        label: 'YOU',
                        labelColor: Colors.greenAccent)),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text('VS',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.primary)),
                ),
                Expanded(
                    child: _HeroPanel(
                        hero: state.aiHero,
                        hp: state.aiHp,
                        maxHp: state.aiMaxHp,
                        label: 'CPU',
                        labelColor: Colors.redAccent)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Battle log ─────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListView.builder(
                controller: _logController,
                itemCount: state.battleLog.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    state.battleLog[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: i < 3
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: _logEntryColor(
                          state.battleLog[i], state.playerHero.name),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Actions / result ────────────────────────────────────────
          if (state.isOver)
            _buildResult(state, battle)
          else if (battle.isProcessing || !state.isPlayerTurn)
            const _ThinkingIndicator()
          else
            _buildActions(battle),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActions(BattleProvider battle) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: battle.isProcessing ? null : battle.playerAttack,
                icon: const Icon(Icons.flash_on),
                label: const Text('Attack'),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: Colors.white24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.tertiary,
                  foregroundColor: Colors.white,
                ),
                onPressed: battle.isProcessing ? null : battle.playerSpecial,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Special'),
              ),
            ),
          ],
        ),
      );

  Widget _buildResult(BattleState state, BattleProvider battle) {
    final won = state.playerWon;

    // Track win/loss in PlayerProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (won) {
        context.read<PlayerProvider>().recordWin();
      } else {
        context.read<PlayerProvider>().recordLoss();
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            won ? '🏆  Victory!' : '💀  Defeat!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: won ? Colors.amber : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Exit'),
                  onPressed: () {
                    battle.reset();
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.replay),
                  label: const Text('Again!'),
                  onPressed: () {
                    battle.reset();
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _logEntryColor(String entry, String playerName) {
    if (entry.contains('🏆')) return Colors.amber;
    if (entry.contains('💀')) return Colors.redAccent;
    if (entry.contains('✨') && entry.contains(playerName)) {
      return Colors.purpleAccent;
    }
    if (entry.contains('✨')) return Colors.deepOrangeAccent;
    if (entry.contains('MISSED')) return Colors.orange;
    if (entry.contains(playerName) && entry.contains('attack')) {
      return Colors.lightBlueAccent;
    }
    if (entry.contains('⚔️') || entry.contains('Battle begins')) {
      return Colors.white70;
    }
    return Colors.white54;
  }
}

// ── Hero panel widget ─────────────────────────────────────────────────────

class _HeroPanel extends StatelessWidget {
  final HeroModel hero;
  final int hp, maxHp;
  final String label;
  final Color labelColor;

  const _HeroPanel({
    required this.hero,
    required this.hp,
    required this.maxHp,
    required this.label,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: hero.imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 110,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, size: 48),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 110,
                    color: Colors.grey[800],
                    child: const Icon(Icons.person, size: 48),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: labelColor.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            hero.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          HpBar(current: hp, max: maxHp, height: 9),
        ],
      );
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Opponent is thinking…', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
}
