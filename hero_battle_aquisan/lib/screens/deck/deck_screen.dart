import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class DeckScreen extends StatelessWidget {
  const DeckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deck'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear Deck',
            onPressed: () => context.read<DeckProvider>().clearDeck(),
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          if (deckProvider.deckSize == 0) {
            return const Center(
              child: Text(
                'Your deck is empty. Add heroes from the Home screen.',
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Heroes: ${deckProvider.deckSize} / 5',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: deckProvider.deckSize,
                  itemBuilder: (context, index) {
                    return HeroCard(hero: deckProvider.deck[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      icon: const Icon(Icons.save),
                      label: const Text('Save Deck (Exercise 1)'),
                      onPressed: () async {
                        if (deckProvider.deckSize == 0) return;
                        final success = await deckProvider.saveDeckToDb('My Custom Deck');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? 'Deck saved to SQLite!' : 'Failed to save deck.'),
                              backgroundColor: success ? null : Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.redAccent,
                      ),
                      icon: const Icon(Icons.sports_martial_arts),
                      label: const Text('Fight Now'),
                      onPressed: deckProvider.deckSize < 5
                          ? null
                          : () async {
                              final battleProvider = context.read<BattleProvider>();
                              final playerDeck = List.of(deckProvider.deck);
                              // Fix: count is a named parameter. Increased to 15 to ensure we get 5 unique opponents.
                              final aiDeck = (await SuperheroApiService(apiToken: '').fetchRandomHeroes(count: 15))
                                  .where((hero) => !playerDeck
                                      .any((playerHero) => playerHero.id == hero.id))
                                  .take(5)
                                  .toList();

                              if (aiDeck.length < 5) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Not enough unique heroes found for AI. Try again!')),
                                  );
                                }
                                return;
                              }

                              battleProvider.startBattle(playerDeck, aiDeck);
                              if (context.mounted) {
                                Navigator.pushNamed(context, RouteNames.battle);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
