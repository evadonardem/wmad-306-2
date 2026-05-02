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
  late Future<List<HeroModel>> _heroesFuture;
  final TextEditingController _searchController = TextEditingController();
  late final SuperheroApiService? _api;

  String _searchText = '';
  Offset _reloadButtonOffset = const Offset(16, 16);
  bool _reloadButtonDragged = false;

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

  void _retryLoadHeroes() {
    setState(() {
      _heroesFuture = _fetchRandomHeroes();
    });
  }

  Future<void> _reloadRandomHeroes() async {
    _searchController.clear();
    final search = context.read<HeroSearchProvider>();
    await search.updateQuery('');
    search.clearResults();
    setState(() => _searchText = '');
    _retryLoadHeroes();
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
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        childAspectRatio: 0.72,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
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
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Battle History',
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
          ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          const buttonSize = 48.0;
          const edgePadding = 8.0;
          final defaultLeft = constraints.maxWidth - buttonSize - edgePadding;
          final defaultTop = constraints.maxHeight - buttonSize - edgePadding;

          final clampedLeft = _reloadButtonOffset.dx.clamp(edgePadding, defaultLeft);
          final clampedTop = _reloadButtonOffset.dy.clamp(edgePadding, defaultTop);

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
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
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Error: ${snapshot.error}'),
                                      const SizedBox(height: 12),
                                      FilledButton(
                                        onPressed: _retryLoadHeroes,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
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
              Positioned(
                left: _reloadButtonDragged ? clampedLeft : defaultLeft,
                top: _reloadButtonDragged ? clampedTop : defaultTop,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final next = _reloadButtonOffset + details.delta;
                    final maxX = constraints.maxWidth - buttonSize - edgePadding;
                    final maxY = constraints.maxHeight - buttonSize - edgePadding;
                    setState(() {
                      _reloadButtonDragged = true;
                      _reloadButtonOffset = Offset(
                        next.dx.clamp(edgePadding, maxX),
                        next.dy.clamp(edgePadding, maxY),
                      );
                    });
                  },
                  child: FloatingActionButton.small(
                    heroTag: 'reloadHeroesFab',
                    onPressed: _reloadRandomHeroes,
                    tooltip: 'Reload Heroes',
                    child: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}