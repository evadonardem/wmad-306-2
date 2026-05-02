import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../services/prefs_service.dart';
import '../../widgets/hero_card.dart';
import '../../router/app_router.dart';

const String kApiToken = 'YOUR_API_TOKEN_HERE'; // Replace with actual token

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<HeroModel>> _heroesFuture; // stored in field!
  final _api = SuperheroApiService(apiToken: kApiToken);
  final _searchController = TextEditingController();
  final _prefs = PrefsService();

  @override
  void initState() {
    super.initState();
    // Store Future once — never create it inside build()
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
    _loadLastSearch();
  }

  Future<void> _loadLastSearch() async {
    final lastSearch = await _prefs.loadLastSearch();
    if (lastSearch != null && mounted) {
      _searchController.text = lastSearch;
      // Execute search automatically
      final searchProvider = context.read<HeroSearchProvider>();
      await searchProvider.searchHeroes(lastSearch);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Roster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
          ),
          // Deck badge — Consumer rebuilds only this icon
          Consumer<DeckProvider>(
            builder: (context, deck, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.style),
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.deckBuilder),
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      child: Text(
                        '${deck.deckSize}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search heroes...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (query) {
                _prefs.saveLastSearch(query);
                final searchProvider = context.read<HeroSearchProvider>();
                searchProvider.searchHeroes(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<HeroSearchProvider>(
              builder: (context, search, child) {
                if (search.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (search.searchResults.isNotEmpty) {
                  return GridView.builder(
                    itemCount: search.searchResults.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 0.7,
                        ),
                    itemBuilder: (context, i) =>
                        HeroCard(hero: search.searchResults[i]),
                  );
                }
                if (search.hasNoResults) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'No heroes found.',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              context.read<HeroSearchProvider>().updateQuery(
                                '',
                              );
                              _prefs.saveLastSearch('');
                            },
                            child: const Text('Show random heroes'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                // Default random heroes
                return FutureBuilder<List<HeroModel>>(
                  future: _heroesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final heroes = snapshot.data!;
                    return GridView.builder(
                      itemCount: heroes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.7,
                          ),
                      itemBuilder: (context, i) => HeroCard(hero: heroes[i]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
