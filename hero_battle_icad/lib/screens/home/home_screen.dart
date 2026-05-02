import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../services/superhero_api_service.dart';
import '../../widgets/hero_card.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Always store the Future in a field assigned in initState to avoid loops [cite: 450, 460]
  late Future<List<HeroModel>> _heroesFuture;
  final TextEditingController _searchController = TextEditingController();

  // inside lib/screens/home/home_screen.dart
  @override
  void initState() {
    super.initState();
    // Ensure the parameter name here matches the one in the Service class
    _heroesFuture = SuperheroApiService().fetchRandomHeroes();
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
        title: const Text("Hero Battle"),
        actions: [
          // Using Consumer to rebuild only the deck icon subtree [cite: 448, 451]
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
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, RouteNames.profile),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final searchProvider = context.watch<HeroSearchProvider>();
          final query = _searchController.text.trim();
          final isSearching = query.isNotEmpty;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isNotEmpty) {
                      searchProvider.search(trimmed);
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search heroes by name',
                    border: const OutlineInputBorder(),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchProvider.clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: isSearching
                    ? _buildSearchResults(searchProvider)
                    : FutureBuilder<List<HeroModel>>(
                        future: _heroesFuture,
                        builder: (context, snapshot) {
                          // FutureBuilder — Three States [cite: 455, 456]
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final heroes = snapshot.data ?? [];
                          return GridView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: heroes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      2, // 2 columns as per manual [cite: 449]
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemBuilder: (context, i) =>
                                HeroCard(hero: heroes[i]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(HeroSearchProvider searchProvider) {
    if (searchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchProvider.searchResults.isEmpty) {
      return const Center(child: Text('No heroes found. Try another name.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: searchProvider.searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, i) =>
          HeroCard(hero: searchProvider.searchResults[i]),
    );
  }
}
