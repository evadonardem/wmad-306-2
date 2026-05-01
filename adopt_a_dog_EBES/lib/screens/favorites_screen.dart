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

  // FIX 3: Cache one Future<String> per breed name so that rebuilds never
  // create a new network request. Previously fetchRandomImage(breed) was
  // called directly inside ListView.builder's itemBuilder, creating a fresh
  // Future on every frame — the anti-pattern warned about in Section 7.
  final Map<String, Future<String>> _imageFutures = {};

  Future<String> _imageFor(String breed) =>
      _imageFutures.putIfAbsent(breed, () => _api.fetchRandomImage(breed));

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _prefs.loadFavorites();
  }

  void _reload() {
    setState(() {
      _imageFutures.clear(); // allow fresh images after list changes
      _favoritesFuture = _prefs.loadFavorites();
    });
  }

  Future<void> _delete(String breed) async {
    await _prefs.removeFavorite(breed);
    _reload();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snap.data ?? [];

          // Empty state
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites saved yet!\nTap ♥ on any breed photo.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Breeds →'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final breed = favorites[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 72,
                    height: 72,
                    // Uses the cached Future — no new request on rebuild
                    child: FutureBuilder<String>(
                      future: _imageFor(breed),
                      builder: (ctx, imgSnap) {
                        if (imgSnap.connectionState != ConnectionState.done) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (imgSnap.hasError || !imgSnap.hasData) {
                          return const Icon(Icons.broken_image);
                        }
                        return CachedNetworkImage(
                          imageUrl: imgSnap.data!,
                          fit: BoxFit.cover,
                          width: 72,
                          height: 72,
                          placeholder: (c, _) => const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (c, _, _) =>
                              const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    _capitalize(breed),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Remove from favorites',
                    onPressed: () => _delete(breed),
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