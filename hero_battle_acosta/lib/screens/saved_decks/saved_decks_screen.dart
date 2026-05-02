import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../models/hero_model.dart';
import '../../services/database_service.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';

class SavedDecksScreen extends StatelessWidget {
  const SavedDecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Decks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService().loadDecks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 10),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final decks = snapshot.data ?? [];

          if (decks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No saved decks yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create and save a deck from the Deck Builder',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              final deckId = deck['id'] as int;
              final deckName = deck['name'] as String;
              final heroesJson = deck['heroes'] as String;
              final created = deck['created'] as String;

              // Parse heroes from JSON
              final heroesData = jsonDecode(heroesJson) as List<dynamic>;
              final heroes = heroesData
                  .map((h) => HeroModel.fromJson(h as Map<String, dynamic>))
                  .toList();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with name and actions
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deckName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created: ${DateTime.parse(created).day}/${DateTime.parse(created).month}/${DateTime.parse(created).year}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
              // Load button
                              IconButton.filled(
                                onPressed: () {
                                  try {
                                    // Load deck into current deck
                                    context.read<DeckProvider>().clearDeck();
                                    for (final hero in heroes) {
                                      context.read<DeckProvider>().addHero(hero);
                                    }
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Loaded "$deckName" (${heroes.length} heroes)'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    
                                    // Navigate back to Deck Builder
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                    Navigator.pushNamed(context, RouteNames.deckBuilder);
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error loading deck: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.download),
                                tooltip: 'Load Deck',
                              ),
                              const SizedBox(width: 8),
                              // Delete button
                              IconButton.filledTonal(
                                onPressed: () async {
                                  // Confirm deletion
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Deck'),
                                      content: Text('Are you sure you want to delete "$deckName"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed == true) {
                                    await DatabaseService().deleteDeck(deckId);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Deck deleted')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete Deck',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Heroes grid
                    Container(
                      height: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: heroes.length,
                        itemBuilder: (context, heroIndex) {
                          final hero = heroes[heroIndex];
                          return Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey[900],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        hero.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[800],
                                            child: const Center(
                                              child: Icon(Icons.person, color: Colors.grey),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hero.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
