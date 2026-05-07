// Manual §5.7 — Home: FutureBuilder grid + ephemeral search controller.
// Future is stored in a field and assigned in initState (NEVER built in build()).
// Exercise 4: search query persisted via PrefsService and restored on launch.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/_neon.dart';
// (no API token — akabab/superhero-api is open via jsdelivr CDN)
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<HeroModel>> _heroesFuture; // stored in field!
  final _api = SuperheroApiService();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Store Future once — never create it inside build().
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
    // Exercise 4 — restore last search and execute it once.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final restored =
          await context.read<HeroSearchProvider>().restore(_api);
      if (restored != null && mounted) {
        _searchController.text = restored;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String q) {
    // Exercise 4 — only fires on submit, not on every keystroke.
    context.read<HeroSearchProvider>().setQuery(_api, q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Hero Roster'),
        actions: [
          // Deck badge — narrow Consumer rebuilds only this icon.
          Consumer<DeckProvider>(
            builder: (context, deck, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.style, color: kNeonCyan),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    RouteNames.deckBuilder,
                  ),
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 9,
                      backgroundColor: kNeonMagenta,
                      child: Text(
                        '${deck.deckSize}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kBgDeep,
                        ),
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
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              decoration: InputDecoration(
                hintText: 'Search hero by name…',
                prefixIcon: const Icon(Icons.search, color: kNeonCyan),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: kTextDim),
                  onPressed: () {
                    _searchController.clear();
                    context.read<HeroSearchProvider>().clear();
                  },
                ),
                filled: true,
                fillColor: kSurface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: kNeonCyan.withValues(alpha: 0.6),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kNeonCyan, width: 2),
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  /// Search results override the random roster when present.
  Widget _buildBody() {
    return Consumer<HeroSearchProvider>(
      builder: (context, search, _) {
        if (search.hasQuery) {
          if (search.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: kNeonCyan),
            );
          }
          if (search.error != null) {
            return _ErrorBlock(message: search.error!);
          }
          if (search.results.isEmpty) {
            return Center(
              child: Text(
                'No heroes found for “${search.query}”',
                style: const TextStyle(color: kTextDim),
              ),
            );
          }
          return _grid(search.results);
        }

        // No active search — show the random roster fetched once in initState.
        return FutureBuilder<List<HeroModel>>(
          future: _heroesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(color: kNeonCyan),
              );
            }
            if (snapshot.hasError) {
              return _ErrorBlock(message: '${snapshot.error}');
            }
            return _grid(snapshot.data!);
          },
        );
      },
    );
  }

  Widget _grid(List<HeroModel> heroes) => GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: heroes.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (context, i) => HeroCard(hero: heroes[i]),
      );

  Drawer _buildDrawer(BuildContext context) => Drawer(
        backgroundColor: kSurface,
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Text(
                  'Hero Battle',
                  style: TextStyle(
                    color: kNeonCyan,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              _drawerTile(Icons.style, 'Deck Builder', RouteNames.deckBuilder),
              _drawerTile(Icons.history, 'Battle History', RouteNames.history),
              _drawerTile(
                Icons.bookmark,
                'Saved Decks',
                RouteNames.savedDecks,
              ),
              _drawerTile(Icons.person, 'Profile', RouteNames.profile),
            ],
          ),
        ),
      );

  Widget _drawerTile(IconData icon, String label, String route) => ListTile(
        leading: Icon(icon, color: kNeonCyan),
        title: Text(label, style: const TextStyle(color: kTextPrimary)),
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
      );
}

class _ErrorBlock extends StatelessWidget {
  final String message;
  const _ErrorBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kNeonMagenta, size: 48),
            const SizedBox(height: 12),
            Text(
              'Could not load heroes.',
              style: kNeonTitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: kTextDim),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Check your internet connection and try again.',
              style: TextStyle(color: kNeonCyan, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
