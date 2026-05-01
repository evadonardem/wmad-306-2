import 'package:flutter/material.dart';

import '../models/breed.dart';
import '../services/app_state.dart';
import '../services/dog_api_service.dart';
import 'breed_detail_screen.dart';
import 'care_tips_screen.dart';

class BreedListScreen extends StatefulWidget {
  const BreedListScreen({super.key});

  @override
  State<BreedListScreen> createState() => _BreedListScreenState();
}

class _BreedListScreenState extends State<BreedListScreen> {
  final DogApiService _dogApiService = DogApiService();
  final TextEditingController _searchController = TextEditingController();
  final AppState _appState = AppState.instance;

  late Future<List<Breed>> _breedsFuture;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _breedsFuture = _dogApiService.fetchBreeds();
    _searchController.text = _appState.lastSearch;
    _searchController.addListener(_onSearchChanged);
    _appState.addListener(_syncSearchFromState);
  }

  @override
  void dispose() {
    _appState.removeListener(_syncSearchFromState);
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _syncSearchFromState() {
    if (_searchController.text != _appState.lastSearch) {
      _searchController.value = TextEditingValue(
        text: _appState.lastSearch,
        selection: TextSelection.collapsed(
          offset: _appState.lastSearch.length,
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSearchChanged() {
    _appState.saveLastSearch(_searchController.text);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _breedsFuture = _dogApiService.fetchBreeds();
    });

    try {
      await _breedsFuture;
    } catch (_) {
      // FutureBuilder handles the error state.
    }
  }

  Future<void> _toggleFavorite(String breedName) async {
    if (_appState.favorites.contains(breedName)) {
      await _appState.removeFavorite(breedName);
    } else {
      await _appState.addFavorite(breedName);
    }
  }

  List<Breed> _filteredBreeds(List<Breed> breeds) {
    final query = _searchController.text.trim().toLowerCase();

    return breeds.where((breed) {
      final searchableText = [
        breed.name,
        ...breed.subBreeds,
      ].join(' ').toLowerCase();
      final matchesSearch =
          query.isEmpty ? true : searchableText.contains(query);
      final matchesFavorite =
          !_favoritesOnly || _appState.favorites.contains(breed.name);
      return matchesSearch && matchesFavorite;
    }).toList();
  }

  List<Breed> _featuredBreeds(List<Breed> breeds) {
    final recentNames = _appState.recentBreeds.toSet();
    final featured = breeds.where((breed) {
      return recentNames.contains(breed.name) || breed.subBreeds.isNotEmpty;
    }).take(6).toList();

    if (featured.isNotEmpty) {
      return featured;
    }

    return breeds.take(6).toList();
  }

  String _formatBreedName(String breedName) {
    return breedName[0].toUpperCase() + breedName.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Discover Dogs'),
            actions: [
              IconButton(
                tooltip: 'Care tips',
                onPressed: () {
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareTipsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book_outlined),
              ),
            ],
          ),
          body: FutureBuilder<List<Breed>>(
            future: _breedsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allBreeds = snapshot.data ?? <Breed>[];
              final breeds = _filteredBreeds(allBreeds);
              final featuredBreeds = _featuredBreeds(allBreeds);

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: breeds.length + 4,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Adopt a Dog',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Browse breeds, compare favorites, and learn better pet care in one warm, simple app.',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatPill(
                                    label: 'Breeds',
                                    value: '${allBreeds.length}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatPill(
                                    label: 'Favorites',
                                    value: '${_appState.favorites.length}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatPill(
                                    label: 'Recent',
                                    value: '${_appState.recentBreeds.length}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }

                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search breeds or sub-breeds',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isEmpty
                                ? null
                                : IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      );
                    }

                    if (index == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            FilterChip(
                              label: const Text('Favorites only'),
                              selected: _favoritesOnly,
                              onSelected: (value) {
                                setState(() => _favoritesOnly = value);
                              },
                            ),
                            ActionChip(
                              label: const Text('Clear recent'),
                              onPressed: () async {
                                await _appState.clearRecentBreeds();
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    if (index == 3) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Featured picks',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 152,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredBreeds.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, featuredIndex) {
                                  final breed = featuredBreeds[featuredIndex];
                                  return GestureDetector(
                                    onTap: () async {
                                      await Navigator.push<void>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BreedDetailScreen(breed: breed),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 170,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x10000000),
                                            blurRadius: 14,
                                            offset: Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFE0B2),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: const Icon(
                                              Icons.pets,
                                              color: Color(0xFFEF6C00),
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            _formatBreedName(breed.name),
                                            style: theme.textTheme.titleMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            breed.subBreeds.isEmpty
                                                ? 'Main breed'
                                                : '${breed.subBreeds.length} sub-breeds',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'All breeds',
                              style: theme.textTheme.titleLarge,
                            ),
                            if (breeds.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text('No breeds found for this filter.'),
                              ),
                          ],
                        ),
                      );
                    }

                    final breed = breeds[index - 4];
                    final isFavorite = _appState.favorites.contains(breed.name);
                    final title = _formatBreedName(breed.name);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE0B2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.pets,
                            color: Color(0xFFEF6C00),
                          ),
                        ),
                        title: Text(title, style: theme.textTheme.titleMedium),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            breed.subBreeds.isEmpty
                                ? 'No sub-breeds listed'
                                : 'Sub-breeds: ${breed.subBreeds.join(', ')}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 48,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () => _toggleFavorite(breed.name),
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? const Color(0xFFE53935)
                                      : Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                        onTap: () async {
                          await Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BreedDetailScreen(breed: breed),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
