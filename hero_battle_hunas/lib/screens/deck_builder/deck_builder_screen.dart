import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_card.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  final _nameController = TextEditingController(text: 'My Deck');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeckProvider>().loadSavedDecks();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deck Builder')),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('${deck.heroes.length}/${DeckProvider.maxDeckSize} heroes'),
              const SizedBox(height: 8),
              if (deck.heroes.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Add heroes from the roster.')),
                )
              else
                ...deck.heroes.map(
                  (hero) => HeroCard(
                    hero: hero,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deck.removeHero(hero),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Deck name'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Deck'),
                onPressed: deck.heroes.isEmpty
                    ? null
                    : () => deck.saveCurrentDeck(_nameController.text),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.sports_mma),
                label: const Text('Start Battle'),
                onPressed: deck.canBattle
                    ? () => Navigator.pushNamed(context, RouteNames.battle)
                    : null,
              ),
              const Divider(height: 32),
              Text('Saved Decks', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (deck.savedDecks.isEmpty)
                const Text('No saved decks yet.')
              else
                ...deck.savedDecks.map(
                  (saved) => ListTile(
                    title: Text(saved.name),
                    subtitle: Text('${saved.heroes.length} heroes'),
                    leading: const Icon(Icons.folder),
                    onTap: () => deck.loadDeck(saved.heroes),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deck.deleteSavedDeck(saved.id),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
