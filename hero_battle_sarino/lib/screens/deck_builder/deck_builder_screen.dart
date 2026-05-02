import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hero_card.dart';
import '../../router/app_router.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.savedDecks),
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Deck: ${deck.deckSize}/${DeckProvider.maxDeckSize}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: deck.deck.isEmpty
                    ? const Center(child: Text('No heroes in deck'))
                    : GridView.builder(
                        itemCount: deck.deck.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.7,
                            ),
                        itemBuilder: (context, i) =>
                            HeroCard(hero: deck.deck[i]),
                      ),
              ),
              if (deck.deck.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      final aiHero = deck.deck.length > 1
                          ? deck.deck[1]
                          : _defaultAiHero();
                      context.read<BattleProvider>().startBattle(
                        deck.deck[0],
                        aiHero,
                      );
                      Navigator.pushNamed(context, RouteNames.battle);
                    },
                    child: const Text('Start Battle'),
                  ),
                ),
              if (deck.isReady)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () => _saveDeck(context, deck),
                    child: const Text('Save Deck'),
                  ),
                ),
            ],
          );
        },
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

  void _saveDeck(BuildContext context, DeckProvider deck) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await deck.saveDeckToDb(name);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deck "$name" saved!')));
      }
    }
  }
}
