import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../services/prefs_service.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_card.dart';

// Replace with your actual API token from superheroapi.com
const String kApiToken = 'd4b3dc4ee502cb88da9ad9467d4c2208';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HeroModel>> _heroesFuture;
  final _api = SuperheroApiService(apiToken: kApiToken);
  final _prefs = PrefsService();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSearch();
  }

  Future<void> _initializeSearch() async {
    // Load last search query from SharedPreferences
    final lastQuery = await _prefs.loadLastSearch();
    
    if (mounted) {
      if (lastQuery != null && lastQuery.isNotEmpty) {
        // Pre-fill the search field
        _searchController.text = lastQuery;
        // Auto-execute search with the restored query
        setState(() {
          _heroesFuture = _api.searchHeroes(lastQuery);
        });
      } else {
        // Load random heroes if no saved search
        setState(() {
          _heroesFuture = _api.fetchRandomHeroes(count: 20);
        });
      }
    }
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
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, RouteNames.history),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
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
                          _prefs.saveLastSearch(''); // Clear the saved search
                          setState(() {
                            _heroesFuture = _api.fetchRandomHeroes(count: 20);
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (query) {
                setState(() {});
              },
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  // Save the search query to SharedPreferences
                  _prefs.saveLastSearch(query.trim());
                  setState(() {
                    _heroesFuture = _api.searchHeroes(query.trim());
                  });
                } else {
                  setState(() {
                    _heroesFuture = _api.fetchRandomHeroes(count: 20);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HeroModel>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _prefs.saveLastSearch('');
                            _heroesFuture = _api.fetchRandomHeroes(count: 20);
                          }),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No heroes found', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _prefs.saveLastSearch('');
                            _heroesFuture = _api.fetchRandomHeroes(count: 20);
                          }),
                          child: const Text('Load Random Heroes'),
                        ),
                      ],
                    ),
                  );
                }
                final heroes = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: heroes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, i) => HeroCard(hero: heroes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
