import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/database_service.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  void _saveDeck(BuildContext context, DeckProvider deck) async {
    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter deck name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (confirmed == true && nameController.text.isNotEmpty) {
      await deck.saveDeckToDb(nameController.text.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deck "${nameController.text}" saved!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedDecksScreen()),
            ),
            icon: const Icon(Icons.folder_open),
            label: const Text('Saved'),
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${deck.deckSize} / ${DeckProvider.maxDeckSize} Heroes',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: deck.deck.isEmpty
                  ? const Center(child: Text('No heroes in deck.\nBrowse the roster to add some!',
                      textAlign: TextAlign.center))
                  : ListView.builder(
                      itemCount: deck.deck.length,
                      itemBuilder: (context, i) {
                        final hero = deck.deck[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: hero.imageUrl.isNotEmpty
                                ? NetworkImage(hero.imageUrl)
                                : null,
                            child: hero.imageUrl.isEmpty ? const Icon(Icons.person) : null,
                          ),
                          title: Text(hero.name),
                          subtitle: Text('HP: ${hero.maxHp} | ATK: ${hero.attack}'),
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
                    child: ElevatedButton.icon(
                      onPressed: deck.deck.isEmpty ? null : () => _saveDeck(context, deck),
                      icon: const Icon(Icons.save),
                      label: const Text('Save Deck'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: deck.isReady
                          ? () => Navigator.pushNamed(context, RouteNames.battle)
                          : null,
                      icon: const Icon(Icons.bolt),
                      label: const Text('Battle!'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Exercise 1 — SavedDecksScreen
class SavedDecksScreen extends StatefulWidget {
  const SavedDecksScreen({super.key});

  @override
  State<SavedDecksScreen> createState() => _SavedDecksScreenState();
}

class _SavedDecksScreenState extends State<SavedDecksScreen> {
  late Future<List<Map<String, dynamic>>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = DatabaseService().loadDecks();
  }

  void _refresh() => setState(() {
    _decksFuture = DatabaseService().loadDecks();
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Decks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text('No saved decks yet.'));
          final decks = snapshot.data!;
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, i) {
              final deck = decks[i];
              final heroes = (jsonDecode(deck['heroes'] as String) as List)
                  .map((h) => HeroModel.fromJson(h as Map<String, dynamic>))
                  .toList();
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text(deck['name'] as String),
                  subtitle: Text('${heroes.length} heroes · ${deck['created'].toString().substring(0, 10)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseService().deleteDeck(deck['id'] as int);
                      _refresh();
                    },
                  ),
                  children: heroes
                      .map((h) => ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(h.name),
                            subtitle: Text('HP: ${h.maxHp} | ATK: ${h.attack}'),
                          ))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}