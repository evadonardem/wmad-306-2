import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class SavedDecksScreen extends StatefulWidget {
  const SavedDecksScreen({super.key});

  @override
  State<SavedDecksScreen> createState() => _SavedDecksScreenState();
}

class _SavedDecksScreenState extends State<SavedDecksScreen> {
  late Future<List<SavedDeck>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseService().loadDecks();
  }

  void _reload() {
    setState(() {
      _future = DatabaseService().loadDecks();
    });
  }

  Future<void> _delete(int id) async {
    await DatabaseService().deleteDeck(id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Decks')),
      body: FutureBuilder<List<SavedDeck>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final decks = snapshot.data ?? [];
          if (decks.isEmpty) {
            return const Center(child: Text('No saved decks yet.'));
          }
          return ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, i) {
              final deck = decks[i];
              return ListTile(
                title: Text(deck.name),
                subtitle: Text(deck.heroes.map((h) => h.name).join(', ')),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(deck.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
