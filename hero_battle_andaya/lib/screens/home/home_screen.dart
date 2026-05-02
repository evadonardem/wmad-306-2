import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../services/prefs_service.dart';
import '../../widgets/hero_card.dart';
import '../../router/app_router.dart';

const String kApiToken = 'fe651a2118cfd82d93f728f36b6da835';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Store Future in a field assigned in initState — NEVER create it inside build()
  late final Future<List<HeroModel>> _heroesFuture;
  final _api = SuperheroApiService();
  final _searchController = TextEditingController();
  final _prefsService = PrefsService();

  @override
  void initState() {
    super.initState();
    // Load last search query and pre-fill search field
    _loadLastSearch();
    // Fetch heroes once when screen loads
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLastSearch() async {
    final lastSearch = await _prefsService.loadLastSearch();
    if (lastSearch != null && lastSearch.isNotEmpty) {
      setState(() {
        _searchController.text = lastSearch;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    // Save search query to SharedPreferences
    await _prefsService.saveLastSearch(query);
    setState(() {}); // Trigger rebuild to apply filter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Roster'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Deck badge — GOOD: Consumer wraps only this icon, rebuilds only on deck change
          Consumer<DeckProvider>(
            builder: (context, deck, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.style),
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.deckBuilder),
                  tooltip: 'Hero Squad',
                ),
                if (deck.deckSize > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${deck.deckSize}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
            tooltip: 'User Account',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
            tooltip: 'Combat Records',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar — ephemeral state with setState
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (value) {
                _performSearch(value);
              },
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Hero grid with FutureBuilder
          Expanded(
            child: FutureBuilder<List<HeroModel>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                // Success state
                final heroes = snapshot.data!;
                
                // Filter heroes based on search (ephemeral state)
                final filtered = _searchController.text.isEmpty
                    ? heroes
                    : heroes
                        .where((hero) => hero.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _searchController.text.isEmpty
                          ? 'No heroes loaded'
                          : 'No heroes match "${_searchController.text}"',
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) =>
                      HeroCard(hero: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}