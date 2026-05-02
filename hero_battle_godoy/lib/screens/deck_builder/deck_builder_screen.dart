import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/battle_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_image.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          Consumer<DeckProvider>(
            builder: (context, deck, _) => IconButton(
              icon: const Icon(Icons.save),
              onPressed: deck.isReady
                  ? () => _showSaveDialog(context, deck)
                  : null,
              tooltip: 'Save Deck',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () => Navigator.pushNamed(context, RouteNames.savedDecks),
            tooltip: 'Saved Decks',
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deck, _) {
          if (deck.deckSize == 0) {
            return const Center(child: Text('Your deck is empty. Add heroes from the roster!'));
          }
          return ListView.builder(
            itemCount: deck.deckSize,
            itemBuilder: (context, i) {
              final hero = deck.deck[i];
              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: HeroImage(
                    imageUrl: hero.reliableImageUrl,
                    borderRadius: BorderRadius.circular(20),
                    errorWidget: const Icon(Icons.person),
                  ),
                ),
                title: Text(hero.name),
                subtitle: Text('ATK: ${hero.attack} | DEF: ${hero.defense} | HP: ${hero.maxHp}'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () => deck.removeHero(hero),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<DeckProvider>(
        builder: (context, deck, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${deck.deckSize}/${DeckProvider.maxDeckSize} heroes',
                  style: const TextStyle(fontSize: 16)),
              if (deck.isReady)
                ElevatedButton(
                  onPressed: () => _startBattle(context, deck),
                  child: const Text('Start Battle'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveDialog(BuildContext context, DeckProvider deck) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter deck name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await deck.saveDeckToDb(name);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deck "$name" saved!')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _startBattle(BuildContext context, DeckProvider deck) async {
    final battleProvider = context.read<BattleProvider>();
    
    // Select two random heroes from deck for PvP battle
    final deckHeroes = deck.deck.toList();
    deckHeroes.shuffle();
    
    if (deckHeroes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 2 heroes in deck to battle!')),
      );
      return;
    }
    
    final playerHero = deckHeroes[0];
    final opponentHero = deckHeroes[1];
    
    battleProvider.startBattle(playerHero, opponentHero, deckHeroes);
    Navigator.pushNamed(context, RouteNames.battle);
  }
}
