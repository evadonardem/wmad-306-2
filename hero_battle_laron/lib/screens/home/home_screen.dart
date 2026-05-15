import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchProvider = Provider.of<HeroSearchProvider>(context);
    final battleProvider = Provider.of<BattleProvider>(context);
    final deckProvider = Provider.of<DeckProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Battle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.deck),
            onPressed: () => _showDeck(context, deckProvider),
          ),
          IconButton(
            icon: const Icon(Icons.sports_martial_arts),
            onPressed: () => _startBattle(context, battleProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Heroes',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => searchProvider.searchHeroes(value),
            ),
          ),
          if (searchProvider.isLoading)
            const CircularProgressIndicator()
          else if (searchProvider.error.isNotEmpty)
            Text('Error: ${searchProvider.error}')
          else
            Expanded(
              child: ListView.builder(
                itemCount: searchProvider.heroes.length,
                itemBuilder: (context, index) {
                  final hero = searchProvider.heroes[index];
                  return HeroCard(
                    hero: hero,
                    onTap: () => _selectHero(context, hero, battleProvider, deckProvider),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _selectHero(BuildContext context, hero, BattleProvider battleProvider, DeckProvider deckProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select ${hero.name}'),
        content: const Text('Choose action:'),
        actions: [
          TextButton(
            onPressed: () {
              battleProvider.selectPlayerHero(hero);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${hero.name} selected as player hero')),
              );
            },
            child: const Text('Select as Player'),
          ),
          TextButton(
            onPressed: () {
              battleProvider.selectOpponentHero(hero);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${hero.name} selected as opponent')),
              );
            },
            child: const Text('Select as Opponent'),
          ),
          TextButton(
            onPressed: () {
              deckProvider.addToDeck(hero);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${hero.name} added to deck')),
              );
            },
            child: const Text('Add to Deck'),
          ),
        ],
      ),
    );
  }

  void _showDeck(BuildContext context, DeckProvider deckProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Deck'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: deckProvider.deck.length,
            itemBuilder: (context, index) {
              final hero = deckProvider.deck[index];
              return ListTile(
                title: Text(hero.name),
                trailing: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => deckProvider.removeFromDeck(hero.id),
                ),
              );
            },
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

  void _startBattle(BuildContext context, BattleProvider battleProvider) async {
    await battleProvider.startBattle();
    if (battleProvider.lastBattle != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Battle Result'),
          content: Text('Winner: ${battleProvider.lastBattle!.winnerName}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}