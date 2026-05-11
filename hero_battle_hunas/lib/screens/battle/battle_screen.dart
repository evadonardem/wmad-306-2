import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../providers/player_provider.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final Future<void> _battle;

  @override
  void initState() {
    super.initState();
    _battle = _start();
  }

  Future<void> _start() async {
    final deck = context.read<DeckProvider>().heroes;
    final opponents =
        await context.read<HeroSearchProvider>().randomOpponents(deck.length);
    if (!mounted) return;
    await context
        .read<BattleProvider>()
        .startBattle(playerDeck: deck, opponents: opponents);
    if (!mounted) return;
    final result = context.read<BattleProvider>().result;
    if (result?.didWin ?? false) context.read<PlayerProvider>().incrementWins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: FutureBuilder<void>(
        future: _battle,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          return Consumer<BattleProvider>(
            builder: (context, battle, _) {
              final result = battle.result;
              if (result == null) return const Center(child: Text('No battle.'));
              final maxScore = result.playerScore > result.opponentScore
                  ? result.playerScore
                  : result.opponentScore;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Icon(
                    result.didWin ? Icons.emoji_events : Icons.shield,
                    size: 64,
                  ),
                  Center(
                    child: Text(
                      result.didWin ? 'Victory' : 'Defeat',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  HpBar(label: 'Your score', value: result.playerScore, max: maxScore),
                  const SizedBox(height: 12),
                  HpBar(
                    label: 'Opponent score',
                    value: result.opponentScore,
                    max: maxScore,
                  ),
                  const Divider(height: 32),
                  ...result.rounds.map((round) => ListTile(title: Text(round))),
                  if (battle.isSaving)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: Text('Saving battle...')),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
