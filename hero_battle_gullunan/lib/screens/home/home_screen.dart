import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../services/prefs_service.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<HeroModel>> _heroesFuture;
  final _api = SuperheroApiService();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
    _loadLastSearch();
  }

  Future<void> _loadLastSearch() async {
    final lastSearch = await PrefsService().loadLastSearch();
    if (lastSearch != null && lastSearch.isNotEmpty) {
      _searchController.text = lastSearch;
      _performSearch(lastSearch);
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      context.read<HeroSearchProvider>().clearSearch();
      return;
    }
    final searchProvider = context.read<HeroSearchProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final results = await _api.searchHeroes(query);
      if (!mounted) return;
      searchProvider.updateSearchResults(results);
      await PrefsService().saveLastSearch(query);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Roster'),
        actions: [
          Consumer<DeckProvider>(
            builder: (context, deck, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.style),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.deckBuilder);
                  },
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
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.history);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, RouteNames.profile);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search heroes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _performSearch,
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: Consumer<HeroSearchProvider>(
              builder: (context, searchProvider, _) {
                final heroes = searchProvider.searchResults.isEmpty
                    ? null
                    : searchProvider.searchResults;
                final query = searchProvider.searchQuery;

                if (heroes != null) {
                  if (heroes.isEmpty) {
                    return Center(
                      child: Text(
                        query.isNotEmpty
                            ? 'No heroes found for "$query"'
                            : 'No heroes found',
                      ),
                    );
                  }

                  return Column(
                    children: [
                      if (query.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Search results for "$query"',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      Expanded(child: _buildHeroGrid(heroes)),
                    ],
                  );
                }

                return FutureBuilder<List<HeroModel>>(
                  future: _heroesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final heroList = snapshot.data ?? [];
                    return _buildHeroGrid(heroList);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGrid(List<HeroModel> heroes) {
    return GridView.builder(
      itemCount: heroes.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, i) => HeroCard(hero: heroes[i]),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
