import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class SavedDecksScreen extends StatefulWidget {
  const SavedDecksScreen({super.key});

  @override
  State<SavedDecksScreen> createState() => _SavedDecksScreenState();
}

class _SavedDecksScreenState extends State<SavedDecksScreen> {
  late Future<List<Map<String, dynamic>>> _savedDecksFuture;

  @override
  void initState() {
    super.initState();
    _savedDecksFuture = DatabaseService().loadDecks();
  }

  void _reload() {
    setState(() {
      _savedDecksFuture = DatabaseService().loadDecks();
    });
  }

  Future<void> _deleteDeck(int id) async {
    await DatabaseService().deleteDeck(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved deck deleted.')),
    );
    _reload();
  }

  int _heroCountFromJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded.length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Decks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
            return const Center(child: Text('No saved decks yet.'));
          }

          return ListView.separated(
            itemCount: decks.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final row = decks[index];
              final id = row['id'] as int;
              final name = row['name'] as String? ?? 'Unnamed Deck';
              final created = row['created'] as String? ?? '';
              final heroesJson = row['heroes'] as String? ?? '[]';
              final count = _heroCountFromJson(heroesJson);

              return ListTile(
                title: Text(name),
                subtitle: Text('Heroes: $count\nCreated: $created'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteDeck(id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
