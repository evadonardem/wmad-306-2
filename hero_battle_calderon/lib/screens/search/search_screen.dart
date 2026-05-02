import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hero_model.dart';
import '../../providers/hero_search_provider.dart';
import '../../widgets/hero_image.dart';
import '../../widgets/hero_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HeroSearchProvider>();
      provider.initialize().then((_) {
        if (mounted) {
          _searchController.text = provider.currentQuery;
        }
      });
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
        title: const Row(
          children: [
            Icon(Icons.search_rounded),
            SizedBox(width: 8),
            Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndSort(),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Consumer<HeroSearchProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search superheroes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      provider.search('');
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (value) => provider.search(value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => provider.toggleSortOrder(),
                    icon: Icon(
                      provider.isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: provider.isAscending ? 'Ascending' : 'Descending',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: HeroSortBy.values
                            .where((e) => e != HeroSortBy.none)
                            .map((criteria) {
                          final isSelected = provider.sortBy == criteria;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(_formatSortLabel(criteria)),
                              selected: isSelected,
                              onSelected: (_) => provider.setSortBy(criteria),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatSortLabel(HeroSortBy criteria) {
    String name = criteria.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  Widget _buildResultsList() {
    return Consumer<HeroSearchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(child: Text('Error: ${provider.error}'));
        }

        final results = provider.results;
        if (results.isEmpty) {
          return const Center(child: Text('No heroes found. Try searching!'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final hero = results[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: HeroImage(
                    urls: [hero.imageUrl, hero.akababImageUrl],
                    heroId: hero.id,
                    heroName: hero.name,
                    searchTerms: hero.aliases,
                    fit: BoxFit.cover,
                    loading: Container(color: Colors.grey[200]),
                    error: const Icon(Icons.person),
                  ),
                ),
              ),
              title: Text(hero.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(hero.fullName.isNotEmpty ? hero.fullName : hero.publisher),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getStatValue(hero, provider.sortBy).toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    provider.sortBy == HeroSortBy.total ? 'Total' : _formatSortLabel(provider.sortBy),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
              onTap: () => _showHeroDetails(context, hero),
            );
          },
        );
      },
    );
  }

  int _getStatValue(HeroModel hero, HeroSortBy criteria) {
    switch (criteria) {
      case HeroSortBy.intelligence: return hero.powerStats.intelligence;
      case HeroSortBy.strength: return hero.powerStats.strength;
      case HeroSortBy.speed: return hero.powerStats.speed;
      case HeroSortBy.durability: return hero.powerStats.durability;
      case HeroSortBy.power: return hero.powerStats.power;
      case HeroSortBy.combat: return hero.powerStats.combat;
      case HeroSortBy.total:
        return hero.powerStats.intelligence +
               hero.powerStats.strength +
               hero.powerStats.speed +
               hero.powerStats.durability +
               hero.powerStats.power +
               hero.powerStats.combat;
      default: return 0;
    }
  }

  void _showHeroDetails(BuildContext context, HeroModel hero) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => HeroCard(hero: hero),
    );
  }
}
