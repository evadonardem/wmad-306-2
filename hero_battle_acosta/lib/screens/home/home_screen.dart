import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../services/prefs_service.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<HeroModel>> _heroesFuture;
  final _searchController = TextEditingController();
  final api = SuperheroApiService();

  @override
  void initState() {
    super.initState();
    _heroesFuture = api.fetchRandomHeroes();
    _loadSearchAndExecute();
  }

  // 🔥 LOAD + AUTO SEARCH (FIXED)
  Future<void> _loadSearchAndExecute() async {
    final last = await PrefsService().loadLastSearch();

    if (last != null && last.isNotEmpty) {
      _searchController.text = last;

      setState(() {
        _heroesFuture = api.searchHeroes(last);
      });
    }
  }

  // 🔥 SEARCH FUNCTION (FIXED)
  void _search(String value) async {
    await PrefsService().saveLastSearch(value);

    setState(() {
      if (value.isEmpty) {
        _heroesFuture = api.fetchRandomHeroes();
      } else {
        _heroesFuture = api.searchHeroes(value);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // ✅ FIX MEMORY LEAK
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
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: "Search hero...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _search,
            ),
          ),

          // 🦸 HERO LIST
          Expanded(
            child: FutureBuilder<List<HeroModel>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                // 🔄 LOADING
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ❌ ERROR FIX
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 60),
                        const SizedBox(height: 10),
                        const Text("Failed to load heroes"),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _heroesFuture = api.fetchRandomHeroes();
                            });
                          },
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  );
                }

                final heroes = snapshot.data ?? [];

                // ⚠️ EMPTY STATE
                if (heroes.isEmpty) {
                  return const Center(
                    child: Text("No heroes found"),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: heroes.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, i) =>
                      HeroCard(hero: heroes[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}