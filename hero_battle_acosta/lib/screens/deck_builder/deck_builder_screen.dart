import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../services/database_service.dart';
import '../../router/app_router.dart';
import '../../models/hero_model.dart';
import 'dart:convert';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  late TextEditingController _deckNameController;

  @override
  void initState() {
    super.initState();
    _deckNameController = TextEditingController();
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }

  void _showSaveDeckDialog() {
    _deckNameController.clear();
    showDialog(
      context: context,
      builder: (context) => _SaveDeckDialog(controller: _deckNameController),
    );
  }

  Future<void> _startBattleAutomatic(BuildContext context, DeckProvider deck) async {
    // Load all saved decks and pick random one
    try {
      final savedDecks = await DatabaseService().loadDecks();
      
      if (savedDecks.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No opponent decks saved. Save a deck first!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Pick random deck
      final randomDeck = savedDecks[(savedDecks.length * 0.5).toInt() + 
        DateTime.now().millisecond % (savedDecks.length > 1 ? savedDecks.length - 1 : 1)];
      
      if (context.mounted) {
        await _startBattleWithDeck(randomDeck, deck);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting battle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _startBattleWithDeck(
    Map<String, dynamic> opponentDeckData,
    DeckProvider deck,
  ) async {
    try {
      // Parse opponent deck heroes
      final heroesJson = jsonDecode(opponentDeckData['heroes'] as String) as List;
      final opponentHeroes = heroesJson
          .map((h) => HeroModel.fromJson(h as Map<String, dynamic>))
          .toList();

      if (opponentHeroes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opponent deck is empty'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Pass full decks to battle screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          RouteNames.battle,
          arguments: {
            'playerDeck': deck.deck,
            'aiDeck': opponentHeroes,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting battle: $e'),
            backgroundColor: Colors.red,
          ),
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
          IconButton(
            onPressed: () => Navigator.pushNamed(context, RouteNames.savedDecks),
            icon: const Icon(Icons.folder),
            tooltip: 'Saved Decks',
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          return Column(
            children: [
              // Header with deck info
              Container(
                color: Colors.grey[850],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Deck (${deck.deckSize}/5)',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deck.deck.isEmpty
                          ? 'No heroes yet. Add heroes from Home.'
                          : '${deck.deck.length} hero${deck.deck.length == 1 ? '' : 's'} selected',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              
              // Heroes list
              Expanded(
                child: deck.deck.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 80, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              'No heroes yet',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add heroes from Home screen',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: deck.deck.length,
                        itemBuilder: (_, i) {
                          final hero = deck.deck[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(hero.imageUrl),
                                onBackgroundImageError: (_, __) {},
                              ),
                              title: Text(hero.name),
                              subtitle: Text('HP: ${hero.maxHp} | ATK: ${hero.attack}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  deck.removeHero(hero);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${hero.name} removed'),
                                      duration: const Duration(milliseconds: 800),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Deck'),
                    onPressed: deck.deck.isEmpty
                        ? null
                        : _showSaveDeckDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.videogame_asset),
                    label: const Text('Battle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: deck.isReady
                        ? () => _startBattleAutomatic(context, deck)
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Dialog for saving deck with dynamic button state
class _SaveDeckDialog extends StatefulWidget {
  final TextEditingController controller;

  const _SaveDeckDialog({required this.controller});

  @override
  State<_SaveDeckDialog> createState() => _SaveDeckDialogState();
}

class _SaveDeckDialogState extends State<_SaveDeckDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Save Deck"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.controller,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'Enter deck name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.folder_special),
            ),
            onChanged: (_) => setState(() {}), // Rebuild on text change
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton.icon(
          icon: _isLoading ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ) : const Icon(Icons.save),
          label: Text(_isLoading ? 'Saving...' : 'Save'),
          onPressed: widget.controller.text.isEmpty || _isLoading
              ? null
              : () async {
                  setState(() => _isLoading = true);
                  
                  try {
                    await context
                        .read<DeckProvider>()
                        .saveDeckToDb(widget.controller.text);

                    if (!mounted) return;
                    
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${widget.controller.text}" saved successfully!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error saving deck: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
        ),
      ],
    );
  }
}