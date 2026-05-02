import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_card.dart';

class DeckBuilderScreen extends StatelessWidget {
  const DeckBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final heroSearch = context.watch<HeroSearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: deck.clear,
            tooltip: 'Clear deck',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Text('Selected heroes: ${deck.count}/${DeckProvider.maxDeckSize}')),
                ElevatedButton(
                  onPressed: deck.selectedHeroes.isEmpty
                      ? null
                      : () {
                          final hero = deck.selectedHeroes.first;
                          Navigator.pushNamed(context, RouteNames.battle, arguments: hero);
                        },
                  child: const Text('Fight with first hero'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: heroSearch.heroes.length,
              itemBuilder: (context, index) {
                final hero = heroSearch.heroes[index];
                final selected = deck.isSelected(hero);
                return HeroCard(
                  hero: hero,
                  selected: selected,
                  onTap: () => deck.toggle(hero),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
