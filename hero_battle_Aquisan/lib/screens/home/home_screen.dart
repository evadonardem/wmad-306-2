import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  late Future<void> _initialHeroesFuture;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _initialHeroesFuture = context.read<HeroSearchProvider>().loadInitialHeroes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final heroSearch = context.watch<HeroSearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
          ),
          IconButton(
            icon: const Icon(Icons.style),
            onPressed: () => Navigator.pushNamed(context, RouteNames.deck),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose your hero roster',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Selected: ${deck.deckSize} / 5',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
  onPressed: deck.deckSize >= 2
      ? () {
          print('=== BATTLE BUTTON PRESSED ===');
          print('Number of heroes: ${deck.deckSize}');
          print('Navigating to: ${RouteNames.battle}');
          
          // Initialize battle before navigation
          final battle = context.read<BattleProvider>();
          final aiDeck = List<HeroModel>.from(deck.deck)..shuffle();
          battle.startBattle(deck.deck, aiDeck);
          
          Navigator.pushNamed(context, RouteNames.battle);
        }
      : null,
  icon: const Icon(Icons.sports_martial_arts),
  label: Text(
    deck.deckSize >= 2
        ? 'Start Battle'
        : 'Select Heroes to Battle',
  ),
),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search heroes by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: heroSearch.query.trim().isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          heroSearch.clearSearch();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onChanged: heroSearch.searchHeroes,
            ),
            const SizedBox(height: 16),
            if (heroSearch.errorMessage != null) ...[
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    heroSearch.errorMessage!,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onErrorContainer,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: FutureBuilder<void>(
                future: _initialHeroesFuture,
                builder: (context, snapshot) {
                  final isInitialLoad =
                      snapshot.connectionState == ConnectionState.waiting &&
                      !heroSearch.hasResults;

                  return _HeroRosterGrid(
                    isLoading: isInitialLoad || (heroSearch.isLoading && !heroSearch.hasResults),
                    heroes: heroSearch.visibleHeroes,
                    emptyLabel: heroSearch.isShowingSearchResults
                        ? 'No heroes matched your search.'
                        : 'No heroes available.',
                    onSelectHero: (hero) {
                      if (deck.contains(hero)) {
                        deck.removeHero(hero);
                      } else if (!deck.isFull) {
                        deck.addHero(hero);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deck is full (Max 5)!')),
                        );
                      }
                    },
                    onLongPressHero: (hero) {
                      Navigator.pushNamed(
                        context,
                        RouteNames.heroDetail,
                        arguments: hero,
                      );
                    },
                    isSelected: deck.contains,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroRosterGrid extends StatelessWidget {
  const _HeroRosterGrid({
    required this.isLoading,
    required this.heroes,
    required this.emptyLabel,
    required this.onSelectHero,
    required this.onLongPressHero,  // FIXED: Keep this parameter name
    required this.isSelected,
  });

  final bool isLoading;
  final List<HeroModel> heroes;
  final String emptyLabel;
  final void Function(HeroModel hero) onSelectHero;
  final void Function(HeroModel hero) onLongPressHero;
  final bool Function(HeroModel hero) isSelected;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (heroes.isEmpty) {
      return Center(child: Text(emptyLabel));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: heroes.length,
      itemBuilder: (context, index) {
        final hero = heroes[index];
        return GestureDetector(
          onTap: () => onSelectHero(hero),
          onLongPress: () => onLongPressHero(hero),
          child: HeroCard(
            hero: hero,
            selected: isSelected(hero),
          ),
        );
      },
    );
  }
}