import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../services/database_service.dart';
import '../../models/hero_model.dart';
import '../../router/app_router.dart';
import 'dart:convert';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  final _deckNameController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _savedDecksFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedDecks();
  }

  void _loadSavedDecks() {
    _savedDecksFuture = DatabaseService().loadDecks();
  }

  void _showSaveDeckDialog() {
    _deckNameController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: _deckNameController,
          decoration: const InputDecoration(hintText: 'Enter deck name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _deckNameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a deck name')),
                );
                return;
              }
              await context.read<DeckProvider>().saveDeckToDb(name);
              if (mounted) {
                Navigator.pop(context);
                setState(() => _loadSavedDecks());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deck "$name" saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deck Builder')),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Deck',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text('${deck.deckSize} / ${DeckProvider.maxDeckSize} heroes'),
                  const SizedBox(height: 12),
                  if (deck.deck.isEmpty)
                    const Center(child: Text('No heroes in deck'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: deck.deck.length,
                      itemBuilder: (context, i) {
                        final hero = deck.deck[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${i + 1}')),
                            title: Text(hero.name),
                            subtitle: Text('HP: ${hero.maxHp}'),
                            onTap: () => Navigator.pushNamed(
                              context,
                              RouteNames.heroDetail,
                              arguments: hero,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => deck.removeHero(hero),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: deck.isReady ? _showSaveDeckDialog : null,
                            child: const Text('Save Deck'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: deck.deck.isNotEmpty ? () => deck.clearDeck() : null,
                            child: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: deck.isReady ? () => Navigator.pushNamed(context, RouteNames.battle) : null,
                      child: const Text('⚔️ Start Battle', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Saved Decks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _savedDecksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final decks = snapshot.data ?? [];
                if (decks.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No saved decks')),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: decks.length,
                  itemBuilder: (context, i) {
                    final deckData = decks[i];
                    final heroesJson = jsonDecode(deckData['heroes'] as String);
                    final heroes = (heroesJson as List)
                        .map((h) => HeroModel.fromJson(h as Map<String, dynamic>))
                        .toList();
                    return Card(
                      child: ListTile(
                        title: Text(deckData['name']),
                        subtitle: Text('${heroes.length} heroes'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () async {
                            await DatabaseService().deleteDeck(deckData['id']);
                            if (mounted) {
                              setState(() => _loadSavedDecks());
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }
}

