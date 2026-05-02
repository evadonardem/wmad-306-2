import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
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
  // Future stored in a field — never created inside build()
  late final Future<List<HeroModel>> _heroesFuture;
  final _api = SuperheroApiService(apiToken: kApiToken);
  final _searchController = TextEditingController();
  final _prefs = PrefsService();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _heroesFuture = _api.fetchRandomHeroes(count: 12);
    // Exercise 4 — restore last search query and auto-execute
    _restoreLastSearch();
  }

  // ── Exercise 4 ─────────────────────────────────────────────────────────
  Future<void> _restoreLastSearch() async {
    final last = await _prefs.loadLastSearch();
    if (!mounted || last == null || last.isEmpty) return;
    _searchController.text = last;
    await _executeSearch(last);
  }

  /// Search triggers on submit only — no call on every keystroke.
  Future<void> _executeSearch(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    await _prefs.saveLastSearch(q); // Exercise 4 — persist
    if (!mounted) return;
    setState(() => _isSearchMode = true);
    // Results stored in app-state provider so other screens can react
    context.read<HeroSearchProvider>().search(q, _api);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _isSearchMode = false);
    context.read<HeroSearchProvider>().clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Roster',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Deck badge — only this icon rebuilds
          Consumer<DeckProvider>(
            builder: (_, deck, __) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.style_rounded),
                  tooltip: 'My Deck',
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.deckBuilder),
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: cs.error,
                      child: Text('${deck.deckSize}',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Battle History',
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.history),
          ),
          IconButton(
            icon: const Icon(Icons.person_rounded),
            tooltip: 'Profile',
            onPressed: () =>
                Navigator.pushNamed(context, RouteNames.profile),
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search heroes…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearchMode
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              // Exercise 4 — search on submit only
              onSubmitted: _executeSearch,
            ),
          ),

          // Hero grid / search results
          Expanded(child: _isSearchMode ? _buildSearchResults() : _buildRandomGrid()),
        ],
      ),

      // Battle FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteNames.battle),
        icon: const Icon(Icons.bolt),
        label: const Text('Battle!'),
      ),
    );
  }

  // ── Random heroes via FutureBuilder ─────────────────────────────────────
  Widget _buildRandomGrid() {
    return FutureBuilder<List<HeroModel>>(
      future: _heroesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 14),
              Text('Loading heroes…'),
            ],
          ));
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                Text('Could not load heroes.\n${snapshot.error}',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                const Text(
                  '• Check your API token in constants.dart\n'
                  '• Ensure you have an internet connection',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return _grid(snapshot.data!);
      },
    );
  }

  // ── Search results via Consumer ──────────────────────────────────────────
  Widget _buildSearchResults() {
    return Consumer<HeroSearchProvider>(
      builder: (_, search, __) {
        if (search.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (search.error != null) {
          return Center(
              child: Text(search.error!,
                  style: const TextStyle(color: Colors.redAccent)));
        }
        if (!search.hasResults) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text('No heroes found for "${search.query}"'),
              ],
            ),
          );
        }
        return _grid(search.results);
      },
    );
  }

  Widget _grid(List<HeroModel> heroes) => GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: heroes.length,
        itemBuilder: (_, i) => HeroCard(hero: heroes[i]),
      );
}
