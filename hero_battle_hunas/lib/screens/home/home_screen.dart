import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/hero_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  late final Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    final search = context.read<HeroSearchProvider>();
    _searchController = TextEditingController(text: search.query);
    _initialLoad = search.initialize().then((_) {
      if (mounted) _searchController.text = search.query;
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
                  onPressed: () =>
                      Navigator.pushNamed(context, RouteNames.deckBuilder),
                ),
                if (deck.heroes.isNotEmpty)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: CircleAvatar(
                      radius: 8,
                      child: Text(
                        deck.heroes.length.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
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
      body: FutureBuilder<void>(
        future: _initialLoad,
        builder: (context, _) {
          return Consumer<HeroSearchProvider>(
            builder: (context, search, _) {
              final heroes =
                  search.hasSearch ? search.results : search.randomHeroes;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search heroes',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.casino),
                          onPressed: () => search.loadRandomHeroes(),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: search.search,
                    ),
                  ),
                  if (search.isLoading)
                    const LinearProgressIndicator()
                  else if (search.error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(search.error!),
                    )
                  else
                    Expanded(child: _HeroList(heroes: heroes)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HeroList extends StatelessWidget {
  const _HeroList({required this.heroes});

  final List<HeroModel> heroes;

  @override
  Widget build(BuildContext context) {
    if (heroes.isEmpty) {
      return const Center(child: Text('No heroes found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: heroes.length,
      itemBuilder: (context, index) {
        final hero = heroes[index];
        return HeroCard(
          hero: hero,
          onTap: () => Navigator.pushNamed(
            context,
            RouteNames.heroDetail,
            arguments: hero,
          ),
        );
      },
    );
  }
}
