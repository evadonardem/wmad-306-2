import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<HeroModel>> _heroesFuture;
  final _api = SuperheroApiService(apiToken: kApiToken);
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
    _restoreLastSearch();
  }

  Future<void> _restoreLastSearch() async {
    final search = context.read<HeroSearchProvider>();
    final lastQuery = await search.loadLastSearch();
    if (!mounted || lastQuery == null || lastQuery.trim().isEmpty) return;
    _searchController.text = lastQuery;
    await search.search(lastQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Battle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
          ),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.18),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build your squad. Pick a fighter. Win the round.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Batman, Superman, Storm...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => context
                          .read<HeroSearchProvider>()
                          .search(_searchController.text),
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: context.read<HeroSearchProvider>().search,
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<HeroSearchProvider>(
              builder: (context, search, _) {
                if (search.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (search.error != null) {
                  return Center(child: Text(search.error!));
                }
                if (search.hasQuery) {
                  return _HeroGrid(heroes: search.results);
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
                    return _HeroGrid(heroes: snapshot.data ?? []);
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

class _HeroGrid extends StatelessWidget {
  const _HeroGrid({required this.heroes});

  final List<HeroModel> heroes;

  @override
  Widget build(BuildContext context) {
    if (heroes.isEmpty) {
      return const Center(child: Text('No heroes found.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: heroes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, i) => HeroCard(hero: heroes[i]),
    );
  }
}
