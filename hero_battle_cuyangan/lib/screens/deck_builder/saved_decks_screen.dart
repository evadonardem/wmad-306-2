import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../services/database_service.dart';
import 'dart:convert';

class SavedDecksScreen extends StatefulWidget {
  const SavedDecksScreen({super.key});

  @override
  State<SavedDecksScreen> createState() => _SavedDecksScreenState();
}

class _SavedDecksScreenState extends State<SavedDecksScreen> {
  List<Map<String, dynamic>> _savedDecks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDecks();
  }

  Future<void> _loadSavedDecks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final decks = await DatabaseService().loadDecks();
      setState(() {
        _savedDecks = decks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load decks: $e')));
      }
    }
  }

  Future<void> _deleteDeck(int? deckId, String deckName) async {
    if (deckId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid deck ID')));
      }
      return;
    }
    final confirmed = await _showDeleteConfirmation(deckName);
    if (!confirmed) return;

    try {
      await DatabaseService().deleteDeck(deckId);
      await _loadSavedDecks(); // Refresh the list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deck deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete deck: $e')));
      }
    }
  }

  Future<bool> _showDeleteConfirmation(String deckName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "$deckName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _loadDeckToBuilder(List<HeroModel> heroes) async {
    // Clear current deck and add heroes from saved deck
    final deckProvider = context.read<DeckProvider>();
    deckProvider.clearDeck();

    for (final hero in heroes) {
      if (!deckProvider.isFull) {
        deckProvider.addHero(hero);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deck loaded to builder'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Go back to deck builder
    }
  }

  List<HeroModel> _parseHeroes(String heroesJson) {
    try {
      // Null Safety: Check if heroesJson is empty or null
      if (heroesJson.isEmpty) {
        return [];
      }

      // JSON Decoding: Ensure proper mapping back to HeroModel objects
      final List<dynamic> heroesList = jsonDecode(heroesJson) as List;
      return heroesList
          .map(
            (heroJson) => HeroModel.fromJson(heroJson as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error parsing heroes: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Decks'),
        actions: [
          IconButton(
            onPressed: _loadSavedDecks,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedDecks.isEmpty
          ? _buildEmptyState()
          : _buildDecksList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.archive, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No saved decks',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Create and save your first deck!',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDecksList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _savedDecks.length,
      itemBuilder: (context, index) {
        final deck = _savedDecks[index];
        final heroes = _parseHeroes(deck['heroes']?.toString() ?? '');
        // Since we removed 'created' column, use current date for display
        final createdDate = DateTime.now();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '${heroes.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              deck['name']?.toString() ?? 'Unnamed Deck',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Created: ${createdDate.day}/${createdDate.month}/${createdDate.year}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteDeck(
                deck['id'] as int?,
                deck['name']?.toString() ?? 'Unnamed Deck',
              ),
              tooltip: 'Delete deck',
            ),
            children: [
              // Heroes in the deck
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heroes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...heroes
                        .map(
                          (hero) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      hero.displayImageUrl.isNotEmpty
                                      ? NetworkImage(hero.displayImageUrl)
                                      : null,
                                  child: hero.displayImageUrl.isEmpty
                                      ? const Icon(Icons.person, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(hero.name)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _loadDeckToBuilder(heroes),
                        icon: const Icon(Icons.download),
                        label: const Text('Load to Builder'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
