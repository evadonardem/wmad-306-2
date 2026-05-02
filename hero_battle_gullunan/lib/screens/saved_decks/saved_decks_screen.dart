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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Decks'),
        centerTitle: true,
        backgroundColor: const Color(0xDD0F0F17),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF080A12),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService().loadDecks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }
          final decks = snapshot.data ?? [];
          if (decks.isEmpty) {
            return const Center(
              child: Text(
                'No saved decks yet',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              final deckId = deck['id'] as int;
              final deckName = deck['name'] as String;
              final heroesJson = jsonDecode(deck['heroes'] as String) as List;
              final createdAt = deck['created'] as String;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 1.2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  title: Text(
                    deckName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${heroesJson.length} heroes · $createdAt',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  trailing: PopupMenuButton(
                    color: const Color(0xFF12131A),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('View'),
                        onTap: () =>
                            _showDeckDetails(context, deckName, heroesJson),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => _deleteDeck(deckId, deckName),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeckDetails(
    BuildContext context,
    String deckName,
    List<dynamic> heroesJson,
  ) {
    final heroes = heroesJson
        .map((h) => HeroModel.fromJson(h as Map<String, dynamic>))
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(deckName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final hero in heroes)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hero.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'HP: ${hero.maxHp} | ATK: ${hero.attack}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteDeck(int deckId, String deckName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: Text('Delete "$deckName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseService().deleteDeck(deckId);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deck "$deckName" deleted')));
      }
    }
  }
}
