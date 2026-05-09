// Exercise 1 — list & delete saved decks from SQLite.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/deck_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/_neon.dart';

class SavedDecksScreen extends StatefulWidget {
  const SavedDecksScreen({super.key});
  @override
  State<SavedDecksScreen> createState() => _SavedDecksScreenState();
}

class _SavedDecksScreenState extends State<SavedDecksScreen> {
  // Stored in field per the rubric — never created in build().
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseService().loadDecks();
  }

  void _refresh() {
    setState(() {
      _future = DatabaseService().loadDecks();
    });
  }

  Future<void> _delete(int id) async {
    await DatabaseService().deleteDeck(id);
    if (!mounted) return;
    _refresh();
  }

  Future<void> _load(Map<String, dynamic> row) async {
    final db = DatabaseService();
    final heroes = db.decodeDeckHeroes(row['heroes'] as String);
    if (!mounted) return;
    context.read<DeckProvider>().loadDeck(heroes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: kSurface,
        content: Text(
          '“${row['name']}” loaded into deck',
          style: const TextStyle(color: kNeonCyan),
        ),
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Decks')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: kNeonCyan),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: const TextStyle(color: kNeonMagenta)),
            );
          }
          final rows = snap.data ?? const [];
          if (rows.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_border,
                      color: kNeonCyan, size: 64),
                  const SizedBox(height: 12),
                  Text(
                    'No saved decks yet',
                    style: kNeonTitle.copyWith(fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final r = rows[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: neonBorder(glow: 6),
                child: ListTile(
                  leading: const Icon(Icons.style, color: kNeonCyan),
                  title: Text(
                    r['name'] as String,
                    style: kNeonTitle.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    'Created ${(r['created'] as String).substring(0, 10)}',
                    style: const TextStyle(color: kTextDim, fontSize: 12),
                  ),
                  onTap: () => _load(r),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: kNeonMagenta),
                    onPressed: () => _delete(r['id'] as int),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
