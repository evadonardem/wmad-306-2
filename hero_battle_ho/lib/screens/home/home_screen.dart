import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

const String kApiToken = String.fromEnvironment(
  'SUPERHERO_API_TOKEN',
  defaultValue: '86fc32080c6be7c63070313609482a39',
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<HeroModel>> _heroesFuture;
  final TextEditingController _searchController = TextEditingController();
  late final SuperheroApiService? _api;

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _api = kApiToken.isEmpty ? null : SuperheroApiService(apiToken: kApiToken);
    _heroesFuture = _fetchRandomHeroes();
    _restoreLastSearch();
  }

  Future<List<HeroModel>> _fetchRandomHeroes() async {
    if (_api == null) {
      throw Exception('Missing API token. Run with --dart-define=SUPERHERO_API_TOKEN=YOUR_TOKEN');
    }
    return _api!.fetchRandomHeroes(count: 20);
  }

  Future<void> _restoreLastSearch() async {
    final search = context.read<HeroSearchProvider>();
    await search.loadLastSearch();
    if (!mounted) return;

    final lastQuery = search.query.trim();
    if (lastQuery.isEmpty) return;

    _searchController.text = lastQuery;
    setState(() => _searchText = lastQuery);
    await _submitSearch(lastQuery);
  }

  Future<void> _submitSearch(String value) async {
    final query = value.trim();
    final search = context.read<HeroSearchProvider>();
    await search.updateQuery(query);

    if (query.isEmpty) {
      search.clearResults();
      return;
    }

    if (_api == null) {
      search.setError('Missing API token. Set SUPERHERO_API_TOKEN.');
      return;
    }

    search.setLoading(true);
    try {
      final results = await _api!.searchHeroes(query);
      if (!mounted) return;
      search.setResults(results);
    } catch (e) {
      if (!mounted) return;
      search.setError(e.toString());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildGrid(List<HeroModel> heroes) {
    return GridView.builder(
      itemCount: heroes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, i) => HeroCard(hero: heroes[i]),
    );
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
                  onPressed: () => Navigator.pushNamed(context, RouteNames.deckBuilder),
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      child: Text('${deck.deckSize}', style: const TextStyle(fontSize: 10)),
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchText = value),
              onSubmitted: _submitSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search hero by name',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                          _submitSearch('');
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<HeroSearchProvider>(
              builder: (context, search, _) {
                final hasQuery = search.query.trim().isNotEmpty;
                if (hasQuery) {
                  if (search.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (search.errorMessage != null) {
                    return Center(child: Text('Error: ${search.errorMessage}'));
                  }
                  if (!search.hasResults) {
                    return const Center(child: Text('No heroes found.'));
                  }
                  return _buildGrid(search.results);
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

                    final heroes = snapshot.data ?? [];
                    return _buildGrid(heroes);
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