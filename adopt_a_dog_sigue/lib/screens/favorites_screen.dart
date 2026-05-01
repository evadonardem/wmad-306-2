import 'package:adopt_a_dog/services/dog_api_service.dart';
import 'package:adopt_a_dog/services/prefs_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

  void _reload() {
    setState(() {
      _favoritesFuture = _prefs.loadFavorites();
    });
  }

  Future<void> _removeFavorite(String breed) async {
    await _prefs.removeFavorite(breed);
    _reload();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$breed removed!')));
    }
  }

  Future<void> _clearAll() async {
    await _prefs.clearFavorite();
    _reload();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All favorites cleared!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: FutureBuilder<List<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites saved yet!\nTap ♥ on any breed photo.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final breed = favorites[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: FutureBuilder<String>(
                    future: _api.fetchRandomImage(breed),
                    builder: (context, imgSnap) {
                      if (imgSnap.connectionState != ConnectionState.done) {
                        return const SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (imgSnap.hasError || imgSnap.data == null) {
                        return const Icon(Icons.pets, size: 56);
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imgSnap.data!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => const SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (ctx, url, err) =>
                              const Icon(Icons.pets, size: 56),
                        ),
                      );
                    },
                  ),
                  title: Text(
                    breed[0].toUpperCase() + breed.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFavorite(breed),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAll,
        child: const Icon(Icons.delete_sweep),
      ),
    );
  }
}
