import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_roster_provider.dart';
import '../../services/superhero_api_service.dart';

class HeroRosterScreen extends StatefulWidget {
  const HeroRosterScreen({super.key});

  @override
  State<HeroRosterScreen> createState() => _HeroRosterScreenState();
}

class _HeroRosterScreenState extends State<HeroRosterScreen> {
  late final Future<List<HeroModel>> _heroesFuture;
  final _api = SuperheroApiService();
  bool _hasLoadedHeroes = false;

  @override
  void initState() {
    super.initState();
    _heroesFuture = _api.fetchRandomHeroes(count: 50);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<HeroModel>>(
      future: _heroesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final allHeroes = snapshot.data ?? [];
        if (!_hasLoadedHeroes && allHeroes.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<HeroRosterProvider>().setAllHeroes(allHeroes);
              setState(() {
                _hasLoadedHeroes = true;
              });
            }
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hero Roster'),
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Filter Buttons only
              _buildFilterSection(),
              // Hero Grid
              Expanded(
                child: _buildHeroGrid(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection() {
    return Consumer<HeroRosterProvider>(
      builder: (context, provider, _) {
        final filters = ['All', 'Common', 'Rare', 'Epic', 'Legendary'];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: filters
                            .map((filter) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _buildFilterButton(
                                    label: filter,
                                    isActive: provider.selectedRarityFilter == filter,
                                    onPressed: () {
                                      provider.setRarityFilter(filter);
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildSortButton(provider),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: isActive
            ? Colors.white
            : Theme.of(context).colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label),
    );
  }

  Widget _buildSortButton(HeroRosterProvider provider) {
    final icon = provider.isSortedAscending
        ? Icons.arrow_upward
        : Icons.arrow_downward;

    return PopupMenuButton<HeroRosterSortType>(
      tooltip: 'Sort by ${provider.sortLabel}',
      color: Theme.of(context).colorScheme.surface,
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: HeroRosterSortType.rarity,
          child: Row(
            children: [
              const Icon(Icons.star, size: 18),
              const SizedBox(width: 8),
              const Text('Sort by Rarity'),
            ],
          ),
        ),
        PopupMenuItem(
          value: HeroRosterSortType.name,
          child: Row(
            children: [
              const Icon(Icons.sort_by_alpha, size: 18),
              const SizedBox(width: 8),
              const Text('Sort by Name'),
            ],
          ),
        ),
      ],
      onSelected: provider.setSortType,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 6),
            Text(
              '${provider.sortLabel} ${provider.isSortedAscending ? '↑' : '↓'}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroGrid() {
    return Consumer2<HeroRosterProvider, DeckProvider>(
      builder: (context, provider, deck, _) {
        final heroes = provider.heroes;

        if (heroes.isEmpty) {
          return const Center(
            child: Text('No heroes found'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 280,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: heroes.length,
          itemBuilder: (context, index) {
            final hero = heroes[index];
            final inDeck = deck.contains(hero);
            return _buildRosterHeroCard(hero, inDeck, deck);
          },
        );
      },
    );
  }

  Widget _buildRosterHeroCard(HeroModel hero, bool inDeck, DeckProvider deck) {
    final borderColor = inDeck ? Colors.green.shade600 : Colors.amber.shade700;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5D6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: hero.imageUrl.isNotEmpty
                          ? Image.network(
                              hero.imageUrl,
                              fit: BoxFit.fill,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image),
                              ),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          if (inDeck) {
                            deck.removeHero(hero);
                          } else {
                            deck.addHero(hero);
                          }
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: inDeck ? Colors.green.shade700 : Colors.black87,
                          child: Icon(
                            inDeck ? Icons.check : Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Text(
                  hero.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
