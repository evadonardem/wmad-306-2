import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _loadFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLastSearchAndInit();
    });
  }

  Future<void> _loadLastSearchAndInit() async {
    await context.read<HeroSearchProvider>().loadLastSearch();
    final query = context.read<HeroSearchProvider>().query;
    if (query.isNotEmpty) {
      _searchController.text = query;
    } else {
      await context.read<HeroSearchProvider>().loadRandomHeroes();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    final searchProvider = context.read<HeroSearchProvider>();
    if (query.isEmpty) {
      searchProvider.clearSearch();
      await searchProvider.loadRandomHeroes();
    } else {
      await searchProvider.searchHeroes(query);
      await searchProvider.saveLastSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Roster'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search heroes...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
        ),
        actions: [
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
                      backgroundColor: Colors.red,
                      child: Text('${deck.deckSize}',
                          style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Consumer<HeroSearchProvider>(
        builder: (context, search, _) {
          if (search.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (search.error.isNotEmpty) {
            return Center(child: Text('Error: ${search.error}'));
          }
          final heroes = search.query.isEmpty ? search.randomHeroes : search.results;
          if (heroes.isEmpty) {
            return const Center(child: Text('No heroes found.'));
          }
          return GridView.builder(
            itemCount: heroes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, i) {
              final hero = heroes[i];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    RouteNames.heroDetail,
                    arguments: hero,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: HeroImage(
                          imageUrl: hero.reliableImageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorWidget: const Center(child: Icon(Icons.person, size: 64)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(hero.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}