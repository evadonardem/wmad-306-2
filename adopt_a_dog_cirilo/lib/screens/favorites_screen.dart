import 'package:adopt_a_dog/models/breed.dart';
import 'package:adopt_a_dog/screens/breed_detail_screen.dart';
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
  final PrefsService _prefsService = PrefsService();
  final DogApiService _apiService = DogApiService();
  late Future<Set<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoritesFuture = _prefsService.loadFavorites();
  }

  String _displayTextFromPath(String path) {
    final parts = path.split('/');
    if (parts.length == 1) return parts.first;
    return '${parts[1]} ${parts[0]}';
  }

  Future<void> _removeFavorite(String path) async {
    await _prefsService.removeFavorite(path);
    setState(() => _loadFavorites());
  }

  Future<void> _clearAll() async {
    await _prefsService.clearFavorites();
    setState(() => _loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear all favorites',
            onPressed: () async {
              await _clearAll();
            },
          ),
        ],
      ),
      body: FutureBuilder<Set<String>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? <String>{};
          if (favorites.isEmpty) {
            return const Center(child: Text('No favorites yet'));
          }

          final sorted = favorites.toList()..sort();

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final path = sorted[index];
              final segments = path.split('/');
              final breed = segments[0];
              final subBreed = segments.length > 1 ? segments[1] : null;

              return FutureBuilder<String>(
                future: _apiService.fetchRandomImage(breed: breed, subBreed: subBreed),
                builder: (context, snapshot) {
                  final imageChild = snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                          ? const Center(child: Icon(Icons.error, color: Colors.red))
                          : CachedNetworkImage(
                              imageUrl: snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.red)),
                            );

                  return GestureDetector(
                    onTap: () async {
                      final breedModel = Breed(name: breed, subBreeds: subBreed != null ? [subBreed] : []);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BreedDetailScreen(breed: breedModel)),
                      );
                      setState(() => _loadFavorites());
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: imageChild),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.45), Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          right: 8,
                          child: Text(
                            _displayTextFromPath(path),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black54, blurRadius: 6)]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white.withOpacity(0.9),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _removeFavorite(path),
                              child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
