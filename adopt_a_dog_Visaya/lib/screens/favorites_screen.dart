import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../services/dog_api_service.dart';
import '../services/prefs_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _prefs = PrefsService();
  final _api = DogApiService();
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefs.loadFavorites();
  }

  Future<void> _refreshFavorites() async {
    if (mounted) {
      setState(() {
        _favoritesFuture = _prefs.loadFavorites();
      });
    }
  }

  Future<void> _removeFavorite(String breedName) async {
    await _prefs.removeFavorite(breedName);
    await _refreshFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet. Go to Breeds and tap ♥ to add one.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final breed = favorites[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.redAccent),
                  title: Text(breed),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeFavorite(breed),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FutureBuilder<String>(
                        future: _api.fetchRandomImage(breed),
                        builder: (context, imgSnap) {
                          if (imgSnap.connectionState != ConnectionState.done) {
                            return const Scaffold(
                              body: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (imgSnap.hasError) {
                            return Scaffold(
                              body: Center(child: Text('Error: ${imgSnap.error}')),
                            );
                          }
                          return Scaffold(
                            appBar: AppBar(title: Text('Favorite: $breed')),
                            body: Center(
                              child: CachedNetworkImage(
                                imageUrl: imgSnap.data ?? '',
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                memCacheWidth: 1080,
                                memCacheHeight: 1080,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.broken_image, size: 64),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
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
