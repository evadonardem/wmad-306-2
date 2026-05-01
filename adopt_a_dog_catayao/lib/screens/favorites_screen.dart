import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/app_state.dart';
import '../services/dog_api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DogApiService _dogApiService = DogApiService();
  final TextEditingController _searchController = TextEditingController();
  final AppState _appState = AppState.instance;

  late Future<List<_FavoritePreview>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavoritePreviews();
    _appState.addListener(_handleAppStateChanged);
  }

  @override
  void dispose() {
    _appState.removeListener(_handleAppStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleAppStateChanged() {
    if (mounted) {
      setState(() {
        _favoritesFuture = _loadFavoritePreviews();
      });
    }
  }

  Future<List<_FavoritePreview>> _loadFavoritePreviews() async {
    final previews = <_FavoritePreview>[];

    for (final breed in _appState.favorites) {
      try {
        final imageUrl = await _dogApiService.fetchRandomImage(breed: breed);
        previews.add(_FavoritePreview(breed: breed, imageUrl: imageUrl));
      } catch (_) {
        previews.add(_FavoritePreview(breed: breed));
      }
    }

    return previews;
  }

  Future<void> _refreshFavorites() async {
    setState(() {
      _favoritesFuture = _loadFavoritePreviews();
    });
  }

  Future<void> _removeFavorite(String breed) async {
    await _appState.removeFavorite(breed);
  }

  Future<void> _clearFavorites() async {
    await _appState.clearFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            onPressed: _clearFavorites,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<_FavoritePreview>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? <_FavoritePreview>[];
          final query = _searchController.text.trim().toLowerCase();
          final filteredFavorites = favorites.where((favorite) {
            return favorite.breed.toLowerCase().contains(query);
          }).toList();

          if (favorites.isEmpty) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(
                child: Text('No favorites saved yet!\nTap heart on any breed photo.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshFavorites,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFF8F2), Color(0xFFFFEDE0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: filteredFavorites.length + 2,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Breeds',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${favorites.length} breeds ready for quick review',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }

                  if (index == 1) {
                    return TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search favorites',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close),
                              ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  }

                  final favorite = filteredFavorites[index - 2];
                  return Container(
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
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 68,
                          height: 68,
                          child: favorite.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: favorite.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image),
                                )
                              : Container(
                                  color: const Color(0xFFFFE0B2),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.pets),
                                ),
                        ),
                      ),
                      title: Text(
                        favorite.breed[0].toUpperCase() +
                            favorite.breed.substring(1),
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: const Text(
                        'Saved for later comparison and viewing',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeFavorite(favorite.breed),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoritePreview {
  final String breed;
  final String? imageUrl;

  const _FavoritePreview({required this.breed, this.imageUrl});
}
