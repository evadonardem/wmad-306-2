import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          Consumer<DeckProvider>(
            builder: (context, deckProvider, child) {
              return IconButton(
                onPressed: deckProvider.deckSize >= 1
                    ? () => _showSaveDeckDialog(context)
                    : null,
                icon: const Icon(Icons.save),
                tooltip: 'Save Deck',
              );
            },
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, child) {
          return Column(
            children: [
              // Deck Status Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                child: Column(
                  children: [
                    Text(
                      'Current Deck (${deckProvider.deckSize}/5)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (deckProvider.deckSize == 0)
                      const Text('Add heroes to build your deck!')
                    else if (deckProvider.isFull)
                      const Text(
                        'Deck is full!',
                        style: TextStyle(color: Colors.green),
                      )
                    else
                      Text('Add ${5 - deckProvider.deckSize} more heroes'),
                  ],
                ),
              ),

              // Heroes List
              Expanded(
                child: deckProvider.deck.isEmpty
                    ? _buildEmptyState(context)
                    : _buildDeckList(context, deckProvider),
              ),

              // Start Battle Button - Only shows when deck is full
              if (deckProvider.isFull)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border(
                      top: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.battle);
                    },
                    icon: const Icon(Icons.flash_on),
                    label: const Text('START BATTLE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      elevation: 8,
                      shadowColor: Colors.red.withOpacity(0.5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.savedDecks);
        },
        icon: const Icon(Icons.archive),
        label: const Text('Saved Decks'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.deck, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Your deck is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Add heroes from the home screen',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckList(BuildContext context, DeckProvider deckProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: deckProvider.deck.length,
      itemBuilder: (context, index) {
        final hero = deckProvider.deck[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: hero.displayImageUrl.isNotEmpty
                  ? NetworkImage(hero.displayImageUrl)
                  : null,
              child: hero.displayImageUrl.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(hero.name),
            subtitle: Text(hero.publisher),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeHero(context, hero, deckProvider),
              tooltip: 'Remove from deck',
            ),
          ),
        );
      },
    );
  }

  void _removeHero(
    BuildContext context,
    HeroModel hero,
    DeckProvider deckProvider,
  ) {
    deckProvider.removeHero(hero);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${hero.name} removed from deck')));
  }

  void _showSaveDeckDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Deck Name',
            border: OutlineInputBorder(),
            hintText: 'Enter a name for your deck',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context);
                await _saveDeck(context, name);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDeck(BuildContext context, String name) async {
    try {
      // Try/Catch Block: Wrap save logic and show SnackBar if it fails
      await context.read<DeckProvider>().saveDeckToDb(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deck "$name" saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Save deck error in UI: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save deck: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
