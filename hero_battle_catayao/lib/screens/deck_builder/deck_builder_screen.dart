import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  Future<void> _saveDeck(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Deck name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || name == null || name.trim().isEmpty) return;
    await context.read<DeckProvider>().saveDeckToDb(name.trim());
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${name.trim()} saved.')));
  }

  Future<void> _startBattle(BuildContext context) async {
    final deck = context.read<DeckProvider>().deck;
    if (deck.isEmpty) return;
    final aiHero = await SuperheroApiService(apiToken: kApiToken).fetchHero(70);
    if (!context.mounted) return;
    context.read<BattleProvider>().startBattle(deck.first, aiHero);
    Navigator.pushNamed(context, RouteNames.battle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.savedDecks),
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          if (deck.deck.isEmpty) {
            return const Center(child: Text('Add heroes from the roster.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${deck.deckSize}/${DeckProvider.maxDeckSize} heroes',
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: deck.deck.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) => HeroCard(hero: deck.deck[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _saveDeck(context),
                        child: const Text('Save Deck'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _startBattle(context),
                        child: const Text('Battle'),
                      ),
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
