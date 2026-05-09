import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/deck_provider.dart';
import 'saved_decks_screen.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  Future<void> _showSaveDialog(BuildContext context, DeckProvider deck) async {
    if (!deck.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one hero before saving.')),
      );
      return;
    }

    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Save Deck'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Deck name',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final deckName = (name ?? '').trim();
    if (deckName.isEmpty) return;

    await deck.saveDeckToDb(deckName);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deck "$deckName" saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Saved Decks',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedDecksScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Current deck: ${deck.deckSize}/${DeckProvider.maxDeckSize}'),
                ),
              ),
              Expanded(
                child: deck.deck.isEmpty
                    ? const Center(
                        child: Text(
                          'No heroes in deck yet.\nOpen Hero Roster, tap a hero card, then Add to Deck.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: deck.deck.length,
                        itemBuilder: (context, index) {
                          final hero = deck.deck[index];
                          return ListTile(
                            title: Text(hero.name),
                            subtitle: Text('ATK ${hero.attack} • HP ${hero.maxHp}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => deck.removeHero(hero),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: deck.isReady ? deck.clearDeck : null,
                        child: const Text('Clear Deck'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _showSaveDialog(context, deck),
                        child: const Text('Save Deck'),
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
