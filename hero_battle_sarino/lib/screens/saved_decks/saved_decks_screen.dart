import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/hero_model.dart';
import '../../services/database_service.dart';

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
    _loadDecks();
  }

  void _loadDecks() {
    _decksFuture = DatabaseService().loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Decks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final decks = snapshot.data!;
          if (decks.isEmpty) {
            return const Center(child: Text('No saved decks'));
          }
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, i) {
              final deck = decks[i];
              final heroes = (jsonDecode(deck['heroes']) as List)
                  .map((h) => HeroModel.fromJson(h))
                  .toList();
              return ListTile(
                title: Text(deck['name']),
                subtitle: Text('${heroes.length} heroes'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteDeck(deck['id'] as int),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteDeck(int id) async {
    await DatabaseService().deleteDeck(id);
    if (!mounted) return;
    setState(_loadDecks);
  }
}
