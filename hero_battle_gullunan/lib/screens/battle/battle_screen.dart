import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  bool _initialized = false;
  bool _attackAnimation = false;

  void _playAttackAnimation() {
    setState(() => _attackAnimation = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _attackAnimation = false);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    final deckProvider = context.read<DeckProvider>();
    final battleProvider = context.read<BattleProvider>();

    if (deckProvider.deck.isNotEmpty && battleProvider.playerTeam.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await battleProvider.initializeBattle(deckProvider.deck);
      });
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Consumer3<DeckProvider, BattleProvider, PlayerProvider>(
        builder: (context, deckProvider, battleProvider, playerProvider, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _buildBattleBackground(battleProvider),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.60),
                      Colors.black.withOpacity(0.88),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: _buildContent(
                  deckProvider,
                  battleProvider,
                  playerProvider.playerName,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBattleBackground(BattleProvider battleProvider) {
    if (battleProvider.backgroundUrl.isEmpty) {
      return Container(color: const Color(0xFF080A12));
    }

    return Image.network(
      battleProvider.backgroundUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(color: const Color(0xFF080A12));
      },
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF080A12)),
    );
  }

  Widget _buildBattleLog(BattleProvider battleProvider) {
    final lines = battleProvider.battleLog
        .trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12, width: 1.2),
      ),
      child: lines.isEmpty
          ? const Center(
              child: Text(
                'Battle log will appear here.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              itemCount: lines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                return Text(
                  lines[index],
                  softWrap: true,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.white,
                    height: 1.45,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildContent(
    DeckProvider deckProvider,
    BattleProvider battleProvider,
    String playerName,
  ) {
    if (deckProvider.deck.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No heroes selected for battle.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.deckBuilder),
                child: const Text('Return to Deck Builder'),
              ),
            ],
          ),
        ),
      );
    }

    if (battleProvider.choosingHero) {
      return _buildHeroSelection(battleProvider);
    }

    final playerHero = battleProvider.currentPlayerHero;
    final aiHero = battleProvider.currentAiHero;

    final actionButtons = Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: battleProvider.battleInProgress
                ? () {
                    _playAttackAnimation();
                    battleProvider.fightRound();
                  }
                : null,
            icon: const Icon(Icons.sports_martial_arts),
            label: Text(
              battleProvider.battleInProgress ? 'ATTACK' : 'BATTLE ENDED',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (!battleProvider.battleInProgress) {
                battleProvider.clearBattle();
                deckProvider.clearDeck();
              }
              Navigator.pushReplacementNamed(context, RouteNames.deckBuilder);
            },
            icon: Icon(
              battleProvider.battleInProgress ? Icons.arrow_back : Icons.replay,
            ),
            label: Text(
              battleProvider.battleInProgress ? 'BACK TO DECK' : 'PLAY AGAIN',
            ),
          ),
        ),
      ],
    );

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildHeroPanel(
                        playerName,
                        playerHero,
                        battleProvider.currentPlayerHp,
                        isPlayer: true,
                        isAttacking: _attackAnimation,
                        animationState: battleProvider.playerAnimationState,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildVsBadge(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildHeroPanel(
                        battleProvider.aiOpponentName,
                        aiHero,
                        battleProvider.currentAiHp,
                        isPlayer: false,
                        isAttacking: _attackAnimation,
                        animationState: battleProvider.aiAnimationState,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Rounds: ${battleProvider.roundsPlayed}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                flex: 3,
                child: _buildBattleLog(battleProvider),
              ),
              const SizedBox(height: 16),
              actionButtons,
            ],
          ),
        ),
        if (!battleProvider.battleInProgress && battleProvider.winner != null)
          _buildWinnerOverlay(battleProvider),
      ],
    );
  }

  Widget _buildHeroSelection(BattleProvider battleProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'A hero has fallen. Choose a stronger ally and deploy to continue the fight.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 280,
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.76,
            ),
            itemCount: battleProvider.playerTeam.length,
            itemBuilder: (context, index) {
              final hero = battleProvider.playerTeam[index];
              return Card(
                color: Colors.white.withValues(alpha: 0.08),
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20.0),
                        ),
                        child: hero.imageUrl.isNotEmpty
                            ? Image.network(
                                hero.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[850],
                                    child: const Center(
                                      child: Icon(Icons.broken_image, size: 48),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[850],
                                child: const Center(
                                  child: Icon(Icons.person, size: 50),
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hero.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  hero.rarity.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'HP ${hero.maxHp}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildHeroSelectStat('ATK', hero.attack),
                          const SizedBox(height: 6),
                          _buildHeroSelectStat('DEF', hero.defense),
                          const SizedBox(height: 6),
                          _buildHeroSelectStat('SPD', hero.initiative),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    RouteNames.heroDetail,
                                    arguments: hero,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white24,
                                    ),
                                  ),
                                  child: const Text('Stats'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    battleProvider.selectPlayerHero(hero);
                                  },
                                  icon: const Icon(Icons.outbound, size: 16),
                                  label: const Text('Deploy'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7B2FBE),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildHeroSelectStat(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showHeroStatsDialog(HeroModel hero, BattleProvider battleProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          title: Text(hero.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hero.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      hero.imageUrl,
                      fit: BoxFit.cover,
                      height: 180,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey[850],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hero.rarity.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailStat('HP', hero.maxHp.toString()),
                const SizedBox(height: 10),
                _buildDetailStat('Attack', hero.attack.toString()),
                const SizedBox(height: 10),
                _buildDetailStat('Defense', hero.defense.toString()),
                const SizedBox(height: 10),
                _buildDetailStat('Speed', hero.initiative.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                battleProvider.selectPlayerHero(hero);
                Navigator.pop(context);
              },
              child: const Text('Deploy Hero'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPanel(
    String title,
    HeroModel? hero,
    int currentHp, {
    bool isPlayer = true,
    bool isAttacking = false,
    required HeroAnimationState animationState,
  }) {
    double scale = 1.0;
    double opacity = 1.0;
    BoxDecoration? decoration;
    final primaryGlow = isPlayer
        ? const Color(0xFF7B2FBE)
        : const Color(0xFF23E6D1);
    final alive = hero != null && currentHp > 0;
    final hpPercent = hero == null || hero.maxHp == 0
        ? 0.0
        : currentHp / hero.maxHp;

    switch (animationState) {
      case HeroAnimationState.defeated:
        break;
      case HeroAnimationState.exiting:
        scale = 0.0;
        opacity = 0.0;
        break;
      case HeroAnimationState.entering:
        scale = 1.0;
        opacity = 1.0;
        decoration = BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryGlow.withValues(alpha: 0.20),
              blurRadius: 26,
              spreadRadius: 4,
            ),
          ],
        );
        break;
      case HeroAnimationState.normal:
        break;
    }

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 500),
      child: AnimatedOpacity(
        opacity: opacity,
        duration: const Duration(milliseconds: 500),
        child: Container(
          decoration: decoration,
          child: AnimatedScale(
            scale: isAttacking ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: Card(
              color: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: primaryGlow.withValues(alpha: 0.20),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: alive
                                    ? Colors.green.shade400
                                    : Colors.red.shade400,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                hero == null
                                    ? 'Waiting'
                                    : alive
                                    ? 'Ready'
                                    : 'Defeated',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: hero != null && hero.imageUrl.isNotEmpty
                                    ? Image.network(
                                        hero.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[850],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                ),
                                              ),
                                            ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[900],
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                hero?.name ?? 'Unknown Hero',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              if (hero != null) ...[
                                const Text(
                                  'HP',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: hpPercent,
                                  minHeight: 10,
                                  backgroundColor: Colors.white10,
                                  color: alive
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${currentHp.clamp(0, hero.maxHp)} / ${hero.maxHp}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildCompactStat(
                                      label: 'ATK',
                                      value: hero.attack,
                                    ),
                                    _buildCompactStat(
                                      label: 'DEF',
                                      value: hero.defense,
                                    ),
                                    _buildCompactStat(
                                      label: 'SPD',
                                      value: hero.initiative,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (animationState == HeroAnimationState.defeated)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.close,
                              size: 80,
                              color: Colors.redAccent,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'DEFEATED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat({required String label, required int value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallStat({required String label, required int value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $value',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (value.clamp(0, 100)) / 100,
            minHeight: 10,
            backgroundColor: Colors.white12,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildVsBadge() {
    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: Text(
          'VS',
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerOverlay(BattleProvider battleProvider) {
    final winner = battleProvider.winner;
    String title;
    String subtitle;
    Color accentColor;
    IconData resultIcon;

    switch (winner) {
      case 'player':
        title = 'VICTORY!';
        subtitle = 'Your team has won the battle!';
        accentColor = Colors.green.shade600;
        resultIcon = Icons.emoji_events;
        break;
      case 'ai':
        title = 'DEFEAT';
        subtitle = 'The AI has won this round. Try again!';
        accentColor = Colors.red.shade600;
        resultIcon = Icons.sentiment_very_dissatisfied;
        break;
      case 'draw':
        title = 'DRAW';
        subtitle = 'Both teams were eliminated!';
        accentColor = Colors.amber.shade700;
        resultIcon = Icons.handshake;
        break;
      default:
        title = 'Battle Ended';
        subtitle = 'The battle has finished.';
        accentColor = Colors.grey.shade700;
        resultIcon = Icons.done;
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(resultIcon, size: 80, color: accentColor),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: accentColor,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    battleProvider.clearBattle();
                    context.read<DeckProvider>().clearDeck();
                    Navigator.pushReplacementNamed(
                      context,
                      RouteNames.deckBuilder,
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
