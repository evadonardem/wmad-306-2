import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/player_provider.dart';
import '../../screens/home/home_screen.dart'; // for kApiToken
import '../../services/superhero_api_service.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _startBattle();
  }

  Future<void> _startBattle() async {
    final deck = context.read<DeckProvider>();
    final battle = context.read<BattleProvider>();
    battle.reset();

    if (deck.deck.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    // Pick a random hero from deck as player hero
    final playerHero = deck.deck.first;

    // Fetch a random AI opponent
    final api = SuperheroApiService(apiToken: kApiToken);
    final ids = List.generate(731, (i) => i + 1)..shuffle();
    final aiHero = await api.fetchHero(ids.first);

    battle.startBattle(playerHero, aiHero);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Battle!')),
      body: Consumer2<BattleProvider, PlayerProvider>(
        builder: (context, battle, player, _) {
          if (battle.playerHero == null) {
            return const Center(child: Text('No hero selected. Add heroes to your deck first.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Round ${battle.round}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                HpBar(
                  label: '${player.playerName} — ${battle.playerHero!.name}',
                  current: battle.playerHp,
                  max: battle.playerHero!.maxHp,
                ),
                const SizedBox(height: 8),
                HpBar(
                  label: 'AI — ${battle.aiHero!.name}',
                  current: battle.aiHp,
                  max: battle.aiHero!.maxHp,
                ),
                const SizedBox(height: 16),
                if (battle.battleOver)
                  Text(
                    battle.playerWon ? '🏆 You Win!' : '💀 You Lost!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                if (!battle.battleOver)
                  ElevatedButton.icon(
                    onPressed: () => battle.attackRound(),
                    icon: const Icon(Icons.sports_martial_arts),
                    label: const Text('Attack!'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                if (battle.battleOver)
                  ElevatedButton(
                    onPressed: () {
                      if (battle.playerWon) context.read<PlayerProvider>().incrementWins();
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Deck'),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      reverse: true,
                      children: battle.battleLog
                          .reversed
                          .map((log) => Text(log, style: const TextStyle(fontSize: 12)))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}