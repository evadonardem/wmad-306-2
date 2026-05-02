import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/database_service.dart';
import '../../widgets/hero_card.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deck Builder')),
      floatingActionButton: Consumer<DeckProvider>(
        builder: (context, deck, _) => deck.isReady
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.pushNamed(context, RouteNames.battle),
                icon: const Icon(Icons.sports_martial_arts),
                label: const Text('Battle'),
              )
            : const SizedBox.shrink(),
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          if (deck.deck.isEmpty) {
            return const Center(
              child: Text('No heroes in deck. Add heroes from the home screen.'),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Deck size: ${deck.deckSize}/${DeckProvider.maxDeckSize}',
                      ),
                    ),
                    TextButton(
                      onPressed: deck.clearDeck,
                      child: const Text('Clear'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showLoadDialog(context, deck),
                      child: const Text('Load Deck'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showSaveDialog(context, deck),
                      child: const Text('Save Deck'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: deck.isReady ? () => _showAutoSaveDialog(context, deck) : null,
                      child: const Text('Auto Save'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: deck.deck.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) => HeroCard(hero: deck.deck[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showSaveDialog(BuildContext context, DeckProvider deck) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty || !context.mounted) return;

    try {
      await deck.saveDeckToDb(name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deck "$name" saved.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save deck: $e')),
      );
    }
  }

  Future<void> _showLoadDialog(BuildContext context, DeckProvider deck) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final selectedAction = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Deck'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService().loadDecks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                width: double.maxFinite,
                height: 140,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return SizedBox(
                width: double.maxFinite,
                height: 140,
                child: Center(
                  child: Text('Failed to load saved decks: ${snapshot.error}'),
                ),
              );
            }
            final savedDecks = snapshot.data ?? [];
            if (savedDecks.isEmpty) {
              return const SizedBox(
                width: double.maxFinite,
                height: 140,
                child: Center(child: Text('No saved decks found.')),
              );
            }

            return SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: savedDecks.length,
                itemBuilder: (context, index) {
                  final deckData = savedDecks[index];
                  final name = deckData['name'] as String;
                  final created = DateTime.parse(deckData['created'] as String);
                  final heroesData = jsonDecode(deckData['heroes'] as String) as List;
                  final previewHeroes = heroesData
                      .map((h) => HeroModel.fromJson(h))
                      .toList();
                  return ExpansionTile(
                    title: Text(name),
                    subtitle: Text('Created: ${created.toLocal()}'),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      SizedBox(
                        height: 88,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: previewHeroes.length,
                          itemBuilder: (context, heroIndex) {
                            final hero = previewHeroes[heroIndex];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage:
                                        NetworkImage(hero.imageUrl),
                                    backgroundColor: Colors.white12,
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      hero.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      OverflowBar(
                        spacing: 8,
                        overflowAlignment: OverflowBarAlignment.start,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, {
                              'action': 'load',
                              'deck': deckData,
                            }),
                            child: const Text('Load'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, {
                              'action': 'rename',
                              'deck': deckData,
                            }),
                            child: const Text('Rename'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, {
                              'action': 'delete',
                              'deck': deckData,
                            }),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedAction == null || !navigator.mounted) return;

    final action = selectedAction['action'] as String?;
    final selectedDeck = selectedAction['deck'] as Map<String, dynamic>?;
    if (action == 'rename' && selectedDeck != null) {
      await _showRenameDialog(navigator, selectedDeck);
      return;
    }
    if (action == 'delete' && selectedDeck != null) {
      await _confirmDeleteDeck(navigator, selectedDeck['id'] as int);
      return;
    }
    if (action != 'load' || selectedDeck == null) return;

    final heroesJson = selectedDeck['heroes'] as String;
    final heroesData = jsonDecode(heroesJson) as List;
    final heroes = heroesData.map((h) => HeroModel.fromJson(h)).toList();

    deck.clearDeck();
    for (final hero in heroes) {
      deck.addHero(hero);
    }

    if (!navigator.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Deck "${selectedDeck['name']}" loaded.')),
    );
  }

  Future<void> _showRenameDialog(
      NavigatorState navigator, Map<String, dynamic> deckData) async {
    final controller = TextEditingController(text: deckData['name'] as String);
    final messenger = ScaffoldMessenger.of(navigator.context);
    final newName = await showDialog<String>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || !navigator.mounted) return;
    try {
      await DatabaseService().updateDeckName(deckData['id'] as int, newName);
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Deck renamed to "$newName".')),
      );
    } catch (e) {
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to rename deck: $e')),
      );
    }
  }

  Future<void> _confirmDeleteDeck(NavigatorState navigator, int deckId) async {
    final messenger = ScaffoldMessenger.of(navigator.context);
    final confirmed = await showDialog<bool>(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: const Text('Are you sure you want to delete this saved deck?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !navigator.mounted) return;
    try {
      await DatabaseService().deleteDeck(deckId);
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Saved deck deleted.')),
      );
    } catch (e) {
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to delete deck: $e')),
      );
    }
  }

  Future<void> _showAutoSaveDialog(BuildContext context, DeckProvider deck) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final slot = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto Save Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose a slot to save this deck automatically.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(3, (index) {
                final slotNumber = index + 1;
                return ElevatedButton(
                  onPressed: () => Navigator.pop(context, slotNumber),
                  child: Text('Slot $slotNumber'),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (slot == null || !navigator.mounted) return;
    final slotName = 'Slot $slot';
    try {
      await DatabaseService().saveOrUpdateDeck(slotName, deck.deck);
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Deck auto-saved to $slotName.')),
      );
    } catch (e) {
      if (!navigator.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to auto-save deck: $e')),
      );
    }
  }
}
