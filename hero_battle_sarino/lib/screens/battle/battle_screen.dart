import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hp_bar.dart';

class BattleScreen extends StatelessWidget {
  const BattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final battle = context.watch<BattleProvider>();

    if (!battle.isBattleActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('Battle')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                deck.deck.isEmpty
                    ? 'Add a hero to your deck first.'
                    : 'Ready to start a battle? Use your first selected hero.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (deck.deck.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    final playerHero = deck.deck[0];
                    final aiHero = deck.deck.length > 1
                        ? deck.deck[1]
                        : _defaultAiHero();
                    context.read<BattleProvider>().startBattle(
                      playerHero,
                      aiHero,
                    );
                  },
                  child: const Text('Start Battle'),
                ),
            ],
          ),
        ),
      );
    }

    final battleOver = battle.playerHp <= 0 || battle.aiHp <= 0;
    final winnerText = battleOver
        ? (battle.playerHp > 0 ? 'Player wins!' : 'AI wins!')
        : (battle.isPlayerTurn ? 'Your turn' : 'AI turn');

    return Scaffold(
      appBar: AppBar(title: const Text('Battle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              battle.aiHero!.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            HpBar(currentHp: battle.aiHp, maxHp: battle.aiHero!.maxHp),
            const SizedBox(height: 32),
            Text(
              battle.playerHero!.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            HpBar(currentHp: battle.playerHp, maxHp: battle.playerHero!.maxHp),
            const SizedBox(height: 32),
            Text('Round: ${battle.round}'),
            Text(winnerText),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: battle.isPlayerTurn && !battleOver
                  ? () => context.read<BattleProvider>().attack()
                  : null,
              child: Text(battleOver ? 'Battle Over' : 'Attack'),
            ),
            if (battleOver) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<DeckProvider>().clearDeck();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Deck'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(child: Text(battle.battleLog)),
            ),
          ],
        ),
      ),
    );
  }

  HeroModel _defaultAiHero() {
    return HeroModel(
      id: 'ai-1',
      name: 'AI Opponent',
      imageUrl: HeroModel.cartoonImageUrl('AI Opponent'),
      powerStats: const PowerStats(
        intelligence: 70,
        strength: 80,
        speed: 70,
        durability: 80,
        power: 75,
        combat: 75,
      ),
      publisher: 'Neutral',
      alignment: 'neutral',
      fullName: 'AI Opponent',
    );
  }
}
