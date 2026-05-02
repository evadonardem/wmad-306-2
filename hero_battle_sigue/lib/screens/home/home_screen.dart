import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/prefs_service.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';

const kApiToken = '53f0edb611dd90f8d9f1da45c71f8a58'; // <-- put your token here

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
    _loadLastSearch();
    _heroesFuture = _api.fetchRandomHeroes(count: 20);
  }

  Future<void> _loadLastSearch() async {
    final last = await _prefs.loadLastSearch();
    if (last != null && last.isNotEmpty) {
      _searchController.text = last;
      // Exercise 4: auto-execute last search on launch
      setState(() {
        _heroesFuture = _api.searchHeroes(last);
      });
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    _prefs.saveLastSearch(query); // Exercise 4: persist query
    setState(() {
      _heroesFuture = _api.searchHeroes(query);
    });
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
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search heroes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _onSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _onSearch(), // search on submit only (Exercise 4)
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HeroModel>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done)
                  return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        ElevatedButton(
                          onPressed: () => setState(() {
                            _heroesFuture = _api.fetchRandomHeroes(count: 20);
                          }),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                final heroes = snapshot.data!;
                if (heroes.isEmpty)
                  return const Center(child: Text('No heroes found.'));
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: heroes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
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